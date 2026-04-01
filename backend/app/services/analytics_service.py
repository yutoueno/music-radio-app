import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import Date, String, cast, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.play_log import ProgramPlay
from app.models.program import Program, ProgramTrack
from app.models.social import Favorite, Follow


class AnalyticsService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_overview(self, user_id: uuid.UUID) -> dict:
        """Get broadcaster's overview stats."""
        # Total programs
        total_programs = (
            await self.db.execute(
                select(func.count()).select_from(Program).where(Program.user_id == user_id)
            )
        ).scalar() or 0

        # Total plays across all programs
        total_plays = (
            await self.db.execute(
                select(func.coalesce(func.sum(Program.play_count), 0)).where(
                    Program.user_id == user_id
                )
            )
        ).scalar() or 0

        # Total favorites across all programs
        total_favorites = (
            await self.db.execute(
                select(func.coalesce(func.sum(Program.favorite_count), 0)).where(
                    Program.user_id == user_id
                )
            )
        ).scalar() or 0

        # Total followers
        total_followers = (
            await self.db.execute(
                select(func.count()).select_from(Follow).where(
                    Follow.following_id == user_id
                )
            )
        ).scalar() or 0

        return {
            "total_plays": int(total_plays),
            "total_favorites": int(total_favorites),
            "total_followers": total_followers,
            "total_programs": total_programs,
        }

    async def get_program_stats(self, user_id: uuid.UUID) -> list[dict]:
        """Get per-program stats for the broadcaster."""
        # Get all programs for this user
        programs_result = await self.db.execute(
            select(Program).where(Program.user_id == user_id).order_by(
                Program.play_count.desc()
            )
        )
        programs = list(programs_result.scalars().all())

        stats = []
        for program in programs:
            # Average listen duration from program_plays
            avg_duration = (
                await self.db.execute(
                    select(func.avg(ProgramPlay.duration_seconds)).where(
                        ProgramPlay.program_id == program.id,
                        ProgramPlay.duration_seconds.isnot(None),
                    )
                )
            ).scalar()

            stats.append(
                {
                    "program_id": program.id,
                    "title": program.title,
                    "play_count": program.play_count or 0,
                    "favorite_count": program.favorite_count or 0,
                    "avg_listen_duration": round(float(avg_duration), 1)
                    if avg_duration
                    else None,
                }
            )

        return stats

    async def get_play_trends(self, user_id: uuid.UUID, days: int = 30) -> list[dict]:
        """Get daily play count trends for the broadcaster's programs."""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        # Get all program IDs for this user
        program_ids_query = select(Program.id).where(Program.user_id == user_id)

        play_date = cast(ProgramPlay.created_at, Date).label("play_date")
        result = await self.db.execute(
            select(play_date, func.count().label("count"))
            .where(
                ProgramPlay.program_id.in_(program_ids_query),
                ProgramPlay.created_at >= since,
            )
            .group_by(play_date)
            .order_by(play_date)
        )

        return [
            {"date": row.play_date, "count": row.count} for row in result.all()
        ]

    async def get_top_tracks(self, user_id: uuid.UUID, limit: int = 20) -> list[dict]:
        """Get most played Apple Music tracks across the broadcaster's programs."""
        # Get tracks from the broadcaster's programs, grouped by apple_music_track_id
        program_ids_query = select(Program.id).where(Program.user_id == user_id)

        result = await self.db.execute(
            select(
                ProgramTrack.apple_music_track_id,
                ProgramTrack.title,
                ProgramTrack.artist_name,
                ProgramTrack.artwork_url,
                func.count().label("total_appearances"),
            )
            .where(
                ProgramTrack.program_id.in_(program_ids_query),
                ProgramTrack.apple_music_track_id.isnot(None),
            )
            .group_by(
                ProgramTrack.apple_music_track_id,
                ProgramTrack.title,
                ProgramTrack.artist_name,
                ProgramTrack.artwork_url,
            )
            .order_by(func.count().desc())
            .limit(limit)
        )

        return [
            {
                "apple_music_track_id": row.apple_music_track_id,
                "title": row.title,
                "artist_name": row.artist_name,
                "artwork_url": row.artwork_url,
                "total_appearances": row.total_appearances,
            }
            for row in result.all()
        ]
