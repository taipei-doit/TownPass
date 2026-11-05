"""PRESENTATION (HTTP) - FastAPI dependencies other features use to protect endpoints.

from townpass_backend.features.auth import CurrentUser
@router.get("/mine")
def mine(user: CurrentUser): ...
"""

from typing import Annotated

from fastapi import Depends, Header, HTTPException, status

from townpass_backend.db import SessionDep

from . import service
from .models import AppUser


def current_user(session: SessionDep, authorization: Annotated[str | None, Header()] = None) -> AppUser:
    token = (authorization or "").removeprefix("Bearer ").strip()
    user = service.user_from_token(session, token) if token else None
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="not logged in",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


CurrentUser = Annotated[AppUser, Depends(current_user)]
