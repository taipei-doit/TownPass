"""DATA LAYER - example feature queries. No business rules here."""

from sqlmodel import Session, col, select

from .models import Favorite, Place


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


def favorite_place_ids(session: Session, user_id: int) -> list[int]:
    stmt = select(Favorite.place_id).where(Favorite.user_id == user_id).order_by(col(Favorite.id))
    return list(session.exec(stmt))


def get_favorite(session: Session, user_id: int, place_id: int) -> Favorite | None:
    stmt = select(Favorite).where(Favorite.user_id == user_id, Favorite.place_id == place_id)
    return session.exec(stmt).first()


def add_favorite(session: Session, user_id: int, place_id: int) -> None:
    session.add(Favorite(user_id=user_id, place_id=place_id))
    session.commit()


def delete_favorite(session: Session, fav: Favorite) -> None:
    session.delete(fav)
    session.commit()
