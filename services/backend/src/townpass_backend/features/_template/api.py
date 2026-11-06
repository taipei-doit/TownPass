"""PRESENTATION (HTTP) - only calls service. Login is an optional add-on (addons/auth); see its __init__.py before protecting endpoints."""

from fastapi import APIRouter

from townpass_backend.db import SessionDep

# Optional add-on (only after the team enabled it): from townpass_backend.addons.auth import CurrentUser
from . import service
from .schemas import ItemOut

router = APIRouter(prefix="/template", tags=["template"])


@router.get("/items")
def list_items(session: SessionDep) -> list[ItemOut]:
    return service.list_items(session)
