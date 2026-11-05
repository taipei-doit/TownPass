"""Feature modules, discovered automatically - same idea as the web's src/features/.

Add a file features/<name>.py that defines `router = APIRouter(prefix="/<name>", tags=["<name>"])`
and it is mounted on the app. Optional `seed(session)` runs once at startup (use it to load
open data or demo rows). Files starting with "_" are skipped (see _template.py).
Each teammate owns their own file -> no merge conflicts in main.py.
"""

import importlib
import pkgutil
from types import ModuleType

modules: list[ModuleType] = [
    importlib.import_module(f"{__name__}.{m.name}")
    for m in sorted(pkgutil.iter_modules(__path__), key=lambda m: m.name)
    if not m.name.startswith("_")
]
