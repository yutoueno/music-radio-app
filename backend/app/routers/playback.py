import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.playback import PlaybackSession, TrackPlay
from app.models.program import Program, ProgramTrack
from app.models.user import User
from app.schemas.playback import (
    AudioStreamResponse,
    PlaybackHistoryItem,
    PlaybackProgressUpdate,
    PlaybackSessionResponse,
    TrackPlayCreate,
)
from app.utils.storage import generate_presigned_get_url
from app.utils.waveform import generate_waveform_data

router = APIRouter(prefix="/playback", tags=["playback"])


async def _get_program_or_404(db: AsyncSession, program_id: uuid.UUID) -> Program:
    result = await db.execute(select(Program).where(Program.id == program_id))
    program = result.scalar_one_or_none()
    if not program:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "番組が見つかりません"},
        )
    return program


@router.get("/stream/{program_id}", response_model=None)
async def get_stream(
    program_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return a presigned S3 URL for streaming program audio + metadata."""
    program = await _get_program_or_404(db, program_id)

    if not program.audio_url:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NO_AUDIO", "message": "この番組には音声ファイルがありません"},
        )

    # Generate presigned GET URL from the stored audio_url
    stream_url = generate_presigned_get_url(program.audio_url)

    # Use existing waveform data or generate demo data
    waveform = program.waveform_data
    if waveform is None:
        waveform = generate_waveform_data(seed=hash(str(program.id)) % (2**31))

    return {
        "data": AudioStreamResponse(
            stream_url=stream_url,
            expires_in=3600,
            program_id=program.id,
            duration_seconds=program.duration_seconds,
            waveform_data=waveform,
        ).model_dump()
    }


@router.post("/session/{program_id}", response_model=None, status_code=status.HTTP_200_OK)
async def create_or_resume_session(
    program_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new playback session or return an existing incomplete one for resume."""
    await _get_program_or_404(db, program_id)

    # Look for existing incomplete session
    result = await db.execute(
        select(PlaybackSession).where(
            PlaybackSession.user_id == current_user.id,
            PlaybackSession.program_id == program_id,
            PlaybackSession.is_completed == False,  # noqa: E712
        )
    )
    session = result.scalar_one_or_none()

    if session:
        return {"data": PlaybackSessionResponse.model_validate(session).model_dump()}

    # Create new session
    session = PlaybackSession(
        user_id=current_user.id,
        program_id=program_id,
        current_position_seconds=0,
        is_completed=False,
    )
    db.add(session)
    await db.flush()
    await db.refresh(session)

    return {"data": PlaybackSessionResponse.model_validate(session).model_dump()}


@router.put("/session/{program_id}/progress", response_model=None)
async def update_progress(
    program_id: uuid.UUID,
    body: PlaybackProgressUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update playback position for the current session."""
    result = await db.execute(
        select(PlaybackSession).where(
            PlaybackSession.user_id == current_user.id,
            PlaybackSession.program_id == program_id,
            PlaybackSession.is_completed == False,  # noqa: E712
        )
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "再生セッションが見つかりません"},
        )

    session.current_position_seconds = body.current_position_seconds
    if body.is_completed is not None:
        session.is_completed = body.is_completed

    await db.flush()
    await db.refresh(session)

    return {"data": PlaybackSessionResponse.model_validate(session).model_dump()}


@router.get("/session/{program_id}", response_model=None)
async def get_session(
    program_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get current playback session for resume."""
    result = await db.execute(
        select(PlaybackSession).where(
            PlaybackSession.user_id == current_user.id,
            PlaybackSession.program_id == program_id,
            PlaybackSession.is_completed == False,  # noqa: E712
        )
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "再生セッションが見つかりません"},
        )

    return {"data": PlaybackSessionResponse.model_validate(session).model_dump()}


@router.post("/track-play", response_model=None, status_code=status.HTTP_201_CREATED)
async def record_track_play(
    body: TrackPlayCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Record that a track was played during a program."""
    # Verify program exists
    await _get_program_or_404(db, body.program_id)

    # Verify track exists
    result = await db.execute(
        select(ProgramTrack).where(ProgramTrack.id == body.track_id)
    )
    track = result.scalar_one_or_none()
    if not track:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "トラックが見つかりません"},
        )

    track_play = TrackPlay(
        program_id=body.program_id,
        track_id=body.track_id,
        user_id=current_user.id,
    )
    db.add(track_play)
    await db.flush()

    return {"data": {"message": "トラック再生を記録しました"}}


@router.get("/history", response_model=None)
async def get_playback_history(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get user's recently played programs with last position."""
    # Get the most recent session per program using a subquery
    from sqlalchemy import desc, func

    # Get latest sessions ordered by updated_at
    stmt = (
        select(PlaybackSession)
        .where(PlaybackSession.user_id == current_user.id)
        .order_by(desc(PlaybackSession.updated_at))
        .offset((page - 1) * per_page)
        .limit(per_page)
    )
    result = await db.execute(stmt)
    sessions = result.scalars().all()

    # Count total
    count_stmt = (
        select(func.count())
        .select_from(PlaybackSession)
        .where(PlaybackSession.user_id == current_user.id)
    )
    total_result = await db.execute(count_stmt)
    total = total_result.scalar() or 0

    # Build response with program info
    items = []
    for session in sessions:
        prog_result = await db.execute(
            select(Program).where(Program.id == session.program_id)
        )
        program = prog_result.scalar_one_or_none()
        if program:
            items.append(
                PlaybackHistoryItem(
                    program_id=program.id,
                    program_title=program.title,
                    program_thumbnail_url=program.thumbnail_url,
                    current_position_seconds=session.current_position_seconds,
                    is_completed=session.is_completed,
                    duration_seconds=program.duration_seconds,
                    updated_at=session.updated_at,
                ).model_dump()
            )

    return {
        "data": items,
        "meta": {
            "page": page,
            "per_page": per_page,
            "total": total,
            "has_next": (page * per_page) < total,
        },
    }
