"""DATA LAYER - queries only."""

from sqlmodel import Session, select

from .models import TemplateItem


def list_items(session: Session) -> list[TemplateItem]:
    return list(session.exec(select(TemplateItem)))


def add_items(session: Session, names: list[str]) -> None:
    session.add_all([TemplateItem(name=n) for n in names])
    session.commit()
