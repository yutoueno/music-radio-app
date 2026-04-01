import uuid
from datetime import datetime

from pydantic import BaseModel, EmailStr, Field

from app.models.inquiry import InquiryStatus


class InquiryCreate(BaseModel):
    email: EmailStr
    subject: str = Field(..., min_length=1, max_length=255)
    body: str = Field(..., min_length=1)


class InquiryResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID | None
    email: str
    subject: str
    body: str
    status: InquiryStatus
    admin_note: str | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class InquiryAdminUpdate(BaseModel):
    status: InquiryStatus | None = None
    admin_note: str | None = None
