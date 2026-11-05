"""LOGIC LAYER - example feature. Public functions are the module interface; `__` helpers are private."""

from sqlmodel import Session

from . import repo
from .models import Place
from .schemas import PlaceOut


class NotFound(Exception):
    pass


def list_places(session: Session, category: str | None = None) -> list[PlaceOut]:
    return [__to_out(p) for p in repo.list_places(session, category)]


def get_place(session: Session, place_id: int) -> PlaceOut:
    return __to_out(__require_place(session, place_id))


def favorite_ids(session: Session, user_id: int) -> list[int]:
    return repo.favorite_place_ids(session, user_id)


def set_favorite(session: Session, user_id: int, place_id: int, on: bool) -> None:
    """Idempotent: adding twice or removing a missing favourite is not an error."""
    __require_place(session, place_id)
    fav = repo.get_favorite(session, user_id, place_id)
    if on and fav is None:
        repo.add_favorite(session, user_id, place_id)
    elif not on and fav is not None:
        repo.delete_favorite(session, fav)


def seed(session: Session) -> None:
    if not repo.has_any_place(session):
        repo.add_places(session, __seed_places())


def __require_place(session: Session, place_id: int) -> Place:
    place = repo.get_place(session, place_id)
    if place is None:
        raise NotFound(f"place {place_id} not found")
    return place


def __to_out(p: Place) -> PlaceOut:
    return PlaceOut.model_validate(p, from_attributes=True)


def __seed_places() -> list[Place]:
    # Clearly fake demo rows - replace with real open data on the day.
    return [
        Place(
            name="範例公園",
            district="信義區",
            category="公園",
            address="臺北市信義區市府路 1 號（範例）",
            hours="全天開放",
            lat=25.0375,
            lng=121.5637,
            tags=["免費", "無障礙"],
            notices=[
                {"title": "開放時間", "body": "全天開放，夜間照明至 23:00。"},
                {"title": "寵物", "body": "寵物須繫牽繩，並清理排泄物。"},
            ],
        ),
        Place(
            name="範例運動中心",
            district="大安區",
            category="運動中心",
            address="臺北市大安區（範例）",
            hours="06:00–22:00",
            lat=25.0263,
            lng=121.5434,
            tags=["需付費", "室內"],
            notices=[{"title": "入場規定", "body": "泳池須著泳帽，請自備。"}],
        ),
        Place(
            name="範例圖書館分館",
            district="中正區",
            category="圖書館",
            address="臺北市中正區（範例）",
            hours="08:30–21:00，週一休館",
            lat=25.0322,
            lng=121.5185,
            tags=["免費", "自習室"],
            notices=[{"title": "自習座位", "body": "採線上預約，保留 15 分鐘。"}],
        ),
    ]
