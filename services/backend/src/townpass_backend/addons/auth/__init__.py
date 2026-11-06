"""ADD-ON: auth (optional, OFF by default). Public interface - import only from this package.

TownPass identity (id + display name only) -> our HMAC-signed token; `CurrentUser` protects endpoints.
Core code never imports this, so nothing (routes, tables) exists until a team enables it - and
only after writing the test plan and demo script for the feature that needs login.

Enable:
  1. Create  features/account/__init__.py  containing:
         from townpass_backend.addons.auth import router
         __all__ = ["router"]
     -> /auth/login and /auth/me are mounted, table app_user is created on startup.
  2. In the feature that needs login:
         from townpass_backend.addons.auth import CurrentUser
         def endpoint(user: CurrentUser, session: SessionDep): ...   # filter data by user.id
  3. Production: SECRET_KEY env var (render.yaml already generates one).
Tests: services/backend/tests/test_addon_auth.py (A1-A10 login checklist).
Trust model: the TownPass id is NOT cryptographically verified - demo only.
"""

from .api import router
from .deps import CurrentUser
from .models import AppUser

__all__ = ["AppUser", "CurrentUser", "router"]
