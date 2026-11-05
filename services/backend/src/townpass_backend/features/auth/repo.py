"""DATA LAYER - auth persistence."""

from datetime import UTC, datetime

from sqlmodel import Session, select

from .models import AppUser


def get_user(session: Session, user_id: int) -> AppUser | None:
    return session.get(AppUser, user_id)


def get_by_townpass_id(session: Session, townpass_id: str) -> AppUser | None:
    return session.exec(select(AppUser).where(AppUser.townpass_id == townpass_id)).first()


def upsert_user(session: Session, townpass_id: str, name: str) -> AppUser:
    user = get_by_townpass_id(session, townpass_id) or AppUser(townpass_id=townpass_id)
    user.name = name
    user.last_login_at = datetime.now(UTC)
    session.add(user)
    session.commit()
    session.refresh(user)
    return user
