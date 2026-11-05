"""PRESENTATION (HTTP) - open-data proxy (avoids CORS problems in the WebView)."""

from typing import Any

from fastapi import APIRouter, HTTPException, status

from . import service

router = APIRouter(prefix="/opendata", tags=["opendata"])


@router.get("/taipei/{resource_id}")
async def taipei_dataset(resource_id: str, limit: int = 100, offset: int = 0) -> Any:
    try:
        return await service.taipei_dataset(resource_id, limit, offset)
    except service.UpstreamError as e:
        raise HTTPException(status.HTTP_502_BAD_GATEWAY, str(e)) from e
