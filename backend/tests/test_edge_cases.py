"""Edge case tests for the Music Radio App backend API."""

import uuid

import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession


# --- Helpers ---


async def create_user_and_login(
    client: AsyncClient, email: str = "user@example.com", nickname: str = "TestUser"
) -> str:
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


async def create_program(
    client: AsyncClient, token: str, title: str = "Test Program", status: str = "published"
) -> str:
    """Helper: create a program and return its ID."""
    resp = await client.post(
        "/api/v1/programs",
        json={"title": title, "status": status, "program_type": "recorded"},
        headers=auth_headers(token),
    )
    assert resp.status_code == 201
    return resp.json()["data"]["id"]


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# =============================================================================
# 1. Auth Edge Cases
# =============================================================================


@pytest.mark.asyncio
async def test_login_wrong_password(client: AsyncClient):
    """Login with correct email but wrong password returns 401."""
    await create_user_and_login(client, email="wrongpw@example.com", nickname="WrongPW")

    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "wrongpw@example.com", "password": "definitelywrongpassword"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_login_nonexistent_email(client: AsyncClient):
    """Login with an email that has never been registered returns 401."""
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "ghost@example.com", "password": "password123"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_access_protected_endpoint_with_invalid_token(client: AsyncClient):
    """Accessing a protected endpoint with a garbage token returns 401."""
    response = await client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer this.is.not.a.valid.jwt"},
    )
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_access_protected_endpoint_without_token(client: AsyncClient):
    """Accessing a protected endpoint with no Authorization header returns 401/403."""
    response = await client.get("/api/v1/users/me")
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_signup_already_registered_email(client: AsyncClient):
    """Signup with an already-registered email returns 409."""
    await create_user_and_login(client, email="taken@example.com", nickname="First")

    response = await client.post(
        "/api/v1/auth/signup",
        json={"email": "taken@example.com", "password": "password456", "nickname": "Second"},
    )
    assert response.status_code == 409


@pytest.mark.asyncio
async def test_signup_invalid_email_format(client: AsyncClient):
    """Signup with an invalid email format returns 422 (validation error)."""
    response = await client.post(
        "/api/v1/auth/signup",
        json={"email": "not-an-email", "password": "password123", "nickname": "BadEmail"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_signup_missing_password(client: AsyncClient):
    """Signup without a password field returns 422."""
    response = await client.post(
        "/api/v1/auth/signup",
        json={"email": "nopw@example.com", "nickname": "NoPW"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_signup_password_too_short(client: AsyncClient):
    """Signup with a password shorter than min_length returns 422."""
    response = await client.post(
        "/api/v1/auth/signup",
        json={"email": "short@example.com", "password": "abc", "nickname": "ShortPW"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_refresh_with_invalid_token(client: AsyncClient):
    """Refresh with a garbage refresh token returns an error."""
    response = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": "not.a.real.refresh.token"},
    )
    assert response.status_code in (401, 422)


# =============================================================================
# 2. Program Edge Cases
# =============================================================================


@pytest.mark.asyncio
async def test_get_nonexistent_program(client: AsyncClient):
    """GET a program with a random UUID returns 404."""
    fake_id = str(uuid.uuid4())
    response = await client.get(f"/api/v1/programs/{fake_id}")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_update_program_not_owner(client: AsyncClient):
    """Updating someone else's program returns 404 (hides existence)."""
    token_owner = await create_user_and_login(client, email="progowner@example.com", nickname="ProgOwner")
    token_other = await create_user_and_login(client, email="progother@example.com", nickname="ProgOther")

    program_id = await create_program(client, token_owner, title="Owner's Program")

    response = await client.put(
        f"/api/v1/programs/{program_id}",
        json={"title": "Stolen Title"},
        headers=auth_headers(token_other),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_program_not_owner(client: AsyncClient):
    """Deleting someone else's program returns 404."""
    token_owner = await create_user_and_login(client, email="delowner@example.com", nickname="DelOwner")
    token_other = await create_user_and_login(client, email="delother@example.com", nickname="DelOther")

    program_id = await create_program(client, token_owner, title="Protected Program")

    response = await client.delete(
        f"/api/v1/programs/{program_id}",
        headers=auth_headers(token_other),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_create_program_missing_title(client: AsyncClient):
    """Creating a program without a title returns 422."""
    token = await create_user_and_login(client, email="notitle@example.com", nickname="NoTitle")

    response = await client.post(
        "/api/v1/programs",
        json={"status": "draft", "program_type": "recorded"},
        headers=auth_headers(token),
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_create_program_unauthenticated(client: AsyncClient):
    """Creating a program without auth returns 401/403."""
    response = await client.post(
        "/api/v1/programs",
        json={"title": "No Auth Program", "status": "draft", "program_type": "recorded"},
    )
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_pagination_page_zero(client: AsyncClient):
    """Requesting page=0 returns 422 because page must be >= 1."""
    response = await client.get(
        "/api/v1/programs",
        params={"page": 0, "per_page": 10, "status": "published"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_pagination_page_negative(client: AsyncClient):
    """Requesting page=-1 returns 422 because page must be >= 1."""
    response = await client.get(
        "/api/v1/programs",
        params={"page": -1, "per_page": 10, "status": "published"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_pagination_per_page_zero(client: AsyncClient):
    """Requesting per_page=0 returns 422 because per_page must be >= 1."""
    response = await client.get(
        "/api/v1/programs",
        params={"page": 1, "per_page": 0, "status": "published"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_pagination_per_page_exceeds_max(client: AsyncClient):
    """Requesting per_page > 100 returns 422 because per_page must be <= 100."""
    response = await client.get(
        "/api/v1/programs",
        params={"page": 1, "per_page": 999, "status": "published"},
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_update_nonexistent_program(client: AsyncClient):
    """Updating a program that doesn't exist returns 404."""
    token = await create_user_and_login(client, email="updghost@example.com", nickname="UpdGhost")
    fake_id = str(uuid.uuid4())

    response = await client.put(
        f"/api/v1/programs/{fake_id}",
        json={"title": "Ghost Program"},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_delete_nonexistent_program(client: AsyncClient):
    """Deleting a program that doesn't exist returns 404."""
    token = await create_user_and_login(client, email="delghost@example.com", nickname="DelGhost")
    fake_id = str(uuid.uuid4())

    response = await client.delete(
        f"/api/v1/programs/{fake_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 404


# =============================================================================
# 3. Social Edge Cases
# =============================================================================


@pytest.mark.asyncio
async def test_favorite_same_program_twice(client: AsyncClient):
    """Favoriting the same program twice returns 409 (conflict)."""
    token = await create_user_and_login(client, email="favtwice@example.com", nickname="FavTwice")
    program_id = await create_program(client, token, title="Fav Target")

    resp1 = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id},
        headers=auth_headers(token),
    )
    assert resp1.status_code == 201

    resp2 = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": program_id},
        headers=auth_headers(token),
    )
    assert resp2.status_code == 409


@pytest.mark.asyncio
async def test_unfavorite_program_not_favorited(client: AsyncClient):
    """Removing a favorite that was never added returns 404."""
    token = await create_user_and_login(client, email="unfavnone@example.com", nickname="UnfavNone")
    program_id = await create_program(client, token, title="Never Faved")

    response = await client.delete(
        f"/api/v1/social/favorites/{program_id}",
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_favorite_nonexistent_program(client: AsyncClient):
    """Favoriting a program that doesn't exist returns 404."""
    token = await create_user_and_login(client, email="favghost@example.com", nickname="FavGhost")
    fake_id = str(uuid.uuid4())

    response = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": fake_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_favorite_unauthenticated(client: AsyncClient):
    """Favoriting without authentication returns 401/403."""
    fake_id = str(uuid.uuid4())
    response = await client.post(
        "/api/v1/social/favorites",
        json={"program_id": fake_id},
    )
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_follow_yourself(client: AsyncClient):
    """Following yourself returns 400."""
    token = await create_user_and_login(client, email="narcissist@example.com", nickname="Narcissist")
    user_id = await get_user_id(client, token)

    response = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 400


@pytest.mark.asyncio
async def test_follow_same_user_twice(client: AsyncClient):
    """Following the same user twice returns 409 (conflict)."""
    token_a = await create_user_and_login(client, email="followa@example.com", nickname="FollowA")
    token_b = await create_user_and_login(client, email="followb@example.com", nickname="FollowB")
    user_b_id = await get_user_id(client, token_b)

    resp1 = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )
    assert resp1.status_code == 201

    resp2 = await client.post(
        "/api/v1/social/follows",
        json={"following_id": user_b_id},
        headers=auth_headers(token_a),
    )
    assert resp2.status_code == 409


@pytest.mark.asyncio
async def test_follow_nonexistent_user(client: AsyncClient):
    """Following a user that doesn't exist returns 404."""
    token = await create_user_and_login(client, email="followghost@example.com", nickname="FollowGhost")
    fake_id = str(uuid.uuid4())

    response = await client.post(
        "/api/v1/social/follows",
        json={"following_id": fake_id},
        headers=auth_headers(token),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_unfollow_user_not_followed(client: AsyncClient):
    """Unfollowing a user you never followed returns 404."""
    token_a = await create_user_and_login(client, email="unfollowa@example.com", nickname="UnfollowA")
    token_b = await create_user_and_login(client, email="unfollowb@example.com", nickname="UnfollowB")
    user_b_id = await get_user_id(client, token_b)

    response = await client.delete(
        f"/api/v1/social/follows/{user_b_id}",
        headers=auth_headers(token_a),
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_follow_unauthenticated(client: AsyncClient):
    """Following without authentication returns 401/403."""
    fake_id = str(uuid.uuid4())
    response = await client.post(
        "/api/v1/social/follows",
        json={"following_id": fake_id},
    )
    assert response.status_code in (401, 403)


# =============================================================================
# 4. Upload Edge Cases
# =============================================================================


@pytest.mark.asyncio
async def test_presigned_url_without_auth(client: AsyncClient):
    """Requesting a presigned upload URL without auth returns 401/403."""
    response = await client.post("/api/v1/upload/audio?file_extension=mp3")
    assert response.status_code in (401, 403)


@pytest.mark.asyncio
async def test_presigned_image_url_without_auth(client: AsyncClient):
    """Requesting a presigned image upload URL without auth returns 401/403."""
    response = await client.post("/api/v1/upload/image?file_extension=jpg")
    assert response.status_code in (401, 403)
