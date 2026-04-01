from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.analytics import (
    AnalyticsOverview,
    DailyPlayTrend,
    ProgramStats,
    TopTrack,
)
from app.services.analytics_service import AnalyticsService

router = APIRouter(prefix="/analytics", tags=["analytics"])


@router.get("/overview", response_model=None)
async def get_analytics_overview(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = AnalyticsService(db)
    overview = await service.get_overview(current_user.id)
    return {"data": AnalyticsOverview(**overview).model_dump()}


@router.get("/programs", response_model=None)
async def get_program_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = AnalyticsService(db)
    stats = await service.get_program_stats(current_user.id)
    return {"data": [ProgramStats(**s).model_dump() for s in stats]}


@router.get("/play-trends", response_model=None)
async def get_play_trends(
    days: int = Query(30, ge=1, le=365),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = AnalyticsService(db)
    trends = await service.get_play_trends(current_user.id, days)
    return {"data": [DailyPlayTrend(**t).model_dump() for t in trends]}


@router.get("/top-tracks", response_model=None)
async def get_top_tracks(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = AnalyticsService(db)
    tracks = await service.get_top_tracks(current_user.id)
    return {"data": [TopTrack(**t).model_dump() for t in tracks]}
