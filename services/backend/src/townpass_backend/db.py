"""Database setup.

DATABASE_URL decides the database:
  - unset            -> local SQLite file ./dev.db (no install needed for teammates)
  - postgres://...   -> Postgres (Render injects this; the driver prefix is fixed up below)

Tables are created on startup from SQLModel classes (no migration tool - fine for a
two-day hackathon; add Alembic before production).
"""

import os
from collections.abc import Iterator
from typing import Annotated

from fastapi import Depends
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine


def _database_url() -> str:
    url = os.getenv("DATABASE_URL", "sqlite:///./dev.db")
    # Render/Heroku style URLs -> SQLAlchemy + psycopg 3 driver
    for prefix in ("postgres://", "postgresql://"):
        if url.startswith(prefix):
            return "postgresql+psycopg://" + url[len(prefix) :]
    return url


DATABASE_URL = _database_url()

if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False},
        # in-memory DB (tests) must share one connection
        poolclass=StaticPool if ":memory:" in DATABASE_URL else None,
    )
else:
    # pool_pre_ping: survive Render's free Postgres dropping idle connections
    engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_size=5, max_overflow=5)


def init_db() -> None:
    # Import feature modules first so their tables are registered on SQLModel.metadata
    from townpass_backend import features  # noqa: F401

    SQLModel.metadata.create_all(engine)


def get_session() -> Iterator[Session]:
    with Session(engine) as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]
