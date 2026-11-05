"""LOGIC LAYER - public functions = the module interface. `__` helpers are private to this file."""

from sqlmodel import Session

from . import repo
from .models import TemplateItem
from .schemas import ItemOut


def list_items(session: Session) -> list[ItemOut]:
    return [__to_out(it) for it in repo.list_items(session)]


def seed(session: Session) -> None:
    """Runs at startup. Must be idempotent."""
    if not repo.list_items(session):
        repo.add_items(session, ["範例項目"])


def __to_out(it: TemplateItem) -> ItemOut:
    return ItemOut(id=it.id or 0, name=it.name)
