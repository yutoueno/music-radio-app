import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.track import (
    AppleMusicResolveRequest,
    AppleMusicTrackInfo,
    TrackCreate,
    TrackResponse,
    TrackUpdate,
)
from app.services.apple_music_service import AppleMusicService
from app.services.program_service import ProgramService

router = APIRouter(prefix="/tracks", tags=["tracks"])


@router.post("", response_model=None, status_code=status.HTTP_201_CREATED)
async def create_track(
    body: TrackCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)

    # Verify program ownership
    program = await service.get_program(body.program_id)
    if not program or program.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "FORBIDDEN", "message": "この番組にトラックを追加する権限がありません"},
        )

    track = await service.create_track(body.model_dump())
    return {"data": TrackResponse.model_validate(track).model_dump()}


@router.get("/program/{program_id}", response_model=None)
async def list_tracks(
    program_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    tracks = await service.list_tracks_for_program(program_id)
    return {"data": [TrackResponse.model_validate(t).model_dump() for t in tracks]}


@router.put("/{track_id}", response_model=None)
async def update_track(
    track_id: uuid.UUID,
    body: TrackUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)

    # Verify ownership via track's program
    track = await service.get_track(track_id)
    if not track:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "トラックが見つかりません"},
        )

    program = await service.get_program(track.program_id)
    if not program or program.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "FORBIDDEN", "message": "このトラックを編集する権限がありません"},
        )

    updated = await service.update_track(track_id, body.model_dump(exclude_unset=True))
    return {"data": TrackResponse.model_validate(updated).model_dump()}


@router.delete("/{track_id}", response_model=None)
async def delete_track(
    track_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)

    track = await service.get_track(track_id)
    if not track:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "トラックが見つかりません"},
        )

    program = await service.get_program(track.program_id)
    if not program or program.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "FORBIDDEN", "message": "このトラックを削除する権限がありません"},
        )

    await service.delete_track(track_id)
    return {"data": {"message": "トラックを削除しました"}}


@router.post("/resolve-apple-music", response_model=None)
async def resolve_apple_music(
    body: AppleMusicResolveRequest,
    current_user: User = Depends(get_current_user),
):
    service = AppleMusicService()
    result = await service.resolve_url(body.url)

    if result is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code": "INVALID_URL",
                "message": "Apple MusicのURLを解析できませんでした",
            },
        )

    return {"data": AppleMusicTrackInfo(**result).model_dump()}
