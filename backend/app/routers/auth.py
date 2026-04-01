from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.auth import (
    LoginRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    RefreshRequest,
    SignupRequest,
    TokenResponse,
    VerifyEmailRequest,
)
from app.schemas.common import ErrorResponse, MessageResponse
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", response_model=None, status_code=status.HTTP_201_CREATED)
async def signup(body: SignupRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.signup(body.email, body.password, body.nickname)

    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": TokenResponse(**result).model_dump()}


@router.post("/login", response_model=None)
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.login(body.email, body.password)

    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": TokenResponse(**result).model_dump()}


@router.post("/refresh", response_model=None)
async def refresh(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.refresh_tokens(body.refresh_token)

    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": TokenResponse(**result).model_dump()}


@router.post("/verify-email", response_model=None)
async def verify_email(body: VerifyEmailRequest, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.verify_email(body.token)

    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": {"message": result["message"]}}


@router.post("/request-password-reset", response_model=None)
async def request_password_reset(
    body: PasswordResetRequest, db: AsyncSession = Depends(get_db)
):
    service = AuthService(db)
    result = await service.request_password_reset(body.email)
    return {"data": {"message": result["message"]}}


@router.post("/reset-password", response_model=None)
async def reset_password(body: PasswordResetConfirm, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    result = await service.reset_password(body.token, body.new_password)

    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": result["error"], "message": result["message"]},
        )

    return {"data": {"message": result["message"]}}
