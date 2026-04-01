import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_admin_user, get_current_user_optional
from app.models.inquiry import Inquiry, InquiryStatus
from app.models.user import User
from app.schemas.common import PaginationMeta
from app.schemas.inquiry import InquiryAdminUpdate, InquiryCreate, InquiryResponse

router = APIRouter(tags=["inquiries"])


# --- Public ---


@router.post("/inquiries", response_model=None, status_code=status.HTTP_201_CREATED)
async def create_inquiry(
    body: InquiryCreate,
    current_user: User | None = Depends(get_current_user_optional),
    db: AsyncSession = Depends(get_db),
):
    inquiry = Inquiry(
        email=body.email,
        subject=body.subject,
        body=body.body,
        user_id=current_user.id if current_user else None,
    )
    db.add(inquiry)
    await db.flush()
    await db.refresh(inquiry)

    return {"data": InquiryResponse.model_validate(inquiry).model_dump()}


# --- Admin ---


@router.get("/admin/inquiries", response_model=None)
async def list_inquiries(
    page: int = Query(1, ge=1),
    per_page: int = Query(30, ge=1, le=100),
    status_filter: str | None = Query(None, alias="status"),
    search: str | None = Query(None),
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(Inquiry)

    if status_filter:
        query = query.where(Inquiry.status == InquiryStatus(status_filter))

    if search:
        pattern = f"%{search}%"
        query = query.where(
            or_(
                Inquiry.subject.ilike(pattern),
                Inquiry.email.ilike(pattern),
                Inquiry.body.ilike(pattern),
            )
        )

    count_query = select(func.count()).select_from(query.subquery())
    count_result = await db.execute(count_query)
    total = count_result.scalar() or 0

    query = query.order_by(Inquiry.created_at.desc())
    query = query.offset((page - 1) * per_page).limit(per_page)
    result = await db.execute(query)
    inquiries = list(result.scalars().all())

    return {
        "data": [InquiryResponse.model_validate(i).model_dump() for i in inquiries],
        "meta": PaginationMeta(
            page=page,
            per_page=per_page,
            total=total,
            has_next=(page * per_page) < total,
        ).model_dump(),
    }


@router.get("/admin/inquiries/{inquiry_id}", response_model=None)
async def get_inquiry(
    inquiry_id: uuid.UUID,
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Inquiry).where(Inquiry.id == inquiry_id))
    inquiry = result.scalar_one_or_none()
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "お問い合わせが見つかりません"},
        )

    return {"data": InquiryResponse.model_validate(inquiry).model_dump()}


@router.patch("/admin/inquiries/{inquiry_id}", response_model=None)
async def update_inquiry(
    inquiry_id: uuid.UUID,
    body: InquiryAdminUpdate,
    admin: User = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Inquiry).where(Inquiry.id == inquiry_id))
    inquiry = result.scalar_one_or_none()
    if not inquiry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={"code": "NOT_FOUND", "message": "お問い合わせが見つかりません"},
        )

    if body.status is not None:
        inquiry.status = body.status
    if body.admin_note is not None:
        inquiry.admin_note = body.admin_note

    await db.flush()
    await db.refresh(inquiry)

    return {"data": InquiryResponse.model_validate(inquiry).model_dump()}
