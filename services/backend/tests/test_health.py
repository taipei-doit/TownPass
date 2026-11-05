from fastapi.testclient import TestClient


def test_health(client: TestClient) -> None:
    body = client.get("/health").json()
    assert body["status"] == "ok"
    assert body["db"] in {"sqlite", "postgresql"}


def test_example_places(client: TestClient) -> None:
    places = client.get("/examples/places").json()
    assert [p["name"] for p in places][:1] == ["範例公園"]
    assert places[0]["tags"] == ["免費", "無障礙"]

    parks = client.get("/examples/places", params={"category": "圖書館"}).json()
    assert len(parks) == 1

    assert client.get(f"/examples/places/{places[0]['id']}").json()["notices"][0]["title"] == "開放時間"
    assert client.get("/examples/places/9999").status_code == 404


def test_template_feature_is_not_mounted(client: TestClient) -> None:
    assert client.get("/template/rows").status_code == 404
