import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, get_current_user_optional
from app.models.user import User
from app.schemas.common import PaginationMeta
from app.schemas.program import (
    ProgramCreate,
    ProgramFromTemplateRequest,
    ProgramResponse,
    ProgramUpdate,
)
from app.schemas.social import PlayRecordRequest
from app.services.notification_service import NotificationService
from app.services.program_service import ProgramService
from app.services.template_service import get_template, list_templates_summary

router = APIRouter(prefix="/programs", tags=["programs"])


def _program_to_response(program, nickname: str | None = None) -> dict:
    resp = ProgramResponse.model_validate(program).model_dump()
    resp["user_nickname"] = nickname
    return resp


@router.post("", response_model=None, status_code=status.HTTP_201_CREATED)
async def create_program(
    body: ProgramCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    program = await service.create_program(current_user.id, body.model_dump(exclude_unset=True))
    nickname = current_user.profile.nickname if current_user.profile else None
    return {"data": _program_to_response(program, nickname)}


@router.get("/recommended", response_model=None)
async def get_recommended_programs(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    programs, total = await service.get_recommended_programs(page, per_page)

    items = []
    for p in programs:
        nickname = await service.get_program_with_user_nickname(p)
        items.append(_program_to_response(p, nickname))

    return {
        "data": items,
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.get("", response_model=None)
async def list_programs(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    status: str | None = Query(None),
    user_id: uuid.UUID | None = Query(None),
    q: str | None = Query(None, description="Search term for title/description"),
    genre: str | None = Query(None, description="Filter by genre"),
    sort_by: str | None = Query(None, description="Sort field: play_count, created_at, favorite_count"),
    sort_order: str | None = Query(None, description="Sort order: asc, desc"),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    from app.models.program import ProgramStatus

    prog_status = ProgramStatus(status) if status else ProgramStatus.published
    programs, total = await service.list_programs(
        page, per_page, prog_status, user_id,
        q=q, genre=genre, sort_by=sort_by, sort_order=sort_order,
    )

    items = []
    for p in programs:
        nickname = await service.get_program_with_user_nickname(p)
        items.append(_program_to_response(p, nickname))

    return {
        "data": items,
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.get("/genres", response_model=None)
async def get_genres(
    db: AsyncSession = Depends(get_db),
):
    """Return a list of available genres with program counts."""
    service = ProgramService(db)
    genres = await service.get_genres_with_counts()
    return {"data": genres}


@router.get("/templates", response_model=None)
async def list_program_templates():
    """List all available program templates for onboarding."""
    templates = list_templates_summary()
    return {"data": templates}


@router.post("/from-template", response_model=None, status_code=status.HTTP_201_CREATED)
async def create_program_from_template(
    body: ProgramFromTemplateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a program from a predefined template (for onboarding new broadcasters)."""
    template = get_template(body.template_name)
    if not template:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "TEMPLATE_NOT_FOUND",
                "message": f"テンプレート '{body.template_name}' が見つかりません",
            },
        )

    service = ProgramService(db)

    # Create the program from the template
    program_data = {
        "title": template.title,
        "description": template.description,
        "genre": template.genre,
        "status": "draft",
        "program_type": "recorded",
        "duration_seconds": template.duration_seconds,
    }
    program = await service.create_program(current_user.id, program_data)

    # Create tracks from the template
    for track_tmpl in template.tracks:
        track_data = {
            "program_id": program.id,
            "apple_music_track_id": track_tmpl.apple_music_track_id,
            "title": track_tmpl.title,
            "artist_name": track_tmpl.artist_name,
            "artwork_url": track_tmpl.artwork_url,
            "play_timing_seconds": track_tmpl.play_timing_seconds,
            "duration_seconds": track_tmpl.duration_seconds,
            "track_order": track_tmpl.track_order,
        }
        await service.create_track(track_data)

    # Refresh to get tracks
    program = await service.get_program(program.id)

    nickname = current_user.profile.nickname if current_user.profile else None
    return {
        "data": {
            "message": f"テンプレート '{template.title}' から番組を作成しました",
            "program": _program_to_response(program, nickname),
        }
    }


@router.get("/{program_id}", response_model=None)
async def get_program(
    program_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    program = await service.get_program(program_id)
    if not program:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "番組が見つかりません"},
        )
    nickname = await service.get_program_with_user_nickname(program)
    return {"data": _program_to_response(program, nickname)}


@router.put("/{program_id}", response_model=None)
async def update_program(
    program_id: uuid.UUID,
    body: ProgramUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)

    # Check previous status to detect publish event
    old_program = await service.get_program(program_id)
    old_status = old_program.status if old_program else None

    program = await service.update_program(
        program_id, current_user.id, body.model_dump(exclude_unset=True)
    )
    if not program:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "番組が見つからないか権限がありません"},
        )

    # Trigger notifications if program was just published
    from app.models.program import ProgramStatus as PS
    if old_status != PS.published and program.status == PS.published:
        notification_service = NotificationService(db)
        await notification_service.notify_followers_new_program(
            broadcaster_id=current_user.id,
            program_id=program.id,
            program_title=program.title,
        )

    nickname = current_user.profile.nickname if current_user.profile else None
    return {"data": _program_to_response(program, nickname)}


@router.delete("/{program_id}", response_model=None, status_code=status.HTTP_200_OK)
async def delete_program(
    program_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    deleted = await service.delete_program(program_id, current_user.id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "番組が見つからないか権限がありません"},
        )
    return {"data": {"message": "番組を削除しました"}}


@router.post("/{program_id}/play", response_model=None, status_code=status.HTTP_201_CREATED)
async def record_play(
    program_id: uuid.UUID,
    body: PlayRecordRequest | None = None,
    current_user: User | None = Depends(get_current_user_optional),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    program = await service.get_program(program_id)
    if not program:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "番組が見つかりません"},
        )
    user_id = current_user.id if current_user else None
    duration = body.duration_seconds if body else None
    await service.record_play(program_id, user_id, duration)
    return {"data": {"message": "再生を記録しました"}}
