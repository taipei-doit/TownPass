"""INTERFACE TYPES - request/response models of this feature."""

from pydantic import BaseModel


class ItemOut(BaseModel):
    id: int
    name: str
