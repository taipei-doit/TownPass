"""ADD-ON auth: login verification checklist A1-A10, run against an app with the add-on ENABLED
exactly as the add-on's __init__.py describes (a feature re-exports its router).

The core app does not include auth (see test_examples.test_core_app_has_no_addons).
"""

from collections.abc import Callable, Iterator

import pytest
from fastapi import APIRouter, FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import text
from sqlmodel import Session

from townpass_backend import config
from townpass_backend.addons.auth import CurrentUser, service
from townpass_backend.addons.auth import router as auth_router
from townpass_backend.addons.auth.repo import get_by_townpass_id
from townpass_backend.db import SessionDep, engine, sync_schema

# Test accounts. NEVER use a real TownPass account, real names or real ID numbers in tests.
USER_A = {"townpass_id": "test-user-a", "name": "測試甲"}
USER_B = {"townpass_id": "test-user-b", "name": "測試乙"}

AuthHeaders = Callable[[dict[str, str]], dict[str, str]]

# A protected, per-user resource - stands in for "the feature that needs login".
_notes = APIRouter(prefix="/test-notes")
_store: dict[int, set[str]] = {}


@_notes.get("")
def my_notes(user: CurrentUser) -> list[str]:
    return sorted(_store.get(user.id or 0, set()))


@_notes.put("/{note}", status_code=204)
def add_note(note: str, user: CurrentUser) -> None:
    _store.setdefault(user.id or 0, set()).add(note)


@_notes.delete("/{note}", status_code=204)
def delete_note(note: str, user: CurrentUser, session: SessionDep) -> None:
    session.exec(text("SELECT 1"))  # type: ignore[call-overload]
    _store.get(user.id or 0, set()).discard(note)


@pytest.fixture(scope="module")
def app_client() -> Iterator[TestClient]:
    sync_schema()  # add-on models are registered by the import above -> creates app_user
    app = FastAPI()
    app.include_router(auth_router)
    app.include_router(_notes)
    with TestClient(app) as c:
        yield c


@pytest.fixture
def auth_headers(app_client: TestClient) -> AuthHeaders:
    def make(user: dict[str, str]) -> dict[str, str]:
        res = app_client.post("/auth/login", json=user)
        assert res.status_code == 200, res.text
        return {"Authorization": f"Bearer {res.json()['token']}"}

    return make


def test_a1_no_token_is_401(app_client: TestClient) -> None:
    for r in (app_client.get("/auth/me"), app_client.get("/test-notes")):
        assert r.status_code == 401 and r.headers["WWW-Authenticate"] == "Bearer"


def test_a2_garbage_and_tampered_tokens_rejected(app_client: TestClient, auth_headers: AuthHeaders) -> None:
    token = auth_headers(USER_A)["Authorization"].removeprefix("Bearer ")
    body, sig = token.split(".")
    for bad in ["nonsense", f"{body}.{sig[:-2]}xx", f"{body[:-2]}xx.{sig}", ".", ""]:
        assert app_client.get("/auth/me", headers={"Authorization": f"Bearer {bad}"}).status_code == 401, bad


def test_a3_expired_token_rejected(app_client: TestClient, auth_headers: AuthHeaders) -> None:
    auth_headers(USER_A)
    with Session(engine) as s:
        uid = get_by_townpass_id(s, USER_A["townpass_id"]).id  # type: ignore[union-attr]
    expired = service.issue_token_for_tests(uid, ttl=-1)  # type: ignore[arg-type]
    assert app_client.get("/auth/me", headers={"Authorization": f"Bearer {expired}"}).status_code == 401


def test_a4_token_signed_with_other_secret_rejected(
    app_client: TestClient, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(config, "SECRET_KEY", "attacker-secret")
    forged = service.issue_token_for_tests(1, ttl=3600)
    monkeypatch.undo()
    assert app_client.get("/auth/me", headers={"Authorization": f"Bearer {forged}"}).status_code == 401


def test_a5_valid_token_sees_own_identity(app_client: TestClient, auth_headers: AuthHeaders) -> None:
    me = app_client.get("/auth/me", headers=auth_headers(USER_B)).json()
    assert me["townpass_id"] == USER_B["townpass_id"]


def test_a6_a7_data_is_per_user_and_idempotent(app_client: TestClient, auth_headers: AuthHeaders) -> None:
    a, b = auth_headers(USER_A), auth_headers(USER_B)
    assert app_client.put("/test-notes/park", headers=a).status_code == 204
    assert app_client.put("/test-notes/park", headers=a).status_code == 204  # A7 idempotent
    assert app_client.get("/test-notes", headers=a).json() == ["park"]
    assert app_client.get("/test-notes", headers=b).json() == []  # A6 B can't see A's data
    assert app_client.delete("/test-notes/park", headers=b).status_code == 204
    assert app_client.get("/test-notes", headers=a).json() == ["park"]  # B can't delete A's data
    assert app_client.delete("/test-notes/park", headers=a).status_code == 204
    assert app_client.get("/test-notes", headers=a).json() == []


def test_a9_login_rejects_personal_data_fields(app_client: TestClient) -> None:
    """Data minimisation: the national ID / phone must never be accepted, even by mistake."""
    for extra in ({"idNo": "A123456789"}, {"phoneNo": "0912345678"}, {"email": "x@example.com"}):
        assert app_client.post("/auth/login", json={**USER_A, **extra}).status_code == 422, extra


def test_a9_login_validates_input(app_client: TestClient) -> None:
    for body in ({"townpass_id": ""}, {"townpass_id": "x" * 65}, {}):
        assert app_client.post("/auth/login", json=body).status_code == 422


def test_a10_same_townpass_id_same_user(app_client: TestClient) -> None:
    first = app_client.post("/auth/login", json=USER_A).json()["user"]["id"]
    again = app_client.post("/auth/login", json={**USER_A, "name": "改名"}).json()["user"]
    assert again["id"] == first and again["name"] == "改名"
