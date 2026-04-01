import uuid

import boto3
from botocore.config import Config

from app.config import get_settings

settings = get_settings()


def get_s3_client():
    return boto3.client(
        "s3",
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_REGION,
        config=Config(signature_version="s3v4"),
    )


def generate_presigned_upload_url(
    file_extension: str,
    content_type: str,
    prefix: str = "",
    expires_in: int = 3600,
) -> dict:
    """Generate a presigned URL for uploading a file to S3."""
    s3_client = get_s3_client()
    file_key = f"{prefix}{uuid.uuid4()}.{file_extension}"

    presigned_url = s3_client.generate_presigned_url(
        "put_object",
        Params={
            "Bucket": settings.S3_BUCKET_NAME,
            "Key": file_key,
            "ContentType": content_type,
        },
        ExpiresIn=expires_in,
    )

    file_url = f"https://{settings.S3_BUCKET_NAME}.s3.{settings.AWS_REGION}.amazonaws.com/{file_key}"

    return {
        "upload_url": presigned_url,
        "file_url": file_url,
        "file_key": file_key,
    }


def generate_presigned_audio_upload_url(file_extension: str = "mp3") -> dict:
    content_type_map = {
        "mp3": "audio/mpeg",
        "wav": "audio/wav",
        "m4a": "audio/mp4",
        "aac": "audio/aac",
        "ogg": "audio/ogg",
    }
    content_type = content_type_map.get(file_extension, "audio/mpeg")
    return generate_presigned_upload_url(
        file_extension=file_extension,
        content_type=content_type,
        prefix=settings.S3_AUDIO_PREFIX,
    )


def generate_presigned_image_upload_url(file_extension: str = "jpg") -> dict:
    content_type_map = {
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "webp": "image/webp",
        "gif": "image/gif",
    }
    content_type = content_type_map.get(file_extension, "image/jpeg")
    return generate_presigned_upload_url(
        file_extension=file_extension,
        content_type=content_type,
        prefix=settings.S3_IMAGE_PREFIX,
    )
