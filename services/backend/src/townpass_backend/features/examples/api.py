"""PRESENTATION (HTTP) - example feature endpoints. Only calls service; maps errors to HTTP."""

from fastapi import APIRouter, HTTPException, Response, status

from townpass_backend.db import SessionDep
from townpass_backend.features.auth import CurrentUser

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


@router.get("/favorites")
def my_favorites(user: CurrentUser, session: SessionDep) -> list[int]:
    """Place ids the CURRENT user saved. Requires login."""
    return service.favorite_ids(session, user.id or 0)


@router.put("/favorites/{place_id}", status_code=status.HTTP_204_NO_CONTENT)
def add_favorite(place_id: int, user: CurrentUser, session: SessionDep) -> Response:
    return __set(session, user.id or 0, place_id, True)


@router.delete("/favorites/{place_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_favorite(place_id: int, user: CurrentUser, session: SessionDep) -> Response:
    return __set(session, user.id or 0, place_id, False)


def __set(session: SessionDep, user_id: int, place_id: int, on: bool) -> Response:
    try:
        service.set_favorite(session, user_id, place_id, on)
    except service.NotFound as e:
        raise HTTPException(status.HTTP_404_NOT_FOUND, str(e)) from e
    return Response(status_code=status.HTTP_204_NO_CONTENT)
