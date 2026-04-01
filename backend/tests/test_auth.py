import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_signup(client: AsyncClient):
    response = await client.post(
        "/api/v1/auth/signup",
        json={
            "email": "test@example.com",
            "password": "password123",
            "nickname": "TestUser",
        },
    )
    assert response.status_code == 201
    data = response.json()
    assert "data" in data
    assert "access_token" in data["data"]
    assert "refresh_token" in data["data"]
    assert data["data"]["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_signup_duplicate_email(client: AsyncClient):
    # First signup
    await client.post(
        "/api/v1/auth/signup",
        json={
            "email": "dup@example.com",
            "password": "password123",
            "nickname": "User1",
        },
    )
    # Second signup with same email
    response = await client.post(
        "/api/v1/auth/signup",
        json={
            "email": "dup@example.com",
            "password": "password456",
            "nickname": "User2",
        },
    )
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_login(client: AsyncClient):
    # Signup first
    await client.post(
        "/api/v1/auth/signup",
        json={
            "email": "login@example.com",
            "password": "password123",
            "nickname": "LoginUser",
        },
    )
    # Login
    response = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "login@example.com",
            "password": "password123",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "data" in data
    assert "access_token" in data["data"]


@pytest.mark.asyncio
async def test_login_invalid_credentials(client: AsyncClient):
    response = await client.post(
        "/api/v1/auth/login",
        json={
            "email": "nonexistent@example.com",
            "password": "wrongpassword",
        },
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_refresh_token(client: AsyncClient):
    # Signup
    signup_resp = await client.post(
        "/api/v1/auth/signup",
        json={
            "email": "refresh@example.com",
            "password": "password123",
            "nickname": "RefreshUser",
        },
    )
    refresh_token = signup_resp.json()["data"]["refresh_token"]

    # Refresh
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data["data"]
    assert "refresh_token" in data["data"]


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient):
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["data"]["status"] == "ok"


@pytest.mark.asyncio
async def test_get_me(client: AsyncClient):
    # Signup
    signup_resp = await client.post(
        "/api/v1/auth/signup",
        json={
            "email": "me@example.com",
            "password": "password123",
            "nickname": "MeUser",
        },
    )
    token = signup_resp.json()["data"]["access_token"]

    # Get profile
    response = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert data["email"] == "me@example.com"
    assert data["profile"]["nickname"] == "MeUser"
