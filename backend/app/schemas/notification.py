import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class DeviceTokenRegister(BaseModel):
    device_token: str = Field(..., min_length=1, max_length=512)
    platform: str = Field(default="ios", max_length=20)


class DeviceTokenResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    device_token: str
    platform: str
    created_at: datetime

    model_config = {"from_attributes": True}


class NotificationResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    body: str
    data: dict | None = None
    read: bool = False
    created_at: datetime

    model_config = {"from_attributes": True}


class UnreadCountResponse(BaseModel):
    unread_count: int
