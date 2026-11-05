from fastapi.testclient import TestClient

from townpass_backend.main import app


def test_health() -> None:
    assert TestClient(app).get("/health").json() == {"status": "ok"}
