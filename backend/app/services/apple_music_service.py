from app.utils.apple_music import resolve_apple_music_url, extract_track_id_from_url


class AppleMusicService:
    async def resolve_url(self, url: str) -> dict | None:
        """Resolve an Apple Music URL to track metadata."""
        return await resolve_apple_music_url(url)

    def extract_track_id(self, url: str) -> tuple[str, str] | None:
        """Extract storefront and track ID from URL."""
        return extract_track_id_from_url(url)
