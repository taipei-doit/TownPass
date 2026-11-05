"""TownPass microservice backend.

Run locally:  uv run python -m uvicorn townpass_backend.main:app --reload --host 0.0.0.0 --port 8000
API docs:     http://localhost:8000/docs   (share this with the frontend - it is the API contract)

Competition rule: no LLM inference may happen here. If a feature needs an LLM it must run
on the phone. Normal backend work (DB, login, file storage, data sync) is fine.
"""

import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from townpass_backend import opendata

app = FastAPI(title="TownPass microservice API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    # Comma-separated list; "*" is fine for the hackathon, tighten before merging upstream.
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(opendata.router)
