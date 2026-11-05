import os

# Must be set before the app (and its engine) is imported.
# CI also runs the suite against a real Postgres via TEST_DATABASE_URL.
os.environ["DATABASE_URL"] = os.getenv("TEST_DATABASE_URL", "sqlite:///:memory:")

import pytest
from fastapi.testclient import TestClient

from townpass_backend.main import app


@pytest.fixture(scope="session")
def client() -> TestClient:
    with TestClient(app) as c:  # `with` runs the lifespan -> tables + seed data
        yield c
