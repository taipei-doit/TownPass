"""DATA LAYER - external open-data APIs (HTTP) with a small in-memory cache.

data.taipei JSON API: https://data.taipei/api/v1/dataset/<resource_id>?scope=resourceAquire&limit=..&offset=..
Every dataset used must be listed in data/SOURCES.md and in the web feature's `sources`.
"""

import time
from typing import Any

import httpx

DATA_TAIPEI = "https://data.taipei/api/v1/dataset/{rid}"
__TTL_SECONDS = 600
__cache: dict[str, tuple[float, Any]] = {}


async def fetch_json(url: str, params: dict[str, Any] | None = None) -> Any:
    """GET a JSON URL, cached for 10 minutes so the demo survives flaky venue Wi-Fi."""
    key = __cache_key(url, params)
    hit = __cache.get(key)
    if hit and time.time() - hit[0] < __TTL_SECONDS:
        return hit[1]
    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()
    __cache[key] = (time.time(), data)
    return data


def __cache_key(url: str, params: dict[str, Any] | None) -> str:
    return url + "?" + "&".join(f"{k}={v}" for k, v in sorted((params or {}).items()))
