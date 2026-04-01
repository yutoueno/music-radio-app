from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.dependencies import get_current_user
from app.models.user import User
from app.utils.storage import generate_presigned_audio_upload_url, generate_presigned_image_upload_url

router = APIRouter(prefix="/upload", tags=["upload"])


ALLOWED_AUDIO_EXTENSIONS = {"mp3", "wav", "m4a", "aac", "ogg"}
ALLOWED_IMAGE_EXTENSIONS = {"jpg", "jpeg", "png", "webp", "gif"}


@router.post("/audio", response_model=None, status_code=status.HTTP_201_CREATED)
async def get_audio_upload_url(
    file_extension: str = Query("mp3", description="Audio file extension"),
    current_user: User = Depends(get_current_user),
):
    ext = file_extension.lower().strip(".")
    if ext not in ALLOWED_AUDIO_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code": "INVALID_FILE_TYPE",
                "message": f"許可されていないファイル形式です。許可: {', '.join(ALLOWED_AUDIO_EXTENSIONS)}",
            },
        )

    try:
        result = generate_presigned_audio_upload_url(ext)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"code": "UPLOAD_ERROR", "message": "アップロードURLの生成に失敗しました"},
        )

    return {"data": result}


@router.post("/image", response_model=None, status_code=status.HTTP_201_CREATED)
async def get_image_upload_url(
    file_extension: str = Query("jpg", description="Image file extension"),
    current_user: User = Depends(get_current_user),
):
    ext = file_extension.lower().strip(".")
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "code": "INVALID_FILE_TYPE",
                "message": f"許可されていないファイル形式です。許可: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}",
            },
        )

    try:
        result = generate_presigned_image_upload_url(ext)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"code": "UPLOAD_ERROR", "message": "アップロードURLの生成に失敗しました"},
        )

    return {"data": result}
