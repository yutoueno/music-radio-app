import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import User


async def create_user_and_login(client: AsyncClient, email: str = "user@example.com", nickname: str = "TestUser") -> str:
    """Helper: create a user via signup and return the access token."""
    resp = await client.post(
        "/api/v1/auth/signup",
        json={"email": email, "password": "password123", "nickname": nickname},
    )
    assert resp.status_code == 201
    return resp.json()["data"]["access_token"]


async def create_admin_user(client: AsyncClient, db_session: AsyncSession, email: str = "admin@example.com", nickname: str = "Admin") -> str:
    """Helper: create a user, promote to admin, and return access token."""
    token = await create_user_and_login(client, email=email, nickname=nickname)

    # Get user ID
    me_resp = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    user_id = me_resp.json()["data"]["id"]

    # Promote to admin directly in DB
    await db_session.execute(
        update(User).where(User.id == uuid.UUID(user_id)).values(is_admin=True)
    )
    await db_session.flush()

    return token


async def get_user_id(client: AsyncClient, token: str) -> str:
    """Helper: get the current user's ID."""
    resp = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    return resp.json()["data"]["id"]


async def create_program(client: AsyncClient, token: str, title: str = "Test Program", status: str = "published") -> str:
    """Helper: create a program and return its ID."""
    resp = await client.post(
        "/api/v1/programs",
        json={"title": title, "status": status, "program_type": "recorded"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 201
    return resp.json()["data"]["id"]


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# --- Dashboard ---


@pytest.mark.asyncio
async def test_dashboard_stats(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session)

    response = await client.get(
        "/api/v1/admin/dashboard",
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert "total_users" in data
    assert "active_users" in data
    assert "total_programs" in data
    assert "published_programs" in data
    assert "draft_programs" in data
    assert "archived_programs" in data
    assert "total_plays" in data
    assert "total_favorites" in data
    assert "total_follows" in data
    # We created 1 admin user so far
    assert data["total_users"] >= 1


@pytest.mark.asyncio
async def test_dashboard_stats_not_admin(client: AsyncClient):
    token = await create_user_and_login(client, email="regular@example.com", nickname="Regular")

    response = await client.get(
        "/api/v1/admin/dashboard",
        headers=auth_headers(token),
    )
    assert response.status_code == 403


# --- Reports ---


@pytest.mark.asyncio
async def test_reports(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session)

    response = await client.get(
        "/api/v1/admin/reports",
        params={"days": 7},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert "top_programs_by_plays" in data
    assert "top_programs_by_favorites" in data
    assert "play_count_trends" in data
    assert "new_user_trends" in data
    assert isinstance(data["top_programs_by_plays"], list)
    assert isinstance(data["play_count_trends"], list)


@pytest.mark.asyncio
async def test_reports_not_admin(client: AsyncClient):
    token = await create_user_and_login(client, email="nonadmin@example.com", nickname="NonAdmin")

    response = await client.get(
        "/api/v1/admin/reports",
        headers=auth_headers(token),
    )
    assert response.status_code == 403


# --- User Management ---


@pytest.mark.asyncio
async def test_list_users(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session)
    # Create some regular users
    await create_user_and_login(client, email="user1@example.com", nickname="User1")
    await create_user_and_login(client, email="user2@example.com", nickname="User2")

    response = await client.get(
        "/api/v1/admin/users",
        params={"page": 1, "per_page": 10},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["data"]) >= 3  # admin + 2 regular users
    assert body["meta"]["total"] >= 3


@pytest.mark.asyncio
async def test_list_users_not_admin(client: AsyncClient):
    token = await create_user_and_login(client, email="noadmin2@example.com", nickname="NoAdmin2")

    response = await client.get(
        "/api/v1/admin/users",
        headers=auth_headers(token),
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_update_user_status(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session)
    user_token = await create_user_and_login(client, email="target@example.com", nickname="Target")
    user_id = await get_user_id(client, user_token)

    # Deactivate the user
    response = await client.patch(
        f"/api/v1/admin/users/{user_id}",
        json={"is_active": False},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    assert response.json()["data"]["is_active"] is False

    # Re-activate the user
    response2 = await client.patch(
        f"/api/v1/admin/users/{user_id}",
        json={"is_active": True},
        headers=auth_headers(admin_token),
    )
    assert response2.status_code == 200
    assert response2.json()["data"]["is_active"] is True


@pytest.mark.asyncio
async def test_update_user_status_not_found(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session)
    fake_id = str(uuid.uuid4())

    response = await client.patch(
        f"/api/v1/admin/users/{fake_id}",
        json={"is_active": False},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_promote_user_to_admin(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session, email="superadmin@example.com", nickname="SuperAdmin")
    user_token = await create_user_and_login(client, email="promote@example.com", nickname="Promotee")
    user_id = await get_user_id(client, user_token)

    response = await client.patch(
        f"/api/v1/admin/users/{user_id}",
        json={"is_admin": True},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    assert response.json()["data"]["is_admin"] is True


# --- Program Management ---


@pytest.mark.asyncio
async def test_admin_list_programs(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session, email="admin2@example.com", nickname="Admin2")
    user_token = await create_user_and_login(client, email="broadcaster@example.com", nickname="Broadcaster")

    await create_program(client, user_token, title="Published Program", status="published")
    await create_program(client, user_token, title="Draft Program", status="draft")

    response = await client.get(
        "/api/v1/admin/programs",
        params={"page": 1, "per_page": 10},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["data"]) >= 2
    assert body["meta"]["total"] >= 2


@pytest.mark.asyncio
async def test_admin_list_programs_filter_by_status(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session, email="admin3@example.com", nickname="Admin3")
    user_token = await create_user_and_login(client, email="bc2@example.com", nickname="BC2")

    await create_program(client, user_token, title="Published Only", status="published")
    await create_program(client, user_token, title="Draft Only", status="draft")

    response = await client.get(
        "/api/v1/admin/programs",
        params={"status": "draft"},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert all(p["status"] == "draft" for p in data)


@pytest.mark.asyncio
async def test_admin_update_program_status(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session, email="admin4@example.com", nickname="Admin4")
    user_token = await create_user_and_login(client, email="bc3@example.com", nickname="BC3")
    program_id = await create_program(client, user_token, title="To Archive", status="published")

    response = await client.patch(
        f"/api/v1/admin/programs/{program_id}",
        json={"status": "archived"},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 200
    assert response.json()["data"]["status"] == "archived"


@pytest.mark.asyncio
async def test_admin_update_program_status_not_found(client: AsyncClient, db_session: AsyncSession):
    admin_token = await create_admin_user(client, db_session, email="admin5@example.com", nickname="Admin5")
    fake_id = str(uuid.uuid4())

    response = await client.patch(
        f"/api/v1/admin/programs/{fake_id}",
        json={"status": "archived"},
        headers=auth_headers(admin_token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_admin_programs_not_admin(client: AsyncClient):
    token = await create_user_and_login(client, email="noadmin3@example.com", nickname="NoAdmin3")

    response = await client.get(
        "/api/v1/admin/programs",
        headers=auth_headers(token),
    )
    assert response.status_code == 403
