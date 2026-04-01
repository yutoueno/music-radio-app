import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class TrackCreate(BaseModel):
    program_id: uuid.UUID
    apple_music_url: str | None = None
    apple_music_track_id: str | None = None
    title: str = Field(..., min_length=1, max_length=255)
    artist_name: str = Field(..., min_length=1, max_length=255)
    artwork_url: str | None = None
    play_timing_seconds: float = 0
    duration_seconds: float | None = None
    track_order: int = 0


class TrackUpdate(BaseModel):
    apple_music_url: str | None = None
    apple_music_track_id: str | None = None
    title: str | None = Field(None, min_length=1, max_length=255)
    artist_name: str | None = Field(None, min_length=1, max_length=255)
    artwork_url: str | None = None
    play_timing_seconds: float | None = None
    duration_seconds: float | None = None
    track_order: int | None = None


class TrackResponse(BaseModel):
    id: uuid.UUID
    program_id: uuid.UUID
    apple_music_url: str | None = None
    apple_music_track_id: str | None = None
    title: str
    artist_name: str
    artwork_url: str | None = None
    play_timing_seconds: float
    duration_seconds: float | None = None
    track_order: int
    created_at: datetime

    model_config = {"from_attributes": True}


class AppleMusicResolveRequest(BaseModel):
    url: str


class AppleMusicTrackInfo(BaseModel):
    apple_music_track_id: str
    title: str
    artist_name: str
    artwork_url: str | None = None
    duration_seconds: float | None = None
    apple_music_url: str
