import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User, UserProfile
from app.schemas.common import PaginationMeta
from app.schemas.program import ProgramResponse
from app.schemas.user import UserProfileResponse, UserProfileUpdate, UserResponse
from app.services.program_service import ProgramService

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=None)
async def get_my_profile(current_user: User = Depends(get_current_user)):
    return {"data": UserResponse.model_validate(current_user).model_dump()}


@router.put("/me", response_model=None)
async def update_my_profile(
    body: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.profile:
        profile = UserProfile(user_id=current_user.id)
        db.add(profile)
        await db.flush()
        await db.refresh(current_user, attribute_names=["profile"])

    update_data = body.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(current_user.profile, key, value)

    await db.flush()
    await db.refresh(current_user, attribute_names=["profile"])

    return {"data": UserResponse.model_validate(current_user).model_dump()}


@router.get("/{user_id}", response_model=None)
async def get_user_profile(
    user_id: uuid.UUID,
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

    profile_data = UserProfileResponse.model_validate(user.profile).model_dump() if user.profile else None
    return {
        "data": {
            "id": str(user.id),
            "nickname": user.profile.nickname if user.profile else "",
            "avatar_url": user.profile.avatar_url if user.profile else None,
            "wallpaper_url": user.profile.wallpaper_url if user.profile else None,
            "message": user.profile.message if user.profile else None,
            "follower_count": user.profile.follower_count if user.profile else 0,
            "profile": profile_data,
        }
    }


@router.get("/{user_id}/programs", response_model=None)
async def get_user_programs(
    user_id: uuid.UUID,
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    programs, total = await service.get_user_programs(user_id, page, per_page)

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
