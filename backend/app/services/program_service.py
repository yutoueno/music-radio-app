import uuid

from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.program import Program, ProgramStatus, ProgramTrack
from app.models.play_log import ProgramPlay
from app.models.user import UserProfile


class ProgramService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_program(self, user_id: uuid.UUID, data: dict) -> Program:
        program = Program(user_id=user_id, **data)
        self.db.add(program)
        await self.db.flush()
        await self.db.refresh(program, attribute_names=["tracks"])
        return program

    async def get_program(self, program_id: uuid.UUID) -> Program | None:
        result = await self.db.execute(
            select(Program)
            .options(selectinload(Program.tracks))
            .where(Program.id == program_id)
        )
        return result.scalar_one_or_none()

    async def update_program(
        self, program_id: uuid.UUID, user_id: uuid.UUID, data: dict
    ) -> Program | None:
        program = await self.get_program(program_id)
        if not program or program.user_id != user_id:
            return None
        for key, value in data.items():
            setattr(program, key, value)
        await self.db.flush()
        # Full re-fetch to ensure updated_at and tracks are loaded
        return await self.get_program(program_id)

    async def delete_program(self, program_id: uuid.UUID, user_id: uuid.UUID) -> bool:
        program = await self.get_program(program_id)
        if not program or program.user_id != user_id:
            return False
        await self.db.delete(program)
        await self.db.flush()
        return True

    async def list_programs(
        self,
        page: int = 1,
        per_page: int = 30,
        status: ProgramStatus | None = ProgramStatus.published,
        user_id: uuid.UUID | None = None,
        q: str | None = None,
        genre: str | None = None,
        sort_by: str | None = None,
        sort_order: str | None = None,
    ) -> tuple[list[Program], int]:
        query = select(Program).options(selectinload(Program.tracks))

        if status:
            query = query.where(Program.status == status)
        if user_id:
            query = query.where(Program.user_id == user_id)

        # Search by title or description (case-insensitive)
        if q:
            search_term = f"%{q}%"
            query = query.where(
                or_(
                    Program.title.ilike(search_term),
                    Program.description.ilike(search_term),
                )
            )

        # Filter by genre
        if genre:
            query = query.where(Program.genre == genre)

        # Count total
        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        # Sort
        valid_sort_fields = {
            "play_count": Program.play_count,
            "created_at": Program.created_at,
            "favorite_count": Program.favorite_count,
        }
        sort_field = valid_sort_fields.get(sort_by, Program.created_at)
        if sort_order == "asc":
            query = query.order_by(sort_field.asc())
        else:
            query = query.order_by(sort_field.desc())

        # Paginate
        query = query.offset((page - 1) * per_page).limit(per_page)

        result = await self.db.execute(query)
        programs = list(result.scalars().all())

        return programs, total

    async def get_genres_with_counts(self) -> list[dict]:
        """Return list of genres with their program counts (published only)."""
        result = await self.db.execute(
            select(Program.genre, func.count(Program.id).label("count"))
            .where(Program.status == ProgramStatus.published)
            .where(Program.genre.isnot(None))
            .where(Program.genre != "")
            .group_by(Program.genre)
            .order_by(func.count(Program.id).desc())
        )
        rows = result.all()
        return [{"genre": row[0], "count": row[1]} for row in rows]

    async def get_recommended_programs(
        self, page: int = 1, per_page: int = 30
    ) -> tuple[list[Program], int]:
        """Return published programs ordered by popularity (play_count + favorite_count)."""
        query = (
            select(Program)
            .options(selectinload(Program.tracks))
            .where(Program.status == ProgramStatus.published)
            .order_by(
                (Program.play_count + Program.favorite_count).desc(),
                Program.created_at.desc(),
            )
        )

        count_query = select(func.count()).select_from(
            select(Program).where(Program.status == ProgramStatus.published).subquery()
        )
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        programs = list(result.scalars().all())

        return programs, total

    async def get_user_programs(
        self,
        user_id: uuid.UUID,
        page: int = 1,
        per_page: int = 30,
        include_drafts: bool = False,
    ) -> tuple[list[Program], int]:
        query = select(Program).options(selectinload(Program.tracks)).where(
            Program.user_id == user_id
        )
        if not include_drafts:
            query = query.where(Program.status == ProgramStatus.published)

        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        query = query.order_by(Program.created_at.desc())
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        programs = list(result.scalars().all())

        return programs, total

    async def record_play(
        self, program_id: uuid.UUID, user_id: uuid.UUID | None, duration_seconds: float | None
    ) -> None:
        play = ProgramPlay(
            program_id=program_id,
            user_id=user_id,
            duration_seconds=duration_seconds,
        )
        self.db.add(play)

        # Increment play count
        program = await self.get_program(program_id)
        if program:
            program.play_count = (program.play_count or 0) + 1
        await self.db.flush()

    async def get_program_with_user_nickname(self, program: Program) -> str | None:
        """Get the nickname of the user who owns this program."""
        result = await self.db.execute(
            select(UserProfile.nickname).where(UserProfile.user_id == program.user_id)
        )
        nickname = result.scalar_one_or_none()
        return nickname

    # Track operations
    async def create_track(self, data: dict) -> ProgramTrack:
        track = ProgramTrack(**data)
        self.db.add(track)
        await self.db.flush()
        return track

    async def get_track(self, track_id: uuid.UUID) -> ProgramTrack | None:
        result = await self.db.execute(
            select(ProgramTrack).where(ProgramTrack.id == track_id)
        )
        return result.scalar_one_or_none()

    async def update_track(self, track_id: uuid.UUID, data: dict) -> ProgramTrack | None:
        track = await self.get_track(track_id)
        if not track:
            return None
        for key, value in data.items():
            setattr(track, key, value)
        await self.db.flush()
        return track

    async def delete_track(self, track_id: uuid.UUID) -> bool:
        track = await self.get_track(track_id)
        if not track:
            return False
        await self.db.delete(track)
        await self.db.flush()
        return True

    async def list_tracks_for_program(self, program_id: uuid.UUID) -> list[ProgramTrack]:
        result = await self.db.execute(
            select(ProgramTrack)
            .where(ProgramTrack.program_id == program_id)
            .order_by(ProgramTrack.track_order)
        )
        return list(result.scalars().all())

    # Admin operations
    async def admin_list_programs(
        self, page: int = 1, per_page: int = 30, status: ProgramStatus | None = None
    ) -> tuple[list[Program], int]:
        query = select(Program).options(selectinload(Program.tracks))
        if status:
            query = query.where(Program.status == status)

        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.db.execute(count_query)
        total = total_result.scalar() or 0

        query = query.order_by(Program.created_at.desc())
        query = query.offset((page - 1) * per_page).limit(per_page)
        result = await self.db.execute(query)
        programs = list(result.scalars().all())

        return programs, total

    async def admin_update_status(
        self, program_id: uuid.UUID, status: ProgramStatus
    ) -> Program | None:
        program = await self.get_program(program_id)
        if not program:
            return None
        program.status = status
        await self.db.flush()
        return await self.get_program(program_id)
