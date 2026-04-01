import uuid
import logging

from sqlalchemy import func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import DeviceToken, Notification
from app.models.social import Follow
from app.models.user import UserProfile

logger = logging.getLogger(__name__)


class NotificationService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # --- Device Token ---

    async def register_device_token(
        self, user_id: uuid.UUID, device_token: str, platform: str = "ios"
    ) -> DeviceToken:
        # Check if token already exists
        result = await self.db.execute(
            select(DeviceToken).where(DeviceToken.device_token == device_token)
        )
        existing = result.scalar_one_or_none()

        if existing:
            # Update user_id if different (device transferred to new user)
            if existing.user_id != user_id:
                existing.user_id = user_id
                existing.platform = platform
                await self.db.flush()
            return existing

        token = DeviceToken(
            user_id=user_id,
            device_token=device_token,
            platform=platform,
        )
        self.db.add(token)
        await self.db.flush()
        return token

    # --- Notifications ---

    async def create_notification(
        self,
        user_id: uuid.UUID,
        title: str,
        body: str,
        data: dict | None = None,
    ) -> Notification:
        notification = Notification(
            user_id=user_id,
            title=title,
            body=body,
            data=data,
        )
        self.db.add(notification)
        await self.db.flush()

        # Attempt to send push notification (placeholder)
        await self._send_push_notification(user_id, title, body, data)

        return notification

    async def get_notifications(
        self, user_id: uuid.UUID, page: int = 1, per_page: int = 30
    ) -> tuple[list[Notification], int]:
        query = select(Notification).where(Notification.user_id == user_id)

        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        query = query.order_by(Notification.created_at.desc())
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        notifications = list(result.scalars().all())

        return notifications, total

    async def mark_as_read(self, notification_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        result = await self.db.execute(
            select(Notification).where(
                Notification.id == notification_id,
                Notification.user_id == user_id,
            )
        )
        notification = result.scalar_one_or_none()
        if not notification:
            return False
        notification.read = True
        await self.db.flush()
        return True

    async def mark_all_as_read(self, user_id: uuid.UUID) -> int:
        """Mark all unread notifications as read for a user. Returns count updated."""
        result = await self.db.execute(
            update(Notification)
            .where(Notification.user_id == user_id, Notification.read == False)  # noqa: E712
            .values(read=True)
        )
        await self.db.flush()
        return result.rowcount

    async def get_unread_count(self, user_id: uuid.UUID) -> int:
        result = await self.db.execute(
            select(func.count()).select_from(
                select(Notification)
                .where(Notification.user_id == user_id, Notification.read == False)  # noqa: E712
                .subquery()
            )
        )
        return result.scalar() or 0

    # --- Trigger notifications ---

    async def notify_followers_new_program(
        self, broadcaster_id: uuid.UUID, program_id: uuid.UUID, program_title: str
    ) -> None:
        """Notify all followers when a broadcaster publishes a new program."""
        # Get broadcaster nickname
        profile_result = await self.db.execute(
            select(UserProfile.nickname).where(UserProfile.user_id == broadcaster_id)
        )
        nickname = profile_result.scalar_one_or_none() or "配信者"

        # Get all follower IDs
        result = await self.db.execute(
            select(Follow.follower_id).where(Follow.following_id == broadcaster_id)
        )
        follower_ids = [row[0] for row in result.all()]

        for follower_id in follower_ids:
            await self.create_notification(
                user_id=follower_id,
                title="新しい番組が公開されました",
                body=f"{nickname}さんが「{program_title}」を公開しました",
                data={"type": "new_program", "program_id": str(program_id)},
            )

    async def notify_program_favorited(
        self, program_owner_id: uuid.UUID, program_id: uuid.UUID, program_title: str, favorited_by_id: uuid.UUID
    ) -> None:
        """Notify program owner when someone favorites their program."""
        # Don't notify if user favorites their own program
        if program_owner_id == favorited_by_id:
            return

        # Get the nickname of the user who favorited
        profile_result = await self.db.execute(
            select(UserProfile.nickname).where(UserProfile.user_id == favorited_by_id)
        )
        nickname = profile_result.scalar_one_or_none() or "ユーザー"

        await self.create_notification(
            user_id=program_owner_id,
            title="お気に入り登録されました",
            body=f"{nickname}さんが「{program_title}」をお気に入りに追加しました",
            data={"type": "favorited", "program_id": str(program_id)},
        )

    # --- Push notification ---

    async def _send_push_notification(
        self, user_id: uuid.UUID, title: str, body: str, data: dict | None = None
    ) -> None:
        """Send push notification via APNs.

        Non-blocking: errors are logged but never propagate to the caller.
        """
        try:
            from app.services.push_service import send_push_to_user_background
            await send_push_to_user_background(self.db, user_id, title, body, data)
        except Exception:
            logger.exception("Failed to send push notification to user %s", user_id)
