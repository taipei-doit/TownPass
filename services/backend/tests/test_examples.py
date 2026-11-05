"""Example feature: public reads + a protected, per-user resource (favourites)."""

from conftest import USER_A, USER_B, AuthHeaders
from fastapi.testclient import TestClient


def test_places_public(client: TestClient) -> None:
    places = client.get("/examples/places").json()
    assert places[0]["name"] == "範例公園" and places[0]["tags"] == ["免費", "無障礙"]
    assert len(client.get("/examples/places", params={"category": "圖書館"}).json()) == 1
    assert client.get(f"/examples/places/{places[0]['id']}").json()["notices"][0]["title"] == "開放時間"
    assert client.get("/examples/places/9999").status_code == 404


def test_favorites_require_login(client: TestClient) -> None:
    assert client.get("/examples/favorites").status_code == 401
    assert client.put("/examples/favorites/1").status_code == 401
    assert client.delete("/examples/favorites/1").status_code == 401


def test_favorites_are_per_user(client: TestClient, auth_headers: AuthHeaders) -> None:
    a, b = auth_headers(USER_A), auth_headers(USER_B)
    for pid in client.get("/examples/favorites", headers=a).json():  # clean slate
        client.delete(f"/examples/favorites/{pid}", headers=a)

    assert client.put("/examples/favorites/1", headers=a).status_code == 204
    assert client.put("/examples/favorites/1", headers=a).status_code == 204  # idempotent
    assert client.get("/examples/favorites", headers=a).json() == [1]
    assert 1 not in client.get("/examples/favorites", headers=b).json()  # B can't see A's data

    assert client.delete("/examples/favorites/1", headers=b).status_code == 204  # B deleting ≠ A's
    assert client.get("/examples/favorites", headers=a).json() == [1]

    assert client.delete("/examples/favorites/1", headers=a).status_code == 204
    assert client.get("/examples/favorites", headers=a).json() == []


def test_favorite_unknown_place_404(client: TestClient, auth_headers: AuthHeaders) -> None:
    assert client.put("/examples/favorites/9999", headers=auth_headers(USER_A)).status_code == 404


def test_template_feature_is_not_mounted(client: TestClient) -> None:
    assert client.get("/template/items").status_code == 404
