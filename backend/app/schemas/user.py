import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class UserProfileResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    nickname: str
    avatar_url: str | None = None
    wallpaper_url: str | None = None
    message: str | None = None
    follower_count: int = 0
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserResponse(BaseModel):
    id: uuid.UUID
    email: str
    is_active: bool
    is_admin: bool
    email_verified: bool
    profile: UserProfileResponse | None = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class UserProfileUpdate(BaseModel):
    nickname: str | None = Field(None, min_length=1, max_length=100)
    avatar_url: str | None = None
    wallpaper_url: str | None = None
    message: str | None = Field(None, max_length=500)


class AdminUserResponse(BaseModel):
    id: uuid.UUID
    email: str
    is_active: bool
    is_admin: bool
    email_verified: bool
    profile: UserProfileResponse | None = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class AdminUserStatusUpdate(BaseModel):
    is_active: bool | None = None
    is_admin: bool | None = None
