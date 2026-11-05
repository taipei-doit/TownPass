"""TEMPLATE - copy this package to features/<name>/ (packages starting with "_" are ignored).

Then: rename prefix/tags/table names, declare the columns you need in models.py, write
service functions, expose them in api.py. Restart -> http://localhost:8000/docs shows the
new endpoints (that page is the API contract for the frontend). Missing tables/columns are
added automatically on startup (db.sync_schema). No LLM inference on the backend.
"""

from .api import router
from .service import seed

__all__ = ["router", "seed"]
