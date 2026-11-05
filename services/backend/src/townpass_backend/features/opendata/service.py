"""LOGIC LAYER - open data. Public interface for other features: taipei_dataset()."""

from typing import Any

import httpx

from . import repo


class UpstreamError(Exception):
    pass


async def taipei_dataset(resource_id: str, limit: int = 100, offset: int = 0) -> Any:
    try:
        return await repo.fetch_json(
            repo.DATA_TAIPEI.format(rid=resource_id),
            {"scope": "resourceAquire", "limit": limit, "offset": offset},
        )
    except httpx.HTTPError as exc:
        raise UpstreamError(f"data.taipei error: {exc}") from exc
