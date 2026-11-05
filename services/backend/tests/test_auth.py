"""Login verification checklist (docs/system/07-testing.md §3). Every item is one test."""

from conftest import USER_A, USER_B, AuthHeaders
from fastapi.testclient import TestClient
from sqlmodel import Session

from townpass_backend.db import engine
from townpass_backend.features.auth import service
from townpass_backend.features.auth.repo import get_by_townpass_id


def test_login_returns_token_and_user(client: TestClient) -> None:
    res = client.post("/auth/login", json=USER_A)
    assert res.status_code == 200
    body = res.json()
    assert body["token"] and body["user"]["townpass_id"] == USER_A["townpass_id"]


def test_login_is_idempotent_same_townpass_id_same_user(client: TestClient) -> None:
    first = client.post("/auth/login", json=USER_A).json()["user"]["id"]
    again = client.post("/auth/login", json={**USER_A, "name": "改名"}).json()["user"]
    assert again["id"] == first and again["name"] == "改名"


def test_me_requires_token(client: TestClient) -> None:
    res = client.get("/auth/me")
    assert res.status_code == 401
    assert res.headers["WWW-Authenticate"] == "Bearer"


def test_me_with_token(client: TestClient, auth_headers: AuthHeaders) -> None:
    assert client.get("/auth/me", headers=auth_headers(USER_B)).json()["townpass_id"] == USER_B["townpass_id"]


def test_garbage_and_tampered_tokens_rejected(client: TestClient, auth_headers: AuthHeaders) -> None:
    token = auth_headers(USER_A)["Authorization"].removeprefix("Bearer ")
    body, sig = token.split(".")
    for bad in ["nonsense", f"{body}.{sig[:-2]}xx", f"{body[:-2]}xx.{sig}", ".", ""]:
        assert client.get("/auth/me", headers={"Authorization": f"Bearer {bad}"}).status_code == 401, bad


def test_expired_token_rejected(client: TestClient) -> None:
    client.post("/auth/login", json=USER_A)
    with Session(engine) as s:
        uid = get_by_townpass_id(s, USER_A["townpass_id"]).id  # type: ignore[union-attr]
    expired = service.issue_token_for_tests(uid, ttl=-1)  # type: ignore[arg-type]
    assert client.get("/auth/me", headers={"Authorization": f"Bearer {expired}"}).status_code == 401


def test_token_signed_with_other_secret_rejected(client: TestClient, monkeypatch) -> None:
    from townpass_backend import config

    monkeypatch.setattr(config, "SECRET_KEY", "attacker-secret")
    forged = service.issue_token_for_tests(1, ttl=3600)
    monkeypatch.undo()
    assert client.get("/auth/me", headers={"Authorization": f"Bearer {forged}"}).status_code == 401


def test_login_rejects_personal_data_fields(client: TestClient) -> None:
    """Data minimisation: the national ID / phone must never be accepted, even by mistake."""
    for extra in ({"idNo": "A123456789"}, {"phoneNo": "0912345678"}, {"email": "x@example.com"}):
        assert client.post("/auth/login", json={**USER_A, **extra}).status_code == 422, extra


def test_login_validates_input(client: TestClient) -> None:
    assert client.post("/auth/login", json={"townpass_id": ""}).status_code == 422
    assert client.post("/auth/login", json={"townpass_id": "x" * 65}).status_code == 422
    assert client.post("/auth/login", json={}).status_code == 422
