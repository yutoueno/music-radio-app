import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.user import User, UserProfile
from app.utils.auth import (
    create_access_token,
    create_email_verification_token,
    create_password_reset_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)


class AuthService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_user_by_email(self, email: str) -> User | None:
        result = await self.db.execute(
            select(User).options(selectinload(User.profile)).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def get_user_by_id(self, user_id: uuid.UUID) -> User | None:
        result = await self.db.execute(
            select(User).options(selectinload(User.profile)).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def signup(self, email: str, password: str, nickname: str) -> dict:
        existing = await self.get_user_by_email(email)
        if existing:
            return {"error": "EMAIL_ALREADY_EXISTS", "message": "このメールアドレスは既に登録されています"}

        user = User(
            email=email,
            hashed_password=hash_password(password),
        )
        self.db.add(user)
        await self.db.flush()

        profile = UserProfile(
            user_id=user.id,
            nickname=nickname,
        )
        self.db.add(profile)
        await self.db.flush()

        access_token = create_access_token(data={"sub": str(user.id)})
        refresh_token = create_refresh_token(data={"sub": str(user.id)})

        # Generate email verification token (would be sent via email in production)
        _verification_token = create_email_verification_token(str(user.id))

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
        }

    async def login(self, email: str, password: str) -> dict:
        user = await self.get_user_by_email(email)
        if not user or not verify_password(password, user.hashed_password):
            return {"error": "INVALID_CREDENTIALS", "message": "メールアドレスまたはパスワードが正しくありません"}

        if not user.is_active:
            return {"error": "ACCOUNT_DISABLED", "message": "このアカウントは無効化されています"}

        access_token = create_access_token(data={"sub": str(user.id)})
        refresh_token = create_refresh_token(data={"sub": str(user.id)})

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
        }

    async def refresh_tokens(self, refresh_token: str) -> dict:
        payload = decode_token(refresh_token)
        if payload is None or payload.get("type") != "refresh":
            return {"error": "INVALID_TOKEN", "message": "無効なリフレッシュトークンです"}

        user_id = payload.get("sub")
        if not user_id:
            return {"error": "INVALID_TOKEN", "message": "無効なトークンです"}

        user = await self.get_user_by_id(uuid.UUID(user_id))
        if not user or not user.is_active:
            return {"error": "INVALID_TOKEN", "message": "ユーザーが見つかりません"}

        new_access = create_access_token(data={"sub": str(user.id)})
        new_refresh = create_refresh_token(data={"sub": str(user.id)})

        return {
            "access_token": new_access,
            "refresh_token": new_refresh,
            "token_type": "bearer",
        }

    async def verify_email(self, token: str) -> dict:
        payload = decode_token(token)
        if payload is None or payload.get("type") != "email_verify":
            return {"error": "INVALID_TOKEN", "message": "無効な認証トークンです"}

        user_id = payload.get("sub")
        user = await self.get_user_by_id(uuid.UUID(user_id))
        if not user:
            return {"error": "USER_NOT_FOUND", "message": "ユーザーが見つかりません"}

        user.email_verified = True
        await self.db.flush()
        return {"message": "メールアドレスの認証が完了しました"}

    async def request_password_reset(self, email: str) -> dict:
        user = await self.get_user_by_email(email)
        if user:
            _token = create_password_reset_token(str(user.id))
            # In production, send email with the reset link
        # Always return success to avoid email enumeration
        return {"message": "パスワードリセットメールを送信しました"}

    async def reset_password(self, token: str, new_password: str) -> dict:
        payload = decode_token(token)
        if payload is None or payload.get("type") != "password_reset":
            return {"error": "INVALID_TOKEN", "message": "無効なリセットトークンです"}

        user_id = payload.get("sub")
        user = await self.get_user_by_id(uuid.UUID(user_id))
        if not user:
            return {"error": "USER_NOT_FOUND", "message": "ユーザーが見つかりません"}

        user.hashed_password = hash_password(new_password)
        await self.db.flush()
        return {"message": "パスワードを変更しました"}
