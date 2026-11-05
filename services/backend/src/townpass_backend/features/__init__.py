"""Feature packages, discovered automatically - same idea as the web's src/features/.

A feature is a package features/<name>/ (copy features/_template). Its __init__.py exposes:
  router           APIRouter, mounted on the app
  seed(session)    optional, runs at startup (idempotent: check before inserting)
and anything other features may use (its PUBLIC interface, e.g. auth exposes CurrentUser).

Inside the package, layers only call downwards:
  api.py (HTTP) -> service.py (logic) -> repo.py (data) -> models.py (tables)
  schemas.py = request/response types shared by api and service
Helpers named `__something` are private to their file. Packages starting with "_" are skipped.
"""

import importlib
import pkgutil
from types import ModuleType

modules: list[ModuleType] = [
    importlib.import_module(f"{__name__}.{m.name}")
    for m in sorted(pkgutil.iter_modules(__path__), key=lambda m: m.name)
    if not m.name.startswith("_")
]
