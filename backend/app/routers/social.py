import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import PaginationMeta
from app.schemas.social import FavoriteCreate, FavoriteResponse, FollowCreate, FollowResponse
from app.services.social_service import SocialService

router = APIRouter(prefix="/social", tags=["social"])


# --- Favorites ---


@router.post("/favorites", response_model=None, status_code=status.HTTP_201_CREATED)
async def add_favorite(
    body: FavoriteCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    result = await service.add_favorite(current_user.id, body.program_id)

    if isinstance(result, dict) and "error" in result:
        status_code = (
            status.HTTP_404_NOT_FOUND
            if result["error"] == "NOT_FOUND"
            else status.HTTP_409_CONFLICT
        )
        raise HTTPException(
            status_code=status_code,
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": FavoriteResponse.model_validate(result).model_dump()}


@router.delete("/favorites/{program_id}", response_model=None)
async def remove_favorite(
    program_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    removed = await service.remove_favorite(current_user.id, program_id)
    if not removed:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "お気に入りが見つかりません"},
        )
    return {"data": {"message": "お気に入りを解除しました"}}


@router.get("/favorites", response_model=None)
async def get_my_favorites(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    favorites, total = await service.get_user_favorites(current_user.id, page, per_page)

    return {
        "data": [FavoriteResponse.model_validate(f).model_dump() for f in favorites],
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


# --- Follows ---


@router.post("/follows", response_model=None, status_code=status.HTTP_201_CREATED)
async def follow_user(
    body: FollowCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    result = await service.follow_user(current_user.id, body.following_id)

    if isinstance(result, dict) and "error" in result:
        code_map = {
            "NOT_FOUND": status.HTTP_404_NOT_FOUND,
            "ALREADY_EXISTS": status.HTTP_409_CONFLICT,
            "INVALID_OPERATION": status.HTTP_400_BAD_REQUEST,
        }
        raise HTTPException(
            status_code=code_map.get(result["error"], status.HTTP_400_BAD_REQUEST),
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": FollowResponse.model_validate(result).model_dump()}


@router.delete("/follows/{following_id}", response_model=None)
async def unfollow_user(
    following_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    removed = await service.unfollow_user(current_user.id, following_id)
    if not removed:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "フォローが見つかりません"},
        )
    return {"data": {"message": "フォローを解除しました"}}


@router.get("/follows", response_model=None)
async def get_my_follows(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    follows, total = await service.get_user_follows(current_user.id, page, per_page)

    return {
        "data": [FollowResponse.model_validate(f).model_dump() for f in follows],
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.get("/followers", response_model=None)
async def get_my_followers(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SocialService(db)
    followers, total = await service.get_user_followers(current_user.id, page, per_page)

    return {
        "data": [FollowResponse.model_validate(f).model_dump() for f in followers],
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }
