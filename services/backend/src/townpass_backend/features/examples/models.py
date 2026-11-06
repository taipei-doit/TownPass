"""DATA - tables owned by the example feature (only the columns it needs)."""

from typing import Any

from sqlalchemy import JSON, Column
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
