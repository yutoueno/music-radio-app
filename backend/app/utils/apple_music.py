import re
import time
from datetime import datetime, timedelta, timezone

import httpx
from jose import jwt

from app.config import get_settings

settings = get_settings()

# Regex patterns for Apple Music URLs
APPLE_MUSIC_TRACK_PATTERNS = [
    # https://music.apple.com/{storefront}/album/{album-name}/{album-id}?i={track-id}
    re.compile(r"music\.apple\.com/(\w+)/album/[^/]+/\d+\?i=(\d+)"),
    # https://music.apple.com/{storefront}/song/{song-name}/{track-id}
    re.compile(r"music\.apple\.com/(\w+)/song/[^/]+/(\d+)"),
]

APPLE_MUSIC_API_BASE = "https://api.music.apple.com/v1"


def extract_track_id_from_url(url: str) -> tuple[str, str] | None:
    """Extract storefront and track ID from an Apple Music URL.

    Returns (storefront, track_id) or None if the URL is not recognized.
    """
    for pattern in APPLE_MUSIC_TRACK_PATTERNS:
        match = pattern.search(url)
        if match:
            return match.group(1), match.group(2)
    return None


def generate_apple_music_developer_token() -> str:
    """Generate a developer token for the Apple Music API using the MusicKit private key."""
    try:
        with open(settings.APPLE_MUSIC_PRIVATE_KEY_PATH, "r") as f:
            private_key = f.read()
    except FileNotFoundError:
        raise RuntimeError(
            f"Apple Music private key not found at {settings.APPLE_MUSIC_PRIVATE_KEY_PATH}"
        )

    now = datetime.now(timezone.utc)
    payload = {
        "iss": settings.APPLE_MUSIC_TEAM_ID,
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(hours=12)).timestamp()),
    }
    headers = {
        "alg": "ES256",
        "kid": settings.APPLE_MUSIC_KEY_ID,
    }
    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
    return token


_cached_token: str | None = None
_token_expiry: float = 0


def get_developer_token() -> str:
    """Get a cached developer token, regenerating if expired."""
    global _cached_token, _token_expiry
    now = time.time()
    if _cached_token is None or now >= _token_expiry:
        _cached_token = generate_apple_music_developer_token()
        _token_expiry = now + 11 * 3600  # refresh after 11 hours
    return _cached_token


async def fetch_track_info(storefront: str, track_id: str) -> dict | None:
    """Fetch track metadata from the Apple Music API.

    Returns a dict with title, artist_name, artwork_url, duration_seconds, or None on failure.
    """
    token = get_developer_token()
    url = f"{APPLE_MUSIC_API_BASE}/catalog/{storefront}/songs/{track_id}"
    headers = {"Authorization": f"Bearer {token}"}

    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers, timeout=10)

    if response.status_code != 200:
        return None

    data = response.json()
    songs = data.get("data", [])
    if not songs:
        return None

    song = songs[0]
    attrs = song.get("attributes", {})
    artwork = attrs.get("artwork", {})
    artwork_url = None
    if artwork.get("url"):
        artwork_url = artwork["url"].replace("{w}", "600").replace("{h}", "600")

    return {
        "apple_music_track_id": track_id,
        "title": attrs.get("name", ""),
        "artist_name": attrs.get("artistName", ""),
        "artwork_url": artwork_url,
        "duration_seconds": attrs.get("durationInMillis", 0) / 1000.0,
        "apple_music_url": attrs.get("url", ""),
    }


async def resolve_apple_music_url(url: str) -> dict | None:
    """Given an Apple Music URL, extract the track ID and fetch metadata."""
    result = extract_track_id_from_url(url)
    if result is None:
        return None
    storefront, track_id = result
    return await fetch_track_info(storefront, track_id)
