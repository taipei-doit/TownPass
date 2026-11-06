"""Example feature: public reads, and proof that optional add-ons are not mounted by default."""

from fastapi.testclient import TestClient


def test_places_public(client: TestClient) -> None:
    places = client.get("/examples/places").json()
    assert places[0]["name"] == "範例公園" and places[0]["tags"] == ["免費", "無障礙"]
    assert len(client.get("/examples/places", params={"category": "圖書館"}).json()) == 1
    assert client.get(f"/examples/places/{places[0]['id']}").json()["notices"][0]["title"] == "開放時間"
    assert client.get("/examples/places/9999").status_code == 404


def test_core_app_has_no_addons(client: TestClient) -> None:
    """Add-ons are opt-in: the deployed core app must not expose /auth or favourites."""
    assert client.post("/auth/login", json={"townpass_id": "x"}).status_code == 404
    assert client.get("/examples/favorites").status_code == 404


def test_template_feature_is_not_mounted(client: TestClient) -> None:
    assert client.get("/template/items").status_code == 404
