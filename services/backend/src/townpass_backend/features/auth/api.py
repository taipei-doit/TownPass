"""PRESENTATION (HTTP) - auth endpoints. Only calls service."""

from fastapi import APIRouter

from townpass_backend.db import SessionDep

from . import service
from .deps import CurrentUser
from .schemas import LoginRequest, TokenOut, UserOut

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login")
def login(req: LoginRequest, session: SessionDep) -> TokenOut:
    """Exchange the TownPass identity (id + display name only) for our session token."""
    return service.login(session, req)


@router.get("/me")
def me(user: CurrentUser) -> UserOut:
    return service.to_out(user)
