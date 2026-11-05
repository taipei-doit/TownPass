"""INTERFACE TYPES - example feature API."""

from typing import Any

from pydantic import BaseModel


class PlaceOut(BaseModel):
    id: int
    name: str
    district: str
    category: str
    address: str
    hours: str
    lat: float
    lng: float
    tags: list[str]
    notices: list[dict[str, Any]]
