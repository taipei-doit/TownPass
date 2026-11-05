"""DATA - tables owned by the example feature (only the columns it needs)."""

from datetime import UTC, datetime
from typing import Any

from sqlalchemy import JSON, Column, UniqueConstraint
from sqlmodel import Field, SQLModel


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


class Favorite(SQLModel, table=True):
    __tablename__ = "example_favorite"
    __table_args__ = (UniqueConstraint("user_id", "place_id"),)

    id: int | None = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="app_user.id", index=True)
    place_id: int = Field(foreign_key="example_place.id")
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
