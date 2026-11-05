"""opendata - PUBLIC interface: router, and taipei_dataset() for other features' services."""

from .api import router
from .service import UpstreamError, taipei_dataset

__all__ = ["UpstreamError", "router", "taipei_dataset"]
