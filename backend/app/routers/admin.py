import uuid

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.dependencies import get_admin_user
from app.models.play_log import ProgramPlay
from app.models.program import Program, ProgramStatus
from app.models.social import Favorite, Follow
from app.models.user import User
from app.schemas.common import PaginationMeta
from app.schemas.program import AdminProgramStatusUpdate, ProgramResponse
from app.schemas.user import AdminUserResponse, AdminUserStatusUpdate
from app.services.program_service import ProgramService

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/users", response_model=None)
async def list_users(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(User).options(selectinload(User.profile))

    count_result = await db.execute(select(func.count()).select_from(User))
    total = count_result.scalar() or 0

    query = query.order_by(User.created_at.desc())
    query = query.offset((page - 1) * per_page).limit(per_page)
    result = await db.execute(query)
    users = list(result.scalars().all())

    return {
        "data": [AdminUserResponse.model_validate(u).model_dump() for u in users],
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.patch("/users/{user_id}", response_model=None)
async def update_user_status(
    user_id: uuid.UUID,
    body: AdminUserStatusUpdate,
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User).options(selectinload(User.profile)).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "ユーザーが見つかりません"},
        )

    if body.is_active is not None:
        user.is_active = body.is_active
    if body.is_admin is not None:
        user.is_admin = body.is_admin

    await db.flush()
    await db.refresh(user)
    # Re-load with profile eagerly loaded
    result2 = await db.execute(
        select(User).options(selectinload(User.profile)).where(User.id == user_id)
    )
    user = result2.scalar_one()

    return {"data": AdminUserResponse.model_validate(user).model_dump()}


@router.get("/broadcasters/{user_id}", response_model=None)
async def get_broadcaster_detail(
    user_id: uuid.UUID,
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """Get detailed broadcaster info including their programs and stats."""
    # Fetch user with profile
    result = await db.execute(
        select(User).options(selectinload(User.profile)).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "ユーザーが見つかりません"},
        )

    # Fetch programs with tracks
    programs_result = await db.execute(
        select(Program)
        .options(selectinload(Program.tracks))
        .where(Program.user_id == user_id)
        .order_by(Program.created_at.desc())
    )
    programs = list(programs_result.scalars().all())

    # Aggregate stats
    total_plays = sum(p.play_count for p in programs)
    total_favorites = sum(p.favorite_count for p in programs)
    total_programs = len(programs)

    # Following count (users this broadcaster follows)
    following_count_result = await db.execute(
        select(func.count()).select_from(Follow).where(Follow.follower_id == user_id)
    )
    following_count = following_count_result.scalar() or 0

    # Follower count from profile
    follower_count = user.profile.follower_count if user.profile else 0

    # Build profile data
    profile_data = None
    if user.profile:
        profile_data = {
            "id": str(user.profile.id),
            "user_id": str(user.profile.user_id),
            "nickname": user.profile.nickname,
            "avatar_url": user.profile.avatar_url,
            "wallpaper_url": user.profile.wallpaper_url,
            "message": user.profile.message,
            "follower_count": follower_count,
            "following_count": following_count,
            "created_at": user.profile.created_at.isoformat(),
            "updated_at": user.profile.updated_at.isoformat(),
        }

    # Build programs list
    programs_data = []
    for p in programs:
        programs_data.append({
            "id": str(p.id),
            "title": p.title,
            "status": p.status.value,
            "play_count": p.play_count,
            "favorite_count": p.favorite_count,
            "genre": p.genre,
            "duration_seconds": p.duration_seconds,
            "track_count": len(p.tracks),
            "created_at": p.created_at.isoformat(),
        })

    return {
        "data": {
            "id": str(user.id),
            "email": user.email,
            "is_active": user.is_active,
            "is_admin": user.is_admin,
            "email_verified": user.email_verified,
            "profile": profile_data,
            "programs": programs_data,
            "stats": {
                "total_programs": total_programs,
                "total_plays": total_plays,
                "total_favorites": total_favorites,
                "follower_count": follower_count,
                "following_count": following_count,
            },
            "created_at": user.created_at.isoformat(),
            "updated_at": user.updated_at.isoformat(),
        }
    }


@router.get("/programs", response_model=None)
async def list_all_programs(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    status_filter: str | None = Query(None, alias="status"),
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    prog_status = ProgramStatus(status_filter) if status_filter else None
    programs, total = await service.admin_list_programs(page, per_page, prog_status)

    items = []
    for p in programs:
        nickname = await service.get_program_with_user_nickname(p)
        resp = ProgramResponse.model_validate(p).model_dump()
        resp["user_nickname"] = nickname
        items.append(resp)

    return {
        "data": items,
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.patch("/programs/{program_id}", response_model=None)
async def update_program_status(
    program_id: uuid.UUID,
    body: AdminProgramStatusUpdate,
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    program = await service.admin_update_status(program_id, body.status)
    if not program:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "番組が見つかりません"},
        )

    nickname = await service.get_program_with_user_nickname(program)
    resp = ProgramResponse.model_validate(program).model_dump()
    resp["user_nickname"] = nickname
    return {"data": resp}


@router.get("/dashboard", response_model=None)
async def get_dashboard_stats(
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    # Total users
    users_count = (await db.execute(select(func.count()).select_from(User))).scalar() or 0

    # Total programs
    programs_count = (await db.execute(select(func.count()).select_from(Program))).scalar() or 0

    # Published programs
    published_count = (
        await db.execute(
            select(func.count())
            .select_from(Program)
            .where(Program.status == ProgramStatus.published)
        )
    ).scalar() or 0

    # Total plays
    plays_count = (await db.execute(select(func.count()).select_from(ProgramPlay))).scalar() or 0

    # Total favorites
    favorites_count = (await db.execute(select(func.count()).select_from(Favorite))).scalar() or 0

    # Total follows
    follows_count = (await db.execute(select(func.count()).select_from(Follow))).scalar() or 0

    # Active users
    active_users_count = (
        await db.execute(
            select(func.count())
            .select_from(User)
            .where(User.is_active == True)  # noqa: E712
        )
    ).scalar() or 0

    # Draft programs
    draft_count = (
        await db.execute(
            select(func.count())
            .select_from(Program)
            .where(Program.status == ProgramStatus.draft)
        )
    ).scalar() or 0

    # Archived programs
    archived_count = (
        await db.execute(
            select(func.count())
            .select_from(Program)
            .where(Program.status == ProgramStatus.archived)
        )
    ).scalar() or 0

    return {
        "data": {
            "total_users": users_count,
            "active_users": active_users_count,
            "total_programs": programs_count,
            "published_programs": published_count,
            "draft_programs": draft_count,
            "archived_programs": archived_count,
            "total_plays": plays_count,
            "total_favorites": favorites_count,
            "total_follows": follows_count,
        }
    }


@router.get("/reports", response_model=None)
async def get_reports(
    days: int = Query(30, ge=1, le=365, description="Number of days for play trend"),
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """Get play count trends and popular programs from real data."""
    # Top programs by plays
    top_by_plays_result = await db.execute(
        select(Program)
        .where(Program.status == ProgramStatus.published)
        .order_by(Program.play_count.desc())
        .limit(10)
    )
    top_by_plays = list(top_by_plays_result.scalars().all())

    # Top programs by favorites
    top_by_favorites_result = await db.execute(
        select(Program)
        .where(Program.status == ProgramStatus.published)
        .order_by(Program.favorite_count.desc())
        .limit(10)
    )
    top_by_favorites = list(top_by_favorites_result.scalars().all())

    # Play count trends (daily counts for the last N days)
    since = datetime.now(timezone.utc) - timedelta(days=days)
    # Use func.date() for cross-database compatibility (works on both PostgreSQL and SQLite)
    play_date = func.date(ProgramPlay.created_at).label("play_date")
    trend_result = await db.execute(
        select(play_date, func.count().label("count"))
        .where(ProgramPlay.created_at >= since)
        .group_by(play_date)
        .order_by(play_date)
    )
    play_trends = [
        {"date": str(row.play_date), "count": row.count}
        for row in trend_result.all()
    ]

    # New users trend (daily counts for the last N days)
    user_date = func.date(User.created_at).label("user_date")
    user_trend_result = await db.execute(
        select(user_date, func.count().label("count"))
        .where(User.created_at >= since)
        .group_by(user_date)
        .order_by(user_date)
    )
    user_trends = [
        {"date": str(row.user_date), "count": row.count}
        for row in user_trend_result.all()
    ]

    return {
        "data": {
            "top_programs_by_plays": [
                {
                    "id": str(p.id),
                    "title": p.title,
                    "play_count": p.play_count,
                    "user_id": str(p.user_id),
                }
                for p in top_by_plays
            ],
            "top_programs_by_favorites": [
                {
                    "id": str(p.id),
                    "title": p.title,
                    "favorite_count": p.favorite_count,
                    "user_id": str(p.user_id),
                }
                for p in top_by_favorites
            ],
            "play_count_trends": play_trends,
            "new_user_trends": user_trends,
        }
    }


@router.get("/analytics/daily", response_model=None)
async def get_daily_analytics(
    days: int = Query(30, ge=1, le=365, description="Number of days to look back"),
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """Get daily play counts for the specified period with summary stats."""
    now = datetime.now(timezone.utc)
    since = now - timedelta(days=days)

    # Daily play counts
    play_date = func.date(ProgramPlay.created_at).label("play_date")
    daily_result = await db.execute(
        select(play_date, func.count().label("count"))
        .where(ProgramPlay.created_at >= since)
        .group_by(play_date)
        .order_by(play_date)
    )
    daily_plays = [
        {"date": str(row.play_date), "count": row.count}
        for row in daily_result.all()
    ]

    # Total plays this period
    total_plays_result = await db.execute(
        select(func.count())
        .select_from(ProgramPlay)
        .where(ProgramPlay.created_at >= since)
    )
    total_plays = total_plays_result.scalar() or 0

    # Total plays in the previous period (for growth calculation)
    previous_since = since - timedelta(days=days)
    previous_plays_result = await db.execute(
        select(func.count())
        .select_from(ProgramPlay)
        .where(
            ProgramPlay.created_at >= previous_since,
            ProgramPlay.created_at < since,
        )
    )
    previous_plays = previous_plays_result.scalar() or 0

    # Growth percentage
    if previous_plays > 0:
        growth_percent = ((total_plays - previous_plays) / previous_plays) * 100
    else:
        growth_percent = 100.0 if total_plays > 0 else 0.0

    # Most active day
    most_active_day = None
    most_active_count = 0
    for day in daily_plays:
        if day["count"] > most_active_count:
            most_active_count = day["count"]
            most_active_day = day["date"]

    return {
        "data": {
            "daily_plays": daily_plays,
            "summary": {
                "total_plays": total_plays,
                "growth_percent": round(growth_percent, 1),
                "most_active_day": most_active_day,
                "most_active_count": most_active_count,
                "period_days": days,
                "period_start": since.strftime("%Y-%m-%d"),
                "period_end": now.strftime("%Y-%m-%d"),
            },
        }
    }
