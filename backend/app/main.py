from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.routers import admin, analytics, auth, inquiries, notifications, programs, social, tracks, upload, users, web

app = FastAPI(
    title="Music Radio API",
    description="A music radio platform where broadcasters upload radio programs and listeners play them with Apple Music tracks.",
    version="1.0.0",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(programs.router, prefix="/api/v1")
app.include_router(tracks.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(social.router, prefix="/api/v1")
app.include_router(upload.router, prefix="/api/v1")
app.include_router(admin.router, prefix="/api/v1")
app.include_router(analytics.router, prefix="/api/v1")
app.include_router(notifications.router, prefix="/api/v1")
app.include_router(inquiries.router, prefix="/api/v1")

# Web routes (mounted AFTER api routes, no /api/v1 prefix)
app.include_router(web.router)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "内部サーバーエラーが発生しました",
            }
        },
    )


@app.get("/api/v1/health")
async def health_check():
    return {"data": {"status": "ok"}}
