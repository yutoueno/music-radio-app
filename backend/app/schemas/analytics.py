import uuid
from datetime import date

from pydantic import BaseModel


class AnalyticsOverview(BaseModel):
    total_plays: int = 0
    total_favorites: int = 0
    total_followers: int = 0
    total_programs: int = 0


class ProgramStats(BaseModel):
    program_id: uuid.UUID
    title: str
    play_count: int = 0
    favorite_count: int = 0
    avg_listen_duration: float | None = None


class DailyPlayTrend(BaseModel):
    date: date
    count: int = 0


class TopTrack(BaseModel):
    apple_music_track_id: str
    title: str
    artist_name: str
    artwork_url: str | None = None
    total_appearances: int = 0


class AnalyticsOverviewResponse(BaseModel):
    data: AnalyticsOverview


class ProgramStatsResponse(BaseModel):
    data: list[ProgramStats]


class PlayTrendsResponse(BaseModel):
    data: list[DailyPlayTrend]


class TopTracksResponse(BaseModel):
    data: list[TopTrack]
