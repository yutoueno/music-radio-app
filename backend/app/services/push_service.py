"""APNs push notification service using HTTP/2 via httpx."""

import asyncio
import json
import logging
import time
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

import httpx
from jose import jwt
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.notification import DeviceToken

logger = logging.getLogger(__name__)

APNS_SANDBOX_URL = "https://api.sandbox.push.apple.com"
APNS_PRODUCTION_URL = "https://api.push.apple.com"

# Module-level token cache
_apns_token: str | None = None
_apns_token_expiry: float = 0


def _get_apns_base_url() -> str:
    settings = get_settings()
    if settings.APNS_USE_SANDBOX:
        return APNS_SANDBOX_URL
    return APNS_PRODUCTION_URL


def _load_apns_private_key() -> str | None:
    """Load the APNs private key from the configured file path."""
    settings = get_settings()
    key_path = settings.APNS_PRIVATE_KEY_PATH
    if not key_path:
        return None
    path = Path(key_path)
    if not path.exists():
        logger.warning("APNs private key file not found at %s", key_path)
        return None
    return path.read_text()


def _generate_apns_token() -> str | None:
    """Generate a JWT token for APNs authentication.

    Apple requires ES256-signed JWTs with team_id as issuer and key_id in the header.
    Tokens are valid for up to 60 minutes.
    """
    settings = get_settings()

    if not settings.APNS_KEY_ID or not settings.APNS_TEAM_ID:
        return None

    private_key = _load_apns_private_key()
    if not private_key:
        return None

    now = datetime.now(timezone.utc)
    payload = {
        "iss": settings.APNS_TEAM_ID,
        "iat": int(now.timestamp()),
    }
    headers = {
        "alg": "ES256",
        "kid": settings.APNS_KEY_ID,
    }
    try:
        token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
        return token
    except Exception:
        logger.exception("Failed to generate APNs JWT token")
        return None


def _get_apns_token() -> str | None:
    """Get a cached APNs token, regenerating if expired (every 50 minutes)."""
    global _apns_token, _apns_token_expiry
    now = time.time()
    if _apns_token is None or now >= _apns_token_expiry:
        _apns_token = _generate_apns_token()
        if _apns_token:
            _apns_token_expiry = now + 50 * 60  # refresh every 50 min (valid for 60)
    return _apns_token


def _is_configured() -> bool:
    """Check whether APNs credentials are configured."""
    settings = get_settings()
    return bool(settings.APNS_KEY_ID and settings.APNS_TEAM_ID and settings.APNS_BUNDLE_ID)


async def send_push(
    device_token: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    """Send a push notification to a single device via APNs HTTP/2.

    Returns True if sent successfully, False otherwise.
    """
    if not _is_configured():
        logger.warning("APNs credentials not configured — skipping push notification")
        return False

    token = _get_apns_token()
    if not token:
        logger.warning("Failed to obtain APNs JWT token — skipping push")
        return False

    settings = get_settings()
    base_url = _get_apns_base_url()
    url = f"{base_url}/3/device/{device_token}"

    # Build the APNs payload
    aps_payload: dict = {
        "alert": {
            "title": title,
            "body": body,
        },
        "sound": "default",
        "badge": 1,
    }
    payload: dict = {"aps": aps_payload}
    if data:
        # Merge custom data at the top level (outside aps)
        payload.update(data)

    headers = {
        "authorization": f"bearer {token}",
        "apns-topic": settings.APNS_BUNDLE_ID,
        "apns-push-type": "alert",
        "apns-priority": "10",
        "apns-expiration": "0",
    }

    try:
        async with httpx.AsyncClient(http2=True, timeout=10) as client:
            response = await client.post(
                url,
                json=payload,
                headers=headers,
            )

        if response.status_code == 200:
            logger.debug("Push sent successfully to device %s...", device_token[:20])
            return True

        # Handle known APNs error responses
        error_body = {}
        try:
            error_body = response.json()
        except Exception:
            pass

        reason = error_body.get("reason", "Unknown")
        logger.warning(
            "APNs returned %d for device %s...: %s",
            response.status_code,
            device_token[:20],
            reason,
        )

        # Return the reason so the caller can handle invalid tokens
        if reason in ("BadDeviceToken", "Unregistered", "ExpiredToken"):
            # Signal that this token should be removed
            raise InvalidTokenError(device_token)

        return False

    except InvalidTokenError:
        raise
    except httpx.HTTPError as exc:
        logger.warning("Network error sending push to %s...: %s", device_token[:20], exc)
        return False
    except Exception:
        logger.exception("Unexpected error sending push to %s...", device_token[:20])
        return False


class InvalidTokenError(Exception):
    """Raised when APNs reports a device token is invalid or unregistered."""

    def __init__(self, device_token: str):
        self.device_token = device_token
        super().__init__(f"Invalid APNs device token: {device_token[:20]}...")


async def send_push_to_user(
    db: AsyncSession,
    user_id: uuid.UUID,
    title: str,
    body: str,
    data: dict | None = None,
) -> int:
    """Send push notifications to all registered devices for a user.

    Automatically cleans up invalid device tokens.
    Returns the number of successfully sent notifications.
    """
    if not _is_configured():
        logger.warning("APNs not configured — skipping push for user %s", user_id)
        return 0

    # Fetch device tokens for the user
    result = await db.execute(
        select(DeviceToken).where(DeviceToken.user_id == user_id)
    )
    tokens = list(result.scalars().all())

    if not tokens:
        return 0

    sent_count = 0
    tokens_to_remove: list[str] = []

    for token_obj in tokens:
        try:
            success = await send_push(token_obj.device_token, title, body, data)
            if success:
                sent_count += 1
        except InvalidTokenError:
            tokens_to_remove.append(token_obj.device_token)
            logger.info(
                "Removing invalid device token %s... for user %s",
                token_obj.device_token[:20],
                user_id,
            )

    # Clean up invalid tokens
    if tokens_to_remove:
        await db.execute(
            delete(DeviceToken).where(DeviceToken.device_token.in_(tokens_to_remove))
        )
        await db.flush()

    return sent_count


async def send_push_to_user_background(
    db: AsyncSession,
    user_id: uuid.UUID,
    title: str,
    body: str,
    data: dict | None = None,
) -> None:
    """Fire-and-forget wrapper for send_push_to_user.

    Creates an asyncio task so the caller is not blocked.
    Errors are logged but never propagated.
    """
    try:
        await send_push_to_user(db, user_id, title, body, data)
    except Exception:
        logger.exception("Background push failed for user %s", user_id)
