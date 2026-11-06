"""DATA LAYER - example feature queries. No business rules here."""

from sqlmodel import Session, col, select

from .models import Place


def list_places(session: Session, category: str | None = None) -> list[Place]:
    stmt = select(Place).order_by(col(Place.id))
    if category:
        stmt = stmt.where(Place.category == category)
    return list(session.exec(stmt))


def get_place(session: Session, place_id: int) -> Place | None:
    return session.get(Place, place_id)


def has_any_place(session: Session) -> bool:
    return session.exec(select(Place.id).limit(1)).first() is not None


def add_places(session: Session, places: list[Place]) -> None:
    session.add_all(places)
    session.commit()
