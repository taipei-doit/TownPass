"""PRESENTATION (HTTP) - example feature endpoints. Only calls service; maps errors to HTTP."""

from fastapi import APIRouter, HTTPException, status

from townpass_backend.db import SessionDep

from . import service
from .schemas import PlaceOut

router = APIRouter(prefix="/examples", tags=["examples"])


@router.get("/places")
def list_places(session: SessionDep, category: str | None = None) -> list[PlaceOut]:
    return service.list_places(session, category)


@router.get("/places/{place_id}")
def get_place(place_id: int, session: SessionDep) -> PlaceOut:
    try:
        return service.get_place(session, place_id)
    except service.NotFound as e:
        raise HTTPException(status.HTTP_404_NOT_FOUND, str(e)) from e
