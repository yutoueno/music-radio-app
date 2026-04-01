import uuid
from datetime import datetime
from enum import Enum as PyEnum

from sqlalchemy import (
    JSON,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.compat import GUID
from app.database import Base


class ProgramStatus(str, PyEnum):
    draft = "draft"
    published = "published"
    archived = "archived"


class ProgramType(str, PyEnum):
    recorded = "recorded"
    live = "live"


class Program(Base):
    __tablename__ = "programs"

    id: Mapped[uuid.UUID] = mapped_column(
        GUID, primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        GUID, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    audio_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    thumbnail_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[ProgramStatus] = mapped_column(
        Enum(ProgramStatus, name="program_status"),
        default=ProgramStatus.draft,
        nullable=False,
        index=True,
    )
    program_type: Mapped[ProgramType] = mapped_column(
        Enum(ProgramType, name="program_type"),
        default=ProgramType.recorded,
        nullable=False,
    )
    scheduled_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    play_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    favorite_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    genre: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    duration_seconds: Mapped[float | None] = mapped_column(Float, nullable=True)
    waveform_data: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False
    )

    user: Mapped["User"] = relationship(back_populates="programs")  # noqa: F821
    tracks: Mapped[list["ProgramTrack"]] = relationship(
        back_populates="program", cascade="all, delete-orphan", order_by="ProgramTrack.track_order"
    )


class ProgramTrack(Base):
    __tablename__ = "program_tracks"

    id: Mapped[uuid.UUID] = mapped_column(
        GUID, primary_key=True, default=uuid.uuid4
    )
    program_id: Mapped[uuid.UUID] = mapped_column(
        GUID, ForeignKey("programs.id", ondelete="CASCADE"), nullable=False, index=True
    )
    apple_music_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    apple_music_track_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    artist_name: Mapped[str] = mapped_column(String(255), nullable=False)
    artwork_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    play_timing_seconds: Mapped[float] = mapped_column(Float, default=0, nullable=False)
    duration_seconds: Mapped[float | None] = mapped_column(Float, nullable=True)
    track_order: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    program: Mapped["Program"] = relationship(back_populates="tracks")
