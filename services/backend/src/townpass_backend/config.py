"""Settings from environment variables (Render sets them; local dev uses the defaults)."""

import logging
import os

log = logging.getLogger("townpass")

DATABASE_URL_RAW = os.getenv("DATABASE_URL", "sqlite:///./dev.db")
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")
TOKEN_TTL_SECONDS = int(os.getenv("TOKEN_TTL_SECONDS", str(7 * 24 * 3600)))

_DEV_SECRET = "dev-insecure-secret-change-me"
SECRET_KEY = os.getenv("SECRET_KEY", _DEV_SECRET)
if SECRET_KEY == _DEV_SECRET and not DATABASE_URL_RAW.startswith("sqlite"):
    log.warning("SECRET_KEY is not set - tokens are forgeable. Set it in Render (render.yaml generates one).")
