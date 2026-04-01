#!/usr/bin/env python3
"""Seed script: creates sample users and 12 radio programs across 8 genres.

Usage:
    cd backend/
    python -m scripts.seed_sample_programs

Genres covered: jpop, jazz, rock, anime, indie, hiphop, classical, electronic

Features:
- Creates 3 sample broadcaster users (skips if email already exists)
- Creates 12 published programs with 2-4 tracks each
- Uses realistic Apple Music track IDs (Japan storefront)
- Handles duplicates gracefully (skips existing programs by title per user)
"""
import asyncio
import sys
import uuid
from pathlib import Path

# Ensure the backend package is importable
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import async_session
from app.models.user import User, UserProfile
from app.models.program import Program, ProgramStatus, ProgramType, ProgramTrack


# ---------------------------------------------------------------------------
# Sample Users
# ---------------------------------------------------------------------------

SAMPLE_USERS = [
    {
        "email": "dj_sakura@example.com",
        "nickname": "DJ さくら",
        "message": "J-POP・アニソン中心に毎日配信中！",
    },
    {
        "email": "jazz_master_taro@example.com",
        "nickname": "ジャズマスター太郎",
        "message": "ジャズとクラシックの名曲をお届けします。",
    },
    {
        "email": "beat_queen@example.com",
        "nickname": "Beat Queen",
        "message": "HipHop / Electronic / Rock — いいビートをシェアしたい。",
    },
]


# ---------------------------------------------------------------------------
# Sample Programs (12 programs, 8 genres)
# ---------------------------------------------------------------------------

SAMPLE_PROGRAMS = [
    # --- jpop (user 0) ---
    {
        "user_index": 0,
        "title": "朝のJ-POPモーニング",
        "description": "爽やかな朝にぴったりのJ-POPヒット曲をお届けします。通勤・通学のお供にどうぞ！",
        "genre": "jpop",
        "duration_seconds": 1800.0,
        "play_count": 1247,
        "favorite_count": 389,
        "tracks": [
            {
                "apple_music_track_id": "1615270862",
                "title": "Subtitle",
                "artist_name": "Official髭男dism",
                "play_timing_seconds": 60.0,
                "duration_seconds": 294.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1713517874",
                "title": "アイドル",
                "artist_name": "YOASOBI",
                "play_timing_seconds": 420.0,
                "duration_seconds": 223.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1556178315",
                "title": "ドライフラワー",
                "artist_name": "優里",
                "play_timing_seconds": 780.0,
                "duration_seconds": 284.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1654562573",
                "title": "ミックスナッツ",
                "artist_name": "Official髭男dism",
                "play_timing_seconds": 1140.0,
                "duration_seconds": 254.0,
                "track_order": 3,
            },
        ],
    },
    {
        "user_index": 0,
        "title": "午後のJ-POP カフェタイム",
        "description": "カフェでゆったり聴きたいJ-POPバラードとポップス。午後のリラックスタイムに。",
        "genre": "jpop",
        "duration_seconds": 2100.0,
        "play_count": 934,
        "favorite_count": 287,
        "tracks": [
            {
                "apple_music_track_id": "1547072042",
                "title": "Pretender",
                "artist_name": "Official髭男dism",
                "play_timing_seconds": 90.0,
                "duration_seconds": 327.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1607394875",
                "title": "踊り子",
                "artist_name": "Vaundy",
                "play_timing_seconds": 540.0,
                "duration_seconds": 234.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1633079498",
                "title": "Magic",
                "artist_name": "Mrs. GREEN APPLE",
                "play_timing_seconds": 960.0,
                "duration_seconds": 222.0,
                "track_order": 2,
            },
        ],
    },
    # --- anime (user 0) ---
    {
        "user_index": 0,
        "title": "アニソンパラダイス",
        "description": "人気アニメの主題歌を集めたアニソン特集。懐かしの名曲から最新ヒットまで！",
        "genre": "anime",
        "duration_seconds": 1800.0,
        "play_count": 2104,
        "favorite_count": 721,
        "tracks": [
            {
                "apple_music_track_id": "1621242812",
                "title": "残酷な天使のテーゼ",
                "artist_name": "高橋洋子",
                "play_timing_seconds": 60.0,
                "duration_seconds": 262.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1713517874",
                "title": "アイドル",
                "artist_name": "YOASOBI",
                "play_timing_seconds": 420.0,
                "duration_seconds": 223.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1586248467",
                "title": "紅蓮華",
                "artist_name": "LiSA",
                "play_timing_seconds": 780.0,
                "duration_seconds": 234.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1558822982",
                "title": "炎",
                "artist_name": "LiSA",
                "play_timing_seconds": 1140.0,
                "duration_seconds": 271.0,
                "track_order": 3,
            },
        ],
    },
    # --- jazz (user 1) ---
    {
        "user_index": 1,
        "title": "夜のジャズラウンジ",
        "description": "大人の夜に寄り添うジャズの名曲セレクション。ゆったりとした時間をお過ごしください。",
        "genre": "jazz",
        "duration_seconds": 2400.0,
        "play_count": 856,
        "favorite_count": 274,
        "tracks": [
            {
                "apple_music_track_id": "1440833709",
                "title": "Take Five",
                "artist_name": "Dave Brubeck",
                "play_timing_seconds": 120.0,
                "duration_seconds": 324.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1440654058",
                "title": "So What",
                "artist_name": "Miles Davis",
                "play_timing_seconds": 600.0,
                "duration_seconds": 561.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1443102648",
                "title": "Fly Me to the Moon",
                "artist_name": "Frank Sinatra",
                "play_timing_seconds": 1200.0,
                "duration_seconds": 149.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1444058530",
                "title": "Autumn Leaves",
                "artist_name": "Bill Evans Trio",
                "play_timing_seconds": 1800.0,
                "duration_seconds": 296.0,
                "track_order": 3,
            },
        ],
    },
    # --- classical (user 1) ---
    {
        "user_index": 1,
        "title": "クラシック名曲の時間",
        "description": "誰もが一度は聴いたことのあるクラシックの名曲を厳選。心が安らぐひとときを。",
        "genre": "classical",
        "duration_seconds": 3600.0,
        "play_count": 672,
        "favorite_count": 198,
        "tracks": [
            {
                "apple_music_track_id": "1452701117",
                "title": "四季「春」第1楽章",
                "artist_name": "アントニオ・ヴィヴァルディ",
                "play_timing_seconds": 120.0,
                "duration_seconds": 208.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1443198730",
                "title": "月の光",
                "artist_name": "クロード・ドビュッシー",
                "play_timing_seconds": 600.0,
                "duration_seconds": 312.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1444389537",
                "title": "エリーゼのために",
                "artist_name": "ルートヴィヒ・ヴァン・ベートーヴェン",
                "play_timing_seconds": 1200.0,
                "duration_seconds": 187.0,
                "track_order": 2,
            },
        ],
    },
    {
        "user_index": 1,
        "title": "ジャズ×クラシック クロスオーバー",
        "description": "ジャズとクラシックの境界を超えた名演奏をセレクト。新しい音楽体験を。",
        "genre": "jazz",
        "duration_seconds": 2700.0,
        "play_count": 412,
        "favorite_count": 135,
        "tracks": [
            {
                "apple_music_track_id": "1440660975",
                "title": "My Favorite Things",
                "artist_name": "John Coltrane",
                "play_timing_seconds": 180.0,
                "duration_seconds": 822.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1452535382",
                "title": "ラプソディ・イン・ブルー",
                "artist_name": "ジョージ・ガーシュウィン",
                "play_timing_seconds": 1080.0,
                "duration_seconds": 1020.0,
                "track_order": 1,
            },
        ],
    },
    # --- rock (user 2) ---
    {
        "user_index": 2,
        "title": "ロック名曲ドライブ",
        "description": "ドライブにぴったりのロック名曲を厳選。テンション上がるナンバーで最高のドライブを！",
        "genre": "rock",
        "duration_seconds": 2100.0,
        "play_count": 1583,
        "favorite_count": 512,
        "tracks": [
            {
                "apple_music_track_id": "1440857781",
                "title": "Bohemian Rhapsody",
                "artist_name": "Queen",
                "play_timing_seconds": 90.0,
                "duration_seconds": 354.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1440833237",
                "title": "Hotel California",
                "artist_name": "Eagles",
                "play_timing_seconds": 540.0,
                "duration_seconds": 391.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1440892237",
                "title": "Smells Like Teen Spirit",
                "artist_name": "Nirvana",
                "play_timing_seconds": 1020.0,
                "duration_seconds": 301.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1440807760",
                "title": "Stairway to Heaven",
                "artist_name": "Led Zeppelin",
                "play_timing_seconds": 1560.0,
                "duration_seconds": 482.0,
                "track_order": 3,
            },
        ],
    },
    # --- hiphop (user 2) ---
    {
        "user_index": 2,
        "title": "日本語ラップ最前線",
        "description": "今アツい日本語ラップシーンの注目曲を集めました。ストリートからメインストリームまで。",
        "genre": "hiphop",
        "duration_seconds": 2100.0,
        "play_count": 1876,
        "favorite_count": 643,
        "tracks": [
            {
                "apple_music_track_id": "1612421022",
                "title": "Bling-Bang-Bang-Born",
                "artist_name": "Creepy Nuts",
                "play_timing_seconds": 60.0,
                "duration_seconds": 196.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1565635806",
                "title": "よふかしのうた",
                "artist_name": "Creepy Nuts",
                "play_timing_seconds": 420.0,
                "duration_seconds": 222.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1498554972",
                "title": "かいじゅうのマーチ",
                "artist_name": "米津玄師",
                "play_timing_seconds": 780.0,
                "duration_seconds": 256.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1590399288",
                "title": "KICK BACK",
                "artist_name": "米津玄師",
                "play_timing_seconds": 1140.0,
                "duration_seconds": 195.0,
                "track_order": 3,
            },
        ],
    },
    {
        "user_index": 2,
        "title": "HipHop Classics ミックス",
        "description": "世界のヒップホップクラシックを振り返る。レジェンドたちの名曲をノンストップで。",
        "genre": "hiphop",
        "duration_seconds": 1800.0,
        "play_count": 1023,
        "favorite_count": 356,
        "tracks": [
            {
                "apple_music_track_id": "1440841238",
                "title": "Lose Yourself",
                "artist_name": "Eminem",
                "play_timing_seconds": 60.0,
                "duration_seconds": 326.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1440823279",
                "title": "Juicy",
                "artist_name": "The Notorious B.I.G.",
                "play_timing_seconds": 480.0,
                "duration_seconds": 314.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1440915532",
                "title": "HUMBLE.",
                "artist_name": "Kendrick Lamar",
                "play_timing_seconds": 900.0,
                "duration_seconds": 177.0,
                "track_order": 2,
            },
        ],
    },
    # --- electronic (user 2) ---
    {
        "user_index": 2,
        "title": "エレクトロニック・ナイトクルーズ",
        "description": "深夜のドライブに合うエレクトロニック・ミュージック。ビートに身を委ねて。",
        "genre": "electronic",
        "duration_seconds": 2400.0,
        "play_count": 1345,
        "favorite_count": 467,
        "tracks": [
            {
                "apple_music_track_id": "1440818839",
                "title": "Strobe",
                "artist_name": "Deadmau5",
                "play_timing_seconds": 120.0,
                "duration_seconds": 637.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1440838295",
                "title": "Midnight City",
                "artist_name": "M83",
                "play_timing_seconds": 840.0,
                "duration_seconds": 243.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1440660982",
                "title": "Around the World",
                "artist_name": "Daft Punk",
                "play_timing_seconds": 1320.0,
                "duration_seconds": 428.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1440837118",
                "title": "Levels",
                "artist_name": "Avicii",
                "play_timing_seconds": 1860.0,
                "duration_seconds": 201.0,
                "track_order": 3,
            },
        ],
    },
    # --- indie (user 0) ---
    {
        "user_index": 0,
        "title": "インディーズ発掘ラジオ",
        "description": "まだ知らないインディーズアーティストの魅力を発掘！次にブレイクするアーティストがここにいるかも。",
        "genre": "indie",
        "duration_seconds": 2100.0,
        "play_count": 643,
        "favorite_count": 198,
        "tracks": [
            {
                "apple_music_track_id": "1633079498",
                "title": "Magic",
                "artist_name": "Mrs. GREEN APPLE",
                "play_timing_seconds": 90.0,
                "duration_seconds": 222.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1607394875",
                "title": "踊り子",
                "artist_name": "Vaundy",
                "play_timing_seconds": 480.0,
                "duration_seconds": 234.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1584498498",
                "title": "猫",
                "artist_name": "DISH//",
                "play_timing_seconds": 870.0,
                "duration_seconds": 273.0,
                "track_order": 2,
            },
            {
                "apple_music_track_id": "1615555300",
                "title": "第ゼロ感",
                "artist_name": "10-FEET",
                "play_timing_seconds": 1260.0,
                "duration_seconds": 262.0,
                "track_order": 3,
            },
        ],
    },
    # --- electronic (user 0) ---
    {
        "user_index": 0,
        "title": "Future Bass & チルアウト",
        "description": "フューチャーベースとチルアウト系の楽曲でリラックス。勉強や作業のBGMにも最適。",
        "genre": "electronic",
        "duration_seconds": 1800.0,
        "play_count": 789,
        "favorite_count": 234,
        "tracks": [
            {
                "apple_music_track_id": "1440862231",
                "title": "Shelter",
                "artist_name": "Porter Robinson & Madeon",
                "play_timing_seconds": 60.0,
                "duration_seconds": 278.0,
                "track_order": 0,
            },
            {
                "apple_music_track_id": "1440845040",
                "title": "Faded",
                "artist_name": "Alan Walker",
                "play_timing_seconds": 420.0,
                "duration_seconds": 212.0,
                "track_order": 1,
            },
            {
                "apple_music_track_id": "1440895073",
                "title": "Lean On",
                "artist_name": "Major Lazer & DJ Snake",
                "play_timing_seconds": 780.0,
                "duration_seconds": 176.0,
                "track_order": 2,
            },
        ],
    },
]


# ---------------------------------------------------------------------------
# Database Operations
# ---------------------------------------------------------------------------

async def get_or_create_users(db: AsyncSession) -> list[User]:
    """Create sample broadcaster users if they don't exist. Return the user list."""
    from app.utils.auth import hash_password

    users: list[User] = []

    for user_data in SAMPLE_USERS:
        result = await db.execute(
            select(User).where(User.email == user_data["email"])
        )
        existing = result.scalar_one_or_none()
        if existing:
            print(f"[seed] User already exists: {existing.email} ({existing.id})")
            users.append(existing)
            continue

        user_id = uuid.uuid4()
        user = User(
            id=user_id,
            email=user_data["email"],
            hashed_password=hash_password("password123"),
            is_active=True,
            is_admin=False,
            email_verified=True,
        )
        db.add(user)

        profile = UserProfile(
            user_id=user_id,
            nickname=user_data["nickname"],
            message=user_data.get("message", ""),
        )
        db.add(profile)
        await db.flush()

        print(f"[seed] Created user: {user.email} ({user.id})")
        users.append(user)

    return users


async def seed_programs(db: AsyncSession) -> None:
    """Create sample programs and their tracks."""
    users = await get_or_create_users(db)

    created = 0
    skipped = 0

    for prog_data in SAMPLE_PROGRAMS:
        user = users[prog_data["user_index"]]

        # Check for duplicate by title + user
        result = await db.execute(
            select(Program).where(
                Program.user_id == user.id,
                Program.title == prog_data["title"],
            )
        )
        if result.scalar_one_or_none():
            print(f"[seed] Skipping (already exists): {prog_data['title']}")
            skipped += 1
            continue

        program = Program(
            user_id=user.id,
            title=prog_data["title"],
            description=prog_data["description"],
            genre=prog_data["genre"],
            status=ProgramStatus.published,
            program_type=ProgramType.recorded,
            duration_seconds=prog_data["duration_seconds"],
            play_count=prog_data["play_count"],
            favorite_count=prog_data["favorite_count"],
        )
        db.add(program)
        await db.flush()

        for t in prog_data["tracks"]:
            track = ProgramTrack(
                program_id=program.id,
                apple_music_track_id=t["apple_music_track_id"],
                title=t["title"],
                artist_name=t["artist_name"],
                artwork_url=t.get("artwork_url"),
                play_timing_seconds=t["play_timing_seconds"],
                duration_seconds=t.get("duration_seconds"),
                track_order=t["track_order"],
            )
            db.add(track)

        await db.flush()
        created += 1
        print(f"[seed] Created: {prog_data['title']} [{prog_data['genre']}] ({len(prog_data['tracks'])} tracks)")

    print(f"\n[seed] Done. {created} program(s) created, {skipped} skipped (already existed).")


async def main() -> None:
    async with async_session() as session:
        try:
            await seed_programs(session)
            await session.commit()
            print("[seed] All changes committed.")
        except Exception as e:
            await session.rollback()
            print(f"[seed] Error: {e}")
            raise


if __name__ == "__main__":
    asyncio.run(main())
