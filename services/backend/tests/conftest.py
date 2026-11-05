import os
from collections.abc import Callable, Iterator

# Must be set before the app (and its engine) is imported.
# CI also runs the suite against a real Postgres via TEST_DATABASE_URL.
os.environ["DATABASE_URL"] = os.getenv("TEST_DATABASE_URL", "sqlite:///:memory:")
os.environ.setdefault("SECRET_KEY", "test-secret")

import pytest
from fastapi.testclient import TestClient

from townpass_backend.main import app

# Test accounts. NEVER use a real TownPass account, real names or real ID numbers in tests.
USER_A = {"townpass_id": "test-user-a", "name": "測試甲"}
USER_B = {"townpass_id": "test-user-b", "name": "測試乙"}

AuthHeaders = Callable[[dict[str, str]], dict[str, str]]


@pytest.fixture(scope="session")
def client() -> Iterator[TestClient]:
    with TestClient(app) as c:  # `with` runs the lifespan -> schema sync + seed data
        yield c


@pytest.fixture
def auth_headers(client: TestClient) -> AuthHeaders:
    """auth_headers(USER_A) -> {"Authorization": "Bearer ..."} for that test user."""

    def make(user: dict[str, str]) -> dict[str, str]:
        res = client.post("/auth/login", json=user)
        assert res.status_code == 200, res.text
        return {"Authorization": f"Bearer {res.json()['token']}"}

    return make
