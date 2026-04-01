from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/music_radio"

    # JWT
    SECRET_KEY: str = "change-me-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # AWS S3
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_REGION: str = "ap-northeast-1"
    S3_BUCKET_NAME: str = "music-radio-uploads"
    S3_AUDIO_PREFIX: str = "audio/"
    S3_IMAGE_PREFIX: str = "images/"

    # Apple Music
    APPLE_MUSIC_KEY_ID: str = ""
    APPLE_MUSIC_TEAM_ID: str = ""
    APPLE_MUSIC_PRIVATE_KEY_PATH: str = "./AuthKey.p8"

    # APNs Push Notifications
    APNS_KEY_ID: str = ""
    APNS_TEAM_ID: str = ""
    APNS_BUNDLE_ID: str = ""
    APNS_PRIVATE_KEY_PATH: str = "./APNsAuthKey.p8"
    APNS_USE_SANDBOX: bool = True

    # Email / SMTP
    SMTP_HOST: str = "smtp.example.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    FRONTEND_URL: str = "http://localhost:3000"

    # Web / Share
    WEB_BASE_URL: str = "https://yourapp.com"

    # Pagination
    DEFAULT_PAGE_SIZE: int = 30

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache()
def get_settings() -> Settings:
    return Settings()
