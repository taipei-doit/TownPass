"""Dynamic, additive schema: a module adding a field must not lose existing rows."""

from fastapi.testclient import TestClient
from sqlalchemy import inspect, text
from sqlmodel import Field, SQLModel

from townpass_backend.db import engine, sync_schema


def test_new_columns_are_added_and_old_rows_kept(client: TestClient) -> None:  # client -> app started
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS zz_schema_probe"))
        conn.execute(text("CREATE TABLE zz_schema_probe (id INTEGER PRIMARY KEY, name VARCHAR NOT NULL)"))
        conn.execute(text("INSERT INTO zz_schema_probe (id, name) VALUES (1, 'old row')"))

    # A module now declares two extra fields it needs
    class ZzSchemaProbe(SQLModel, table=True):
        __tablename__ = "zz_schema_probe"
        id: int | None = Field(default=None, primary_key=True)
        name: str
        district: str | None = Field(default=None, index=True)
        visits: int = 0
        active: bool = True

    try:
        changes = sync_schema()
        assert {"zz_schema_probe.district", "zz_schema_probe.visits", "zz_schema_probe.active"} <= set(
            changes
        )
        cols = {c["name"] for c in inspect(engine).get_columns("zz_schema_probe")}
        assert {"id", "name", "district", "visits", "active"} <= cols
        with engine.connect() as conn:
            row = conn.execute(
                text("SELECT name, district, visits, active FROM zz_schema_probe WHERE id = 1")
            ).one()
        assert row[0] == "old row" and row[1] is None and row[2] == 0 and bool(row[3]) is True
        assert sync_schema() == []  # second run: nothing to do
    finally:
        SQLModel.metadata.remove(ZzSchemaProbe.__table__)  # type: ignore[attr-defined]
        with engine.begin() as conn:
            conn.execute(text("DROP TABLE IF EXISTS zz_schema_probe"))
