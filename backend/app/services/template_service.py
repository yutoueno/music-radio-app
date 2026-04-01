"""Predefined program templates for onboarding new broadcasters."""

from dataclasses import dataclass, field


@dataclass
class TrackTemplate:
    apple_music_track_id: str
    title: str
    artist_name: str
    artwork_url: str | None
    play_timing_seconds: float
    duration_seconds: float | None
    track_order: int


@dataclass
class ProgramTemplate:
    name: str
    title: str
    description: str
    genre: str
    duration_seconds: float
    tracks: list[TrackTemplate] = field(default_factory=list)


# Well-known Apple Music track IDs (Japan storefront) used as realistic examples
PROGRAM_TEMPLATES: dict[str, ProgramTemplate] = {
    "jpop_morning": ProgramTemplate(
        name="jpop_morning",
        title="朝のJ-POPモーニング",
        description="爽やかな朝にぴったりのJ-POPヒット曲をお届けします。通勤・通学のお供にどうぞ！",
        genre="jpop",
        duration_seconds=1800.0,
        tracks=[
            TrackTemplate(
                apple_music_track_id="1615270862",
                title="Subtitle",
                artist_name="Official髭男dism",
                artwork_url=None,
                play_timing_seconds=60.0,
                duration_seconds=294.0,
                track_order=0,
            ),
            TrackTemplate(
                apple_music_track_id="1713517874",
                title="アイドル",
                artist_name="YOASOBI",
                artwork_url=None,
                play_timing_seconds=420.0,
                duration_seconds=223.0,
                track_order=1,
            ),
            TrackTemplate(
                apple_music_track_id="1556178315",
                title="ドライフラワー",
                artist_name="優里",
                artwork_url=None,
                play_timing_seconds=780.0,
                duration_seconds=284.0,
                track_order=2,
            ),
            TrackTemplate(
                apple_music_track_id="1654562573",
                title="ミックスナッツ",
                artist_name="Official髭男dism",
                artwork_url=None,
                play_timing_seconds=1140.0,
                duration_seconds=254.0,
                track_order=3,
            ),
        ],
    ),
    "jazz_evening": ProgramTemplate(
        name="jazz_evening",
        title="夜のジャズラウンジ",
        description="大人の夜に寄り添うジャズの名曲セレクション。ゆったりとした時間をお過ごしください。",
        genre="jazz",
        duration_seconds=2400.0,
        tracks=[
            TrackTemplate(
                apple_music_track_id="1440833709",
                title="Take Five",
                artist_name="Dave Brubeck",
                artwork_url=None,
                play_timing_seconds=120.0,
                duration_seconds=324.0,
                track_order=0,
            ),
            TrackTemplate(
                apple_music_track_id="1440654058",
                title="So What",
                artist_name="Miles Davis",
                artwork_url=None,
                play_timing_seconds=600.0,
                duration_seconds=561.0,
                track_order=1,
            ),
            TrackTemplate(
                apple_music_track_id="1440660975",
                title="My Favorite Things",
                artist_name="John Coltrane",
                artwork_url=None,
                play_timing_seconds=1200.0,
                duration_seconds=822.0,
                track_order=2,
            ),
            TrackTemplate(
                apple_music_track_id="1443102648",
                title="Fly Me to the Moon",
                artist_name="Frank Sinatra",
                artwork_url=None,
                play_timing_seconds=1800.0,
                duration_seconds=149.0,
                track_order=3,
            ),
            TrackTemplate(
                apple_music_track_id="1444058530",
                title="Autumn Leaves",
                artist_name="Bill Evans Trio",
                artwork_url=None,
                play_timing_seconds=2100.0,
                duration_seconds=296.0,
                track_order=4,
            ),
        ],
    ),
    "rock_drive": ProgramTemplate(
        name="rock_drive",
        title="ロック名曲ドライブ",
        description="ドライブにぴったりのロック名曲を厳選。テンション上がるナンバーで最高のドライブを！",
        genre="rock",
        duration_seconds=2100.0,
        tracks=[
            TrackTemplate(
                apple_music_track_id="1440857781",
                title="Bohemian Rhapsody",
                artist_name="Queen",
                artwork_url=None,
                play_timing_seconds=90.0,
                duration_seconds=354.0,
                track_order=0,
            ),
            TrackTemplate(
                apple_music_track_id="1440833237",
                title="Hotel California",
                artist_name="Eagles",
                artwork_url=None,
                play_timing_seconds=540.0,
                duration_seconds=391.0,
                track_order=1,
            ),
            TrackTemplate(
                apple_music_track_id="1440807760",
                title="Stairway to Heaven",
                artist_name="Led Zeppelin",
                artwork_url=None,
                play_timing_seconds=1020.0,
                duration_seconds=482.0,
                track_order=2,
            ),
            TrackTemplate(
                apple_music_track_id="1440892237",
                title="Smells Like Teen Spirit",
                artist_name="Nirvana",
                artwork_url=None,
                play_timing_seconds=1560.0,
                duration_seconds=301.0,
                track_order=3,
            ),
        ],
    ),
    "anime_paradise": ProgramTemplate(
        name="anime_paradise",
        title="アニソンパラダイス",
        description="人気アニメの主題歌を集めたアニソン特集。懐かしの名曲から最新ヒットまで！",
        genre="anime",
        duration_seconds=1800.0,
        tracks=[
            TrackTemplate(
                apple_music_track_id="1621242812",
                title="残酷な天使のテーゼ",
                artist_name="高橋洋子",
                artwork_url=None,
                play_timing_seconds=60.0,
                duration_seconds=262.0,
                track_order=0,
            ),
            TrackTemplate(
                apple_music_track_id="1713517874",
                title="アイドル",
                artist_name="YOASOBI",
                artwork_url=None,
                play_timing_seconds=420.0,
                duration_seconds=223.0,
                track_order=1,
            ),
            TrackTemplate(
                apple_music_track_id="1637284671",
                title="廻廻奇譚",
                artist_name="Eve",
                artwork_url=None,
                play_timing_seconds=780.0,
                duration_seconds=225.0,
                track_order=2,
            ),
            TrackTemplate(
                apple_music_track_id="1586248467",
                title="紅蓮華",
                artist_name="LiSA",
                artwork_url=None,
                play_timing_seconds=1140.0,
                duration_seconds=234.0,
                track_order=3,
            ),
            TrackTemplate(
                apple_music_track_id="1558822982",
                title="炎",
                artist_name="LiSA",
                artwork_url=None,
                play_timing_seconds=1440.0,
                duration_seconds=271.0,
                track_order=4,
            ),
        ],
    ),
    "indie_discovery": ProgramTemplate(
        name="indie_discovery",
        title="インディーズ発掘ラジオ",
        description="まだ知らないインディーズアーティストの魅力を発掘！次にブレイクするアーティストがここにいるかも。",
        genre="indie",
        duration_seconds=2100.0,
        tracks=[
            TrackTemplate(
                apple_music_track_id="1633079498",
                title="Magic",
                artist_name="Mrs. GREEN APPLE",
                artwork_url=None,
                play_timing_seconds=90.0,
                duration_seconds=222.0,
                track_order=0,
            ),
            TrackTemplate(
                apple_music_track_id="1607394875",
                title="踊り子",
                artist_name="Vaundy",
                artwork_url=None,
                play_timing_seconds=480.0,
                duration_seconds=234.0,
                track_order=1,
            ),
            TrackTemplate(
                apple_music_track_id="1584498498",
                title="猫",
                artist_name="DISH//",
                artwork_url=None,
                play_timing_seconds=870.0,
                duration_seconds=273.0,
                track_order=2,
            ),
            TrackTemplate(
                apple_music_track_id="1615555300",
                title="第ゼロ感",
                artist_name="10-FEET",
                artwork_url=None,
                play_timing_seconds=1260.0,
                duration_seconds=262.0,
                track_order=3,
            ),
        ],
    ),
}


def get_template(template_name: str) -> ProgramTemplate | None:
    """Retrieve a program template by its name key."""
    return PROGRAM_TEMPLATES.get(template_name)


def list_template_names() -> list[str]:
    """Return all available template name keys."""
    return list(PROGRAM_TEMPLATES.keys())


def list_templates_summary() -> list[dict]:
    """Return a summary list of all templates (name, title, genre, track_count)."""
    return [
        {
            "name": t.name,
            "title": t.title,
            "description": t.description,
            "genre": t.genre,
            "track_count": len(t.tracks),
            "duration_seconds": t.duration_seconds,
        }
        for t in PROGRAM_TEMPLATES.values()
    ]
