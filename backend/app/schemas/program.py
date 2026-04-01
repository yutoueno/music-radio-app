import uuid
from datetime import datetime

from pydantic import BaseModel, Field

from app.models.program import ProgramStatus, ProgramType
from app.schemas.track import TrackResponse


class ProgramCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str | None = None
    audio_url: str | None = None
    thumbnail_url: str | None = None
    status: ProgramStatus = ProgramStatus.draft
    program_type: ProgramType = ProgramType.recorded
    genre: str | None = Field(None, max_length=100)
    scheduled_at: datetime | None = None
    duration_seconds: float | None = None
    waveform_data: dict | None = None


class ProgramUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    audio_url: str | None = None
    thumbnail_url: str | None = None
    status: ProgramStatus | None = None
    program_type: ProgramType | None = None
    genre: str | None = Field(None, max_length=100)
    scheduled_at: datetime | None = None
    duration_seconds: float | None = None
    waveform_data: dict | None = None


class ProgramResponse(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    title: str
    description: str | None = None
    audio_url: str | None = None
    thumbnail_url: str | None = None
    status: ProgramStatus
    program_type: ProgramType
    genre: str | None = None
    scheduled_at: datetime | None = None
    play_count: int = 0
    favorite_count: int = 0
    duration_seconds: float | None = None
    waveform_data: dict | None = None
    tracks: list[TrackResponse] = []
    user_nickname: str | None = None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ProgramFromTemplateRequest(BaseModel):
    template_name: str = Field(..., min_length=1, max_length=100)


class ProgramFromTemplateResponse(BaseModel):
    message: str
    program: ProgramResponse


class AdminProgramStatusUpdate(BaseModel):
    status: ProgramStatus
