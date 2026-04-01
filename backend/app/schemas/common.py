from typing import Any, Generic, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class PaginationMeta(BaseModel):
    page: int
    per_page: int
    total: int
    has_next: bool


class PaginatedResponse(BaseModel, Generic[T]):
    data: list[Any]
    meta: PaginationMeta


class DataResponse(BaseModel):
    data: Any


class ErrorDetail(BaseModel):
    code: str
    message: str


class ErrorResponse(BaseModel):
    error: ErrorDetail


class MessageResponse(BaseModel):
    data: dict[str, str]
