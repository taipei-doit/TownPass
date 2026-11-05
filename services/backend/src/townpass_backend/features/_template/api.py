"""PRESENTATION (HTTP) - only calls service. Protect endpoints with CurrentUser when needed."""

from fastapi import APIRouter

from townpass_backend.db import SessionDep

# from townpass_backend.features.auth import CurrentUser
from . import service
from .schemas import ItemOut

router = APIRouter(prefix="/template", tags=["template"])


@router.get("/items")
def list_items(session: SessionDep) -> list[ItemOut]:
    return service.list_items(session)
