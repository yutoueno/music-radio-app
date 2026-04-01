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


async def create_program(client: AsyncClient, token: str, title: str = "Test Program") -> str:
    """Helper: create a program and return its ID."""
    resp = await client.post(
        "/api/v1/programs",
        json={"title": title, "status": "draft", "program_type": "recorded"},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 201
    return resp.json()["data"]["id"]


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_create_track(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    response = await client.post(
        "/api/v1/tracks",
        json={
            "program_id": program_id,
            "title": "Test Song",
            "artist_name": "Test Artist",
            "apple_music_track_id": "1234567890",
            "play_timing_seconds": 30.0,
            "duration_seconds": 240.0,
            "track_order": 1,
        },
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["title"] == "Test Song"
    assert data["artist_name"] == "Test Artist"
    assert data["apple_music_track_id"] == "1234567890"
    assert data["play_timing_seconds"] == 30.0
    assert data["track_order"] == 1


@pytest.mark.asyncio
async def test_create_track_not_owner(client: AsyncClient):
    token_owner = await create_user_and_login(client, email="owner@example.com", nickname="Owner")
    token_other = await create_user_and_login(client, email="other@example.com", nickname="Other")
    program_id = await create_program(client, token_owner)

    response = await client.post(
        "/api/v1/tracks",
        json={
            "program_id": program_id,
            "title": "Unauthorized Track",
            "artist_name": "Hacker",
            "track_order": 1,
        },
        headers=auth_headers(token_other),
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_list_tracks_for_program(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    # Create two tracks
    for i in range(2):
        await client.post(
            "/api/v1/tracks",
            json={
                "program_id": program_id,
                "title": f"Track {i}",
                "artist_name": f"Artist {i}",
                "track_order": i,
            },
            headers=auth_headers(token),
        )

    response = await client.get(f"/api/v1/tracks/program/{program_id}")
    assert response.status_code == 200
    data = response.json()["data"]
    assert len(data) == 2


@pytest.mark.asyncio
async def test_list_tracks_empty_program(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    response = await client.get(f"/api/v1/tracks/program/{program_id}")
    assert response.status_code == 200
    assert response.json()["data"] == []


@pytest.mark.asyncio
async def test_update_track(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    create_resp = await client.post(
        "/api/v1/tracks",
        json={
            "program_id": program_id,
            "title": "Original Track",
            "artist_name": "Original Artist",
            "track_order": 0,
        },
        headers=auth_headers(token),
    )
    track_id = create_resp.json()["data"]["id"]

    response = await client.put(
        f"/api/v1/tracks/{track_id}",
        json={"title": "Updated Track", "play_timing_seconds": 60.0},
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert data["title"] == "Updated Track"
    assert data["play_timing_seconds"] == 60.0


@pytest.mark.asyncio
async def test_update_track_not_owner(client: AsyncClient):
    token_owner = await create_user_and_login(client, email="owner2@example.com", nickname="Owner2")
    token_other = await create_user_and_login(client, email="other2@example.com", nickname="Other2")
    program_id = await create_program(client, token_owner)

    create_resp = await client.post(
        "/api/v1/tracks",
        json={
            "program_id": program_id,
            "title": "Owner Track",
            "artist_name": "Owner Artist",
            "track_order": 0,
        },
        headers=auth_headers(token_owner),
    )
    track_id = create_resp.json()["data"]["id"]

    response = await client.put(
        f"/api/v1/tracks/{track_id}",
        json={"title": "Hijacked"},
        headers=auth_headers(token_other),
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_update_track_not_found(client: AsyncClient):
    token = await create_user_and_login(client)
    fake_id = str(uuid.uuid4())

    response = await client.put(
        f"/api/v1/tracks/{fake_id}",
        json={"title": "Ghost Track"},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_track(client: AsyncClient):
    token = await create_user_and_login(client)
    program_id = await create_program(client, token)

    create_resp = await client.post(
        "/api/v1/tracks",
        json={
            "program_id": program_id,
            "title": "Delete Me",
            "artist_name": "Artist",
            "track_order": 0,
        },
        headers=auth_headers(token),
    )
    track_id = create_resp.json()["data"]["id"]

    response = await client.delete(
        f"/api/v1/tracks/{track_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 200

    # Verify deleted
    tracks_resp = await client.get(f"/api/v1/tracks/program/{program_id}")
    assert len(tracks_resp.json()["data"]) == 0


@pytest.mark.asyncio
async def test_delete_track_not_owner(client: AsyncClient):
    token_owner = await create_user_and_login(client, email="owner3@example.com", nickname="Owner3")
    token_other = await create_user_and_login(client, email="other3@example.com", nickname="Other3")
    program_id = await create_program(client, token_owner)

    create_resp = await client.post(
        "/api/v1/tracks",
        json={
            "program_id": program_id,
            "title": "Protected Track",
            "artist_name": "Artist",
            "track_order": 0,
        },
        headers=auth_headers(token_owner),
    )
    track_id = create_resp.json()["data"]["id"]

    response = await client.delete(
        f"/api/v1/tracks/{track_id}",
        headers=auth_headers(token_other),
    )
    assert response.status_code == 403


@pytest.mark.asyncio
async def test_delete_track_not_found(client: AsyncClient):
    token = await create_user_and_login(client)
    fake_id = str(uuid.uuid4())

    response = await client.delete(
        f"/api/v1/tracks/{fake_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 404
