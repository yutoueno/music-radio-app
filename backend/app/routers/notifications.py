import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import PaginationMeta
from app.schemas.notification import (
    DeviceTokenRegister,
    DeviceTokenResponse,
    NotificationResponse,
)
from app.services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.post("/device-token", response_model=None, status_code=status.HTTP_201_CREATED)
async def register_device_token(
    body: DeviceTokenRegister,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Register an APNs device token for push notifications."""
    service = NotificationService(db)
    token = await service.register_device_token(
        current_user.id, body.device_token, body.platform
    )
    return {"data": DeviceTokenResponse.model_validate(token).model_dump()}


@router.get("", response_model=None)
async def get_notifications(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get the current user's notifications (paginated)."""
    service = NotificationService(db)
    notifications, total = await service.get_notifications(
        current_user.id, page, per_page
    )

    return {
        "data": [
            NotificationResponse.model_validate(n).model_dump()
            for n in notifications
        ],
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.get("/unread-count", response_model=None)
async def get_unread_count(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get the count of unread notifications."""
    service = NotificationService(db)
    count = await service.get_unread_count(current_user.id)
    return {"data": {"unread_count": count}}


@router.put("/{notification_id}/read", response_model=None)
async def mark_notification_read(
    notification_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Mark a single notification as read."""
    service = NotificationService(db)
    success = await service.mark_as_read(notification_id, current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "通知が見つかりません"},
        )
    return {"data": {"message": "通知を既読にしました"}}


@router.post("/read-all", response_model=None)
async def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Mark all of the current user's notifications as read."""
    service = NotificationService(db)
    count = await service.mark_all_as_read(current_user.id)
    return {"data": {"message": f"{count}件の通知を既読にしました", "count": count}}
