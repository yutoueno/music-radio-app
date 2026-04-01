import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession


async def create_user_and_login(client: AsyncClient, email: str = "user@example.com", nickname: str = "TestUser") -> str:
    """Helper: create a user via signup and return the access token."""
    resp = await client.post(
        "/api/v1/auth/signup",
        json={"email": email, "password": "password123", "nickname": nickname},
    )
    assert resp.status_code == 201
    return resp.json()["data"]["access_token"]


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_register_device_token(client: AsyncClient):
    token = await create_user_and_login(client)

    response = await client.post(
        "/api/v1/notifications/device-token",
        json={"device_token": "abc123def456", "platform": "ios"},
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["device_token"] == "abc123def456"
    assert data["platform"] == "ios"


@pytest.mark.asyncio
async def test_register_device_token_default_platform(client: AsyncClient):
    token = await create_user_and_login(client)

    response = await client.post(
        "/api/v1/notifications/device-token",
        json={"device_token": "token123"},
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    assert response.json()["data"]["platform"] == "ios"


@pytest.mark.asyncio
async def test_get_notifications_empty(client: AsyncClient):
    token = await create_user_and_login(client)

    response = await client.get(
        "/api/v1/notifications",
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    body = response.json()
    assert body["data"] == []
    assert body["meta"]["total"] == 0


@pytest.mark.asyncio
async def test_get_unread_count(client: AsyncClient):
    token = await create_user_and_login(client)

    response = await client.get(
        "/api/v1/notifications/unread-count",
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    assert response.json()["data"]["unread_count"] == 0


@pytest.mark.asyncio
async def test_mark_notification_read_not_found(client: AsyncClient):
    token = await create_user_and_login(client)
    fake_id = str(uuid.uuid4())

    response = await client.put(
        f"/api/v1/notifications/{fake_id}/read",
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_mark_all_notifications_read(client: AsyncClient):
    token = await create_user_and_login(client)

    response = await client.post(
        "/api/v1/notifications/read-all",
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert "count" in data
    assert data["count"] == 0


@pytest.mark.asyncio
async def test_notifications_unauthenticated(client: AsyncClient):
    response = await client.get("/api/v1/notifications")
    assert response.status_code in (401, 403)
