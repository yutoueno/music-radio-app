import uuid

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.program import Program
from app.models.social import Favorite, Follow
from app.models.user import User, UserProfile


class SocialService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # --- Favorites ---

    async def add_favorite(self, user_id: uuid.UUID, program_id: uuid.UUID) -> Favorite | dict:
        # Check program exists
        result = await self.db.execute(select(Program).where(Program.id == program_id))
        program = result.scalar_one_or_none()
        if not program:
            return {"error": "NOT_FOUND", "message": "番組が見つかりません"}

        # Check duplicate
        existing = await self.db.execute(
            select(Favorite).where(
                Favorite.user_id == user_id, Favorite.program_id == program_id
            )
        )
        if existing.scalar_one_or_none():
            return {"error": "ALREADY_EXISTS", "message": "既にお気に入りに追加されています"}

        favorite = Favorite(user_id=user_id, program_id=program_id)
        self.db.add(favorite)

        program.favorite_count = (program.favorite_count or 0) + 1
        await self.db.flush()
        return favorite

    async def remove_favorite(self, user_id: uuid.UUID, program_id: uuid.UUID) -> bool:
        result = await self.db.execute(
            select(Favorite).where(
                Favorite.user_id == user_id, Favorite.program_id == program_id
            )
        )
        favorite = result.scalar_one_or_none()
        if not favorite:
            return False

        await self.db.delete(favorite)

        # Decrement count
        prog_result = await self.db.execute(select(Program).where(Program.id == program_id))
        program = prog_result.scalar_one_or_none()
        if program and program.favorite_count > 0:
            program.favorite_count -= 1

        await self.db.flush()
        return True

    async def get_user_favorites(
        self, user_id: uuid.UUID, page: int = 1, per_page: int = 30
    ) -> tuple[list[Favorite], int]:
        query = select(Favorite).where(Favorite.user_id == user_id)

        count_result = await self.db.execute(
            select(func.count()).select_from(query.subquery())
        )
        total = count_result.scalar() or 0

        query = query.order_by(Favorite.created_at.desc())
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        favorites = list(result.scalars().all())

        return favorites, total

    # --- Follows ---

    async def follow_user(self, follower_id: uuid.UUID, following_id: uuid.UUID) -> Follow | dict:
        if follower_id == following_id:
            return {"error": "INVALID_OPERATION", "message": "自分自身をフォローすることはできません"}

        # Check user exists
        result = await self.db.execute(select(User).where(User.id == following_id))
        target_user = result.scalar_one_or_none()
        if not target_user:
            return {"error": "NOT_FOUND", "message": "ユーザーが見つかりません"}

        # Check duplicate
        existing = await self.db.execute(
            select(Follow).where(
                Follow.follower_id == follower_id, Follow.following_id == following_id
            )
        )
        if existing.scalar_one_or_none():
            return {"error": "ALREADY_EXISTS", "message": "既にフォロー済みです"}

        follow = Follow(follower_id=follower_id, following_id=following_id)
        self.db.add(follow)

        # Update follower count
        profile_result = await self.db.execute(
            select(UserProfile).where(UserProfile.user_id == following_id)
        )
        profile = profile_result.scalar_one_or_none()
        if profile:
            profile.follower_count = (profile.follower_count or 0) + 1

        await self.db.flush()
        return follow

    async def unfollow_user(self, follower_id: uuid.UUID, following_id: uuid.UUID) -> bool:
        result = await self.db.execute(
            select(Follow).where(
                Follow.follower_id == follower_id, Follow.following_id == following_id
            )
        )
        follow = result.scalar_one_or_none()
        if not follow:
            return False

        await self.db.delete(follow)

        # Decrement follower count
        profile_result = await self.db.execute(
            select(UserProfile).where(UserProfile.user_id == following_id)
        )
        profile = profile_result.scalar_one_or_none()
        if profile and profile.follower_count > 0:
            profile.follower_count -= 1

        await self.db.flush()
        return True

    async def get_user_follows(
        self, user_id: uuid.UUID, page: int = 1, per_page: int = 30
    ) -> tuple[list[Follow], int]:
        query = select(Follow).where(Follow.follower_id == user_id)

        count_result = await self.db.execute(
            select(func.count()).select_from(query.subquery())
        )
        total = count_result.scalar() or 0

        query = query.order_by(Follow.created_at.desc())
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        follows = list(result.scalars().all())

        return follows, total

    async def get_user_followers(
        self, user_id: uuid.UUID, page: int = 1, per_page: int = 30
    ) -> tuple[list[Follow], int]:
        query = select(Follow).where(Follow.following_id == user_id)

        count_result = await self.db.execute(
            select(func.count()).select_from(query.subquery())
        )
        total = count_result.scalar() or 0

        query = query.order_by(Follow.created_at.desc())
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        follows = list(result.scalars().all())

        return follows, total
