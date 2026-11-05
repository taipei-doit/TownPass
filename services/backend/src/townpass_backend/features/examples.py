"""Example feature backing the web's src/features/example. Delete once real features exist.

Shows: a table with JSON columns, idempotent seed data, list + detail endpoints.
"""

from typing import Any

from fastapi import APIRouter, HTTPException
from sqlalchemy import JSON, Column
from sqlmodel import Field, Session, SQLModel, select

from townpass_backend.db import SessionDep

router = APIRouter(prefix="/examples", tags=["examples"])


class Place(SQLModel, table=True):
    __tablename__ = "example_place"

    id: int | None = Field(default=None, primary_key=True)
    name: str
    district: str = Field(index=True)
    category: str = Field(index=True)
    address: str
    hours: str
    lat: float
    lng: float
    tags: list[str] = Field(default_factory=list, sa_column=Column(JSON))
    notices: list[dict[str, Any]] = Field(default_factory=list, sa_column=Column(JSON))


@router.get("/places")
def list_places(session: SessionDep, category: str | None = None) -> list[Place]:
    stmt = select(Place).order_by(Place.id)
    if category:
        stmt = stmt.where(Place.category == category)
    return list(session.exec(stmt))


@router.get("/places/{place_id}")
def get_place(place_id: int, session: SessionDep) -> Place:
    place = session.get(Place, place_id)
    if not place:
        raise HTTPException(status_code=404, detail="place not found")
    return place


SEED = [
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


def seed(session: Session) -> None:
    if session.exec(select(Place).limit(1)).first() is None:
        session.add_all([p.model_copy() for p in SEED])
        session.commit()
