"""auth - PUBLIC interface. Other features import only from here.

from townpass_backend.features.auth import CurrentUser   # protect an endpoint
"""

from .api import router
from .deps import CurrentUser
from .models import AppUser

__all__ = ["AppUser", "CurrentUser", "router"]
