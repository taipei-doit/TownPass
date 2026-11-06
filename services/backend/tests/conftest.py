import os
from collections.abc import Iterator

# Must be set before the app (and its engine) is imported.
# CI also runs the suite against a real Postgres via TEST_DATABASE_URL.
os.environ["DATABASE_URL"] = os.getenv("TEST_DATABASE_URL", "sqlite:///:memory:")
os.environ.setdefault("SECRET_KEY", "test-secret")

import pytest
from fastapi.testclient import TestClient

from townpass_backend.main import app


@pytest.fixture(scope="session")
def client() -> Iterator[TestClient]:
    """The core app exactly as deployed (no add-ons)."""
    with TestClient(app) as c:  # `with` runs the lifespan -> schema sync + seed data
        yield c
