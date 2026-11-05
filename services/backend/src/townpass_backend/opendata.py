"""Open data access with a small in-memory cache.

Rule reminder: core data must come from public open data and the source must be cited.
Every dataset you use goes in data/SOURCES.md (name, URL, licence, what we use it for).

data.taipei datasets expose a resource id; the JSON API is
  https://data.taipei/api/v1/dataset/<resource_id>?scope=resourceAquire&limit=..&offset=..
"""

import time
from typing import Any

import httpx
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/opendata", tags=["opendata"])

DATA_TAIPEI = "https://data.taipei/api/v1/dataset/{rid}"
_TTL_SECONDS = 600
_cache: dict[str, tuple[float, Any]] = {}


async def fetch_json(url: str, params: dict[str, Any] | None = None) -> Any:
    """GET a JSON URL, cached for 10 minutes so the demo survives flaky venue Wi-Fi."""
    key = url + "?" + "&".join(f"{k}={v}" for k, v in sorted((params or {}).items()))
    hit = _cache.get(key)
    if hit and time.time() - hit[0] < _TTL_SECONDS:
        return hit[1]
    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()
    _cache[key] = (time.time(), data)
    return data


@router.get("/taipei/{resource_id}")
async def taipei_dataset(resource_id: str, limit: int = 100, offset: int = 0) -> Any:
    """Proxy one data.taipei resource (avoids CORS issues in the WebView)."""
    try:
        return await fetch_json(
            DATA_TAIPEI.format(rid=resource_id),
            {"scope": "resourceAquire", "limit": limit, "offset": offset},
        )
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=502, detail=f"data.taipei error: {exc}") from exc
