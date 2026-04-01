import uuid
from datetime import datetime

from pydantic import BaseModel


class FavoriteCreate(BaseModel):
    program_id: uuid.UUID


class FavoriteResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    program_id: uuid.UUID
    created_at: datetime

    model_config = {"from_attributes": True}


class FollowCreate(BaseModel):
    following_id: uuid.UUID


class FollowResponse(BaseModel):
    id: uuid.UUID
    follower_id: uuid.UUID
    following_id: uuid.UUID
    created_at: datetime

    model_config = {"from_attributes": True}


class PlayLogCreate(BaseModel):
    program_id: uuid.UUID
    duration_seconds: float | None = None


class PlayRecordRequest(BaseModel):
    duration_seconds: float | None = None
