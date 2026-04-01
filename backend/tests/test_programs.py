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
async def test_create_program(client: AsyncClient):
    token = await create_user_and_login(client)
    response = await client.post(
        "/api/v1/programs",
        json={
            "title": "My First Program",
            "description": "A test program",
            "status": "draft",
            "program_type": "recorded",
            "genre": "pop",
        },
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    data = response.json()["data"]
    assert data["title"] == "My First Program"
    assert data["description"] == "A test program"
    assert data["status"] == "draft"
    assert data["genre"] == "pop"


@pytest.mark.asyncio
async def test_create_program_unauthenticated(client: AsyncClient):
    response = await client.post(
        "/api/v1/programs",
        json={"title": "Unauthorized Program"},
    )
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_list_programs(client: AsyncClient):
    token = await create_user_and_login(client)
    # Create two published programs
    for i in range(2):
        await client.post(
            "/api/v1/programs",
            json={
                "title": f"Program {i}",
                "status": "published",
                "program_type": "recorded",
            },
            headers=auth_headers(token),
        )

    response = await client.get(
        "/api/v1/programs",
        params={"page": 1, "per_page": 10, "status": "published"},
    )
    assert response.status_code == 200
    body = response.json()
    assert "data" in body
    assert "meta" in body
    assert len(body["data"]) == 2
    assert body["meta"]["total"] == 2
    assert body["meta"]["page"] == 1


@pytest.mark.asyncio
async def test_list_programs_pagination(client: AsyncClient):
    token = await create_user_and_login(client)
    for i in range(5):
        await client.post(
            "/api/v1/programs",
            json={
                "title": f"Program {i}",
                "status": "published",
                "program_type": "recorded",
            },
            headers=auth_headers(token),
        )

    response = await client.get(
        "/api/v1/programs",
        params={"page": 1, "per_page": 2, "status": "published"},
    )
    assert response.status_code == 200
    body = response.json()
    assert len(body["data"]) == 2
    assert body["meta"]["total"] == 5
    assert body["meta"]["has_next"] is True

    # Page 3 should have 1 item
    response2 = await client.get(
        "/api/v1/programs",
        params={"page": 3, "per_page": 2, "status": "published"},
    )
    assert response2.status_code == 200
    body2 = response2.json()
    assert len(body2["data"]) == 1
    assert body2["meta"]["has_next"] is False


@pytest.mark.asyncio
async def test_get_program_by_id(client: AsyncClient):
    token = await create_user_and_login(client)
    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "Specific Program", "status": "draft", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    program_id = create_resp.json()["data"]["id"]

    response = await client.get(f"/api/v1/programs/{program_id}")
    assert response.status_code == 200
    assert response.json()["data"]["id"] == program_id
    assert response.json()["data"]["title"] == "Specific Program"


@pytest.mark.asyncio
async def test_get_program_not_found(client: AsyncClient):
    fake_id = str(uuid.uuid4())
    response = await client.get(f"/api/v1/programs/{fake_id}")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_update_program_owner(client: AsyncClient):
    token = await create_user_and_login(client)
    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "Original Title", "status": "draft", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    program_id = create_resp.json()["data"]["id"]

    response = await client.put(
        f"/api/v1/programs/{program_id}",
        json={"title": "Updated Title", "description": "Updated description"},
        headers=auth_headers(token),
    )
    assert response.status_code == 200
    assert response.json()["data"]["title"] == "Updated Title"
    assert response.json()["data"]["description"] == "Updated description"


@pytest.mark.asyncio
async def test_update_program_not_owner(client: AsyncClient):
    token_owner = await create_user_and_login(client, email="owner@example.com", nickname="Owner")
    token_other = await create_user_and_login(client, email="other@example.com", nickname="Other")

    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "Owner Program", "status": "draft", "program_type": "recorded"},
        headers=auth_headers(token_owner),
    )
    program_id = create_resp.json()["data"]["id"]

    response = await client.put(
        f"/api/v1/programs/{program_id}",
        json={"title": "Hijacked Title"},
        headers=auth_headers(token_other),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_program_owner(client: AsyncClient):
    token = await create_user_and_login(client)
    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "To Delete", "status": "draft", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    program_id = create_resp.json()["data"]["id"]

    response = await client.delete(
        f"/api/v1/programs/{program_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 200

    # Verify it no longer exists
    get_resp = await client.get(f"/api/v1/programs/{program_id}")
    assert get_resp.status_code == 404


@pytest.mark.asyncio
async def test_delete_program_not_owner(client: AsyncClient):
    token_owner = await create_user_and_login(client, email="owner2@example.com", nickname="Owner2")
    token_other = await create_user_and_login(client, email="other2@example.com", nickname="Other2")

    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "Not Yours", "status": "draft", "program_type": "recorded"},
        headers=auth_headers(token_owner),
    )
    program_id = create_resp.json()["data"]["id"]

    response = await client.delete(
        f"/api/v1/programs/{program_id}",
        headers=auth_headers(token_other),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_search_programs_by_query(client: AsyncClient):
    token = await create_user_and_login(client)
    await client.post(
        "/api/v1/programs",
        json={"title": "Jazz Evening", "status": "published", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    await client.post(
        "/api/v1/programs",
        json={"title": "Rock Morning", "status": "published", "program_type": "recorded"},
        headers=auth_headers(token),
    )

    response = await client.get(
        "/api/v1/programs",
        params={"q": "Jazz", "status": "published"},
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert len(data) >= 1
    assert any("Jazz" in p["title"] for p in data)


@pytest.mark.asyncio
async def test_filter_programs_by_genre(client: AsyncClient):
    token = await create_user_and_login(client)
    await client.post(
        "/api/v1/programs",
        json={"title": "Pop Hits", "status": "published", "program_type": "recorded", "genre": "pop"},
        headers=auth_headers(token),
    )
    await client.post(
        "/api/v1/programs",
        json={"title": "Rock Classics", "status": "published", "program_type": "recorded", "genre": "rock"},
        headers=auth_headers(token),
    )

    response = await client.get(
        "/api/v1/programs",
        params={"genre": "pop", "status": "published"},
    )
    assert response.status_code == 200
    data = response.json()["data"]
    assert all(p["genre"] == "pop" for p in data)


@pytest.mark.asyncio
async def test_get_genres(client: AsyncClient):
    token = await create_user_and_login(client)
    await client.post(
        "/api/v1/programs",
        json={"title": "Genre Test", "status": "published", "program_type": "recorded", "genre": "jazz"},
        headers=auth_headers(token),
    )

    response = await client.get("/api/v1/programs/genres")
    assert response.status_code == 200
    assert "data" in response.json()


@pytest.mark.asyncio
async def test_get_templates(client: AsyncClient):
    response = await client.get("/api/v1/programs/templates")
    assert response.status_code == 200
    assert "data" in response.json()
    assert isinstance(response.json()["data"], list)


@pytest.mark.asyncio
async def test_create_from_template(client: AsyncClient):
    token = await create_user_and_login(client)

    # First get available templates
    templates_resp = await client.get("/api/v1/programs/templates")
    templates = templates_resp.json()["data"]

    if len(templates) == 0:
        pytest.skip("No templates available to test")

    template_name = templates[0]["name"]
    response = await client.post(
        "/api/v1/programs/from-template",
        json={"template_name": template_name},
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    data = response.json()["data"]
    assert "program" in data
    assert "message" in data


@pytest.mark.asyncio
async def test_create_from_template_not_found(client: AsyncClient):
    token = await create_user_and_login(client)
    response = await client.post(
        "/api/v1/programs/from-template",
        json={"template_name": "nonexistent_template"},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_record_play(client: AsyncClient):
    token = await create_user_and_login(client)
    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "Play Me", "status": "published", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    program_id = create_resp.json()["data"]["id"]

    # Record a play (authenticated)
    response = await client.post(
        f"/api/v1/programs/{program_id}/play",
        json={"duration_seconds": 120.5},
        headers=auth_headers(token),
    )
    assert response.status_code == 201
    assert response.json()["data"]["message"] == "再生を記録しました"


@pytest.mark.asyncio
async def test_record_play_anonymous(client: AsyncClient):
    token = await create_user_and_login(client)
    create_resp = await client.post(
        "/api/v1/programs",
        json={"title": "Anon Play", "status": "published", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    program_id = create_resp.json()["data"]["id"]

    # Record a play without authentication
    response = await client.post(f"/api/v1/programs/{program_id}/play")
    assert response.status_code == 201


@pytest.mark.asyncio
async def test_record_play_not_found(client: AsyncClient):
    fake_id = str(uuid.uuid4())
    response = await client.post(f"/api/v1/programs/{fake_id}/play")
    assert response.status_code == 404
