import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class PlaybackSessionResponse(BaseModel):
    id: uuid.UUID
    program_id: uuid.UUID
    current_position_seconds: float = 0
    is_completed: bool = False
    updated_at: datetime

    model_config = {"from_attributes": True}


class PlaybackProgressUpdate(BaseModel):
    current_position_seconds: float = Field(..., ge=0)
    is_completed: bool | None = None


class AudioStreamResponse(BaseModel):
    stream_url: str
    expires_in: int = 3600
    program_id: uuid.UUID
    duration_seconds: float | None = None
    waveform_data: list[float] | None = None


class TrackPlayCreate(BaseModel):
    program_id: uuid.UUID
    track_id: uuid.UUID


class PlaybackHistoryItem(BaseModel):
    program_id: uuid.UUID
    program_title: str
    program_thumbnail_url: str | None = None
    current_position_seconds: float = 0
    is_completed: bool = False
    duration_seconds: float | None = None
    updated_at: datetime

    model_config = {"from_attributes": True}
