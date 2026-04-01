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


async def get_user_id(client: AsyncClient, token: str) -> str:
    """Helper: get the current user's ID."""
    resp = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    return resp.json()["data"]["id"]


async def create_program(client: AsyncClient, token: str, title: str = "Test Program") -> str:
    """Helper: create a program and return its ID."""
    resp = await client.post(
        "/api/v1/programs",
        json={"title": title, "status": "published", "program_type": "recorded"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 201
    return resp.json()["data"]["id"]


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# --- Favorites ---


@pytest.mark.asyncio
async def test_add_favorite(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    response = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["program_id"] == program_id


@pytest.mark.asyncio
async def test_add_favorite_duplicate(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    # First favorite
    resp1 = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id},
        headers=auth_headers(token),
    )
    assert resp1.status_code == 201

    # Duplicate favorite
    resp2 = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id},
        headers=auth_headers(token),
    )
    assert resp2.status_code == 409


@pytest.mark.asyncio
async def test_add_favorite_nonexistent_program(client: AsyncClient):
    token = await create_user_and_login(client)
    fake_id = str(uuid.uuid4())

    response = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": fake_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_remove_favorite(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    # Add favorite
    await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id},
        headers=auth_headers(token),
    )

    # Remove favorite
    response = await client.delete(
        f"/api/v1/social/favorites/{program_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_remove_favorite_not_found(client: AsyncClient):
    token = await create_user_and_login(client)
    fake_id = str(uuid.uuid4())

    response = await client.delete(
        f"/api/v1/social/favorites/{fake_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_list_favorites(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id1 = await create_program(client, token, title="Fav Program 1")
    program_id2 = await create_program(client, token, title="Fav Program 2")

    await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id1},
        headers=auth_headers(token),
    )
    await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id2},
        headers=auth_headers(token),
    )

    response = await client.get(
        "/api/v1/social/favorites",
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["data"]) == 2
    assert body["meta"]["total"] == 2


@pytest.mark.asyncio
async def test_list_favorites_empty(client: AsyncClient):
    token = await create_user_and_login(client)

    response = await client.get(
        "/api/v1/social/favorites",
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    assert len(response.json()["data"]) == 0
    assert response.json()["meta"]["total"] == 0


# --- Follows ---


@pytest.mark.asyncio
async def test_follow_user(client: AsyncClient):
    token_a = await create_user_and_login(client, email="a@example.com", nickname="UserA")
    token_b = await create_user_and_login(client, email="b@example.com", nickname="UserB")
    user_b_id = await get_user_id(client, token_b)

    response = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["following_id"] == user_b_id


@pytest.mark.asyncio
async def test_follow_duplicate(client: AsyncClient):
    token_a = await create_user_and_login(client, email="a2@example.com", nickname="UserA2")
    token_b = await create_user_and_login(client, email="b2@example.com", nickname="UserB2")
    user_b_id = await get_user_id(client, token_b)

    # First follow
    resp1 = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )
    assert resp1.status_code == 201

    # Duplicate follow
    resp2 = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )
    assert resp2.status_code == 409


@pytest.mark.asyncio
async def test_follow_self(client: AsyncClient):
    token = await create_user_and_login(client, email="self@example.com", nickname="SelfUser")
    user_id = await get_user_id(client, token)

    response = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_follow_nonexistent_user(client: AsyncClient):
    token = await create_user_and_login(client, email="follower@example.com", nickname="Follower")
    fake_id = str(uuid.uuid4())

    response = await client.post(
        "/api/v1/social/follows",
        json={"following_id": fake_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_unfollow_user(client: AsyncClient):
    token_a = await create_user_and_login(client, email="a3@example.com", nickname="UserA3")
    token_b = await create_user_and_login(client, email="b3@example.com", nickname="UserB3")
    user_b_id = await get_user_id(client, token_b)

    # Follow
    await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )

    # Unfollow
    response = await client.delete(
        f"/api/v1/social/follows/{user_b_id}",
        headers=auth_headers(token_a),
    )
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_unfollow_not_found(client: AsyncClient):
    token = await create_user_and_login(client, email="unfollower@example.com", nickname="Unfollower")
    fake_id = str(uuid.uuid4())

    response = await client.delete(
        f"/api/v1/social/follows/{fake_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_list_following(client: AsyncClient):
    token_a = await create_user_and_login(client, email="a4@example.com", nickname="UserA4")
    token_b = await create_user_and_login(client, email="b4@example.com", nickname="UserB4")
    token_c = await create_user_and_login(client, email="c4@example.com", nickname="UserC4")
    user_b_id = await get_user_id(client, token_b)
    user_c_id = await get_user_id(client, token_c)

    await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )
    await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_c_id},
        headers=auth_headers(token_a),
    )

    response = await client.get(
        "/api/v1/social/follows",
        headers=auth_headers(token_a),
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["data"]) == 2
    assert body["meta"]["total"] == 2


@pytest.mark.asyncio
async def test_list_followers(client: AsyncClient):
    token_a = await create_user_and_login(client, email="a5@example.com", nickname="UserA5")
    token_b = await create_user_and_login(client, email="b5@example.com", nickname="UserB5")
    user_a_id = await get_user_id(client, token_a)

    # B follows A
    await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_a_id},
        headers=auth_headers(token_b),
    )

    response = await client.get(
        "/api/v1/social/followers",
        headers=auth_headers(token_a),
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["data"]) == 1
    assert body["meta"]["total"] == 1
