import uuid

from fastapi import APIRouter, Depends, Request
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.database import get_db
from app.services.program_service import ProgramService

router = APIRouter(tags=["web"])

settings = get_settings()


@router.get("/programs/{program_id}", response_class=HTMLResponse)
async def web_program_page(
    program_id: uuid.UUID,
    request: Request,
    db: AsyncSession = Depends(get_db),
):
    service = ProgramService(db)
    program = await service.get_program(program_id)

    if not program:
        return HTMLResponse(
            content=_not_found_html(),
            status_code=404,
        )

    nickname = await service.get_program_with_user_nickname(program)

    base_url = getattr(settings, "WEB_BASE_URL", "https://yourapp.com")
    og_title = program.title
    og_description = program.description or f"{nickname or 'broadcaster'}の番組です"
    og_image = program.thumbnail_url or f"{base_url}/static/default-ogp.png"
    og_url = f"{base_url}/programs/{program.id}"
    deep_link = f"musicradio://program/{program.id}"
    app_store_url = "https://apps.apple.com/app/music-radio/id000000000"

    html = f"""<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{_escape(og_title)} - Music Radio</title>

    <!-- OGP Meta Tags -->
    <meta property="og:title" content="{_escape(og_title)}" />
    <meta property="og:description" content="{_escape(og_description)}" />
    <meta property="og:image" content="{_escape(og_image)}" />
    <meta property="og:url" content="{_escape(og_url)}" />
    <meta property="og:type" content="music.radio_station" />
    <meta property="og:site_name" content="Music Radio" />

    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image" />
    <meta name="twitter:title" content="{_escape(og_title)}" />
    <meta name="twitter:description" content="{_escape(og_description)}" />
    <meta name="twitter:image" content="{_escape(og_image)}" />

    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: #fff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }}
        .container {{
            max-width: 480px;
            width: 100%;
            text-align: center;
        }}
        .card {{
            background: rgba(255, 255, 255, 0.08);
            backdrop-filter: blur(20px);
            border-radius: 24px;
            padding: 32px 24px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }}
        .thumbnail {{
            width: 200px;
            height: 200px;
            border-radius: 16px;
            object-fit: cover;
            margin: 0 auto 24px;
            display: block;
            background: rgba(255, 255, 255, 0.1);
        }}
        .thumbnail-placeholder {{
            width: 200px;
            height: 200px;
            border-radius: 16px;
            margin: 0 auto 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.1);
            font-size: 64px;
        }}
        h1 {{
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 8px;
            line-height: 1.3;
        }}
        .broadcaster {{
            font-size: 15px;
            color: rgba(255, 255, 255, 0.7);
            margin-bottom: 16px;
        }}
        .description {{
            font-size: 14px;
            color: rgba(255, 255, 255, 0.6);
            line-height: 1.5;
            margin-bottom: 24px;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
        }}
        .stats {{
            display: flex;
            justify-content: center;
            gap: 24px;
            margin-bottom: 24px;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.6);
        }}
        .open-app-btn {{
            display: inline-block;
            width: 100%;
            padding: 16px 32px;
            background: linear-gradient(135deg, #e94560 0%, #c23152 100%);
            color: #fff;
            text-decoration: none;
            border-radius: 14px;
            font-size: 17px;
            font-weight: 600;
            margin-bottom: 12px;
            transition: transform 0.2s;
        }}
        .open-app-btn:hover {{
            transform: scale(1.02);
        }}
        .store-link {{
            display: inline-block;
            font-size: 14px;
            color: rgba(255, 255, 255, 0.6);
            text-decoration: none;
            padding: 8px;
        }}
        .store-link:hover {{
            color: rgba(255, 255, 255, 0.9);
        }}
        .logo {{
            margin-bottom: 24px;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }}
        .logo span {{
            color: #e94560;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="logo">Music <span>Radio</span></div>

            {"<img class='thumbnail' src='" + _escape(program.thumbnail_url) + "' alt='" + _escape(og_title) + "' />" if program.thumbnail_url else "<div class='thumbnail-placeholder'>📻</div>"}

            <h1>{_escape(og_title)}</h1>

            {"<p class='broadcaster'>by " + _escape(nickname) + "</p>" if nickname else ""}

            {"<p class='description'>" + _escape(program.description) + "</p>" if program.description else ""}

            <div class="stats">
                <span>▶ {program.play_count or 0} plays</span>
                <span>♥ {program.favorite_count or 0} favorites</span>
            </div>

            <a href="{deep_link}" class="open-app-btn">アプリで開く</a>
            <br />
            <a href="{app_store_url}" class="store-link">App Storeでダウンロード</a>
        </div>
    </div>

    <script>
        // Try to open the deep link automatically
        setTimeout(function() {{
            window.location.href = "{deep_link}";
        }}, 100);
    </script>
</body>
</html>"""

    return HTMLResponse(content=html)


def _escape(s: str | None) -> str:
    if s is None:
        return ""
    return (
        s.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&#x27;")
    )


def _not_found_html() -> str:
    return """<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>番組が見つかりません - Music Radio</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
            color: #fff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
        }
        h1 { font-size: 24px; margin-bottom: 12px; }
        p { color: rgba(255,255,255,0.6); }
    </style>
</head>
<body>
    <div>
        <h1>番組が見つかりません</h1>
        <p>この番組は削除されたか、存在しません。</p>
    </div>
</body>
</html>"""
