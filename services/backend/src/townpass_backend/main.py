"""TownPass microservice backend (wiring only - add features in features/, don't edit this file).

Run locally:  uv run python -m uvicorn townpass_backend.main:app --reload --host 0.0.0.0 --port 8000
API docs:     http://localhost:8000/docs   (the API contract for the frontend)

Competition rule: no LLM inference may happen here. If a feature needs an LLM it must run
on the phone. Normal backend work (DB, login, file storage, data sync) is fine.
"""

import logging
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from sqlmodel import Session

from townpass_backend import config, features
from townpass_backend.db import SessionDep, engine, sync_schema

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("townpass")


@asynccontextmanager
async def lifespan(_: FastAPI) -> AsyncIterator[None]:
    sync_schema()  # create tables / add new columns declared by any feature
    with Session(engine) as session:
        for mod in features.modules:
            if seed := getattr(mod, "seed", None):
                try:
                    seed(session)
                except Exception:  # one bad seed must not take the whole API down
                    session.rollback()
                    log.exception("seed failed in %s", mod.__name__)
    yield


app = FastAPI(title="TownPass microservice API", version="0.2.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=config.CORS_ORIGINS,  # "*" is fine for the hackathon; tighten before merging upstream
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health(session: SessionDep) -> dict[str, str]:
    """Also pings the DB. Call this ~5 min before the demo to wake Render's free instance."""
    session.exec(text("SELECT 1"))  # type: ignore[call-overload]
    return {"status": "ok", "db": engine.dialect.name}


for _mod in features.modules:
    if router := getattr(_mod, "router", None):
        app.include_router(router)
