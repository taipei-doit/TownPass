"""Database: engine, session dependency and ADDITIVE schema sync.

DATABASE_URL decides the database:
  - unset          -> local SQLite file ./dev.db (teammates need nothing installed)
  - postgres://... -> Postgres (Render injects this; the driver prefix is fixed up below)

Dynamic schema (team rule): each module declares only the columns IT needs in its models.py.
On startup `sync_schema()` creates missing tables and ADDS missing columns/indexes.
It never drops, renames or changes types - existing data is always kept.
  - new columns are added NULL-able; a scalar default becomes a server DEFAULT so old rows get it
  - renaming a field = a new column (the old one stays, unused)
"""

import logging
from collections.abc import Iterator
from typing import Annotated, Any

from fastapi import Depends
from sqlalchemy import Column, inspect, text
from sqlalchemy.engine import Dialect
from sqlalchemy.pool import StaticPool
from sqlmodel import Session, SQLModel, create_engine

from townpass_backend.config import DATABASE_URL_RAW

log = logging.getLogger("townpass.db")


def __normalise_url(url: str) -> str:
    # Render/Heroku style URLs -> SQLAlchemy + psycopg 3 driver
    for prefix in ("postgres://", "postgresql://"):
        if url.startswith(prefix):
            return "postgresql+psycopg://" + url[len(prefix) :]
    return url


DATABASE_URL = __normalise_url(DATABASE_URL_RAW)

if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool if ":memory:" in DATABASE_URL else None,  # in-memory DB shares one connection
    )
else:
    # pool_pre_ping: survive Render's free Postgres dropping idle connections
    engine = create_engine(DATABASE_URL, pool_pre_ping=True, pool_size=5, max_overflow=5)


def get_session() -> Iterator[Session]:
    with Session(engine) as session:
        yield session


SessionDep = Annotated[Session, Depends(get_session)]


def sync_schema() -> list[str]:
    """Create missing tables, add missing columns and indexes. Returns what changed."""
    SQLModel.metadata.create_all(engine)
    changes: list[str] = []
    insp = inspect(engine)
    with engine.begin() as conn:
        for table in SQLModel.metadata.sorted_tables:
            existing = {c["name"] for c in insp.get_columns(table.name)}
            for col in table.columns:
                if col.name in existing:
                    continue
                if col.primary_key:
                    log.warning("cannot add primary key column %s.%s - skipped", table.name, col.name)
                    continue
                conn.execute(text(__add_column_ddl(table.name, col, engine.dialect)))
                changes.append(f"{table.name}.{col.name}")
            for idx in table.indexes:
                idx.create(conn, checkfirst=True)
    for c in changes:
        log.info("schema sync: added column %s", c)
    return changes


def __add_column_ddl(table: str, col: Column[Any], dialect: Dialect) -> str:
    prep = dialect.identifier_preparer
    ddl = f"ALTER TABLE {prep.quote(table)} ADD COLUMN {prep.quote(col.name)} {col.type.compile(dialect=dialect)}"
    default = __scalar_default(col)
    if default is not None:
        ddl += f" DEFAULT {default}"
    return ddl


def __scalar_default(col: Column[Any]) -> str | None:
    d = col.default
    if d is None or not d.is_scalar:
        return None
    value = d.arg
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    return None
