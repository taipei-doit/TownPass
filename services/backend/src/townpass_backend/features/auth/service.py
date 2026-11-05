"""LOGIC LAYER - auth. Public: login(), user_from_token(). `__` helpers are private.

Trust model (see docs/system/01-decisions.md ADR-008): the TownPass app gives the web page the
user's account id; the page sends it here and gets our own signed token. The id itself is NOT
cryptographically verified - fine for a hackathon demo, NOT for production (would need the
TownPass OAuth / signed ID token).

Token = base64url(json{uid, exp}) + "." + base64url(HMAC-SHA256(SECRET_KEY, payload)).
"""

import base64
import hashlib
import hmac
import json
import time

from sqlmodel import Session

from townpass_backend import config

from . import repo
from .models import AppUser
from .schemas import LoginRequest, TokenOut, UserOut


def login(session: Session, req: LoginRequest) -> TokenOut:
    """Same townpass_id -> same user (idempotent). Updates the display name."""
    user = repo.upsert_user(session, req.townpass_id, req.name.strip())
    return TokenOut(token=__issue(user.id), user=to_out(user))  # type: ignore[arg-type]


def user_from_token(session: Session, token: str) -> AppUser | None:
    """None for missing/garbled/tampered/expired tokens or deleted users. Never raises."""
    uid = __verify(token)
    return repo.get_user(session, uid) if uid is not None else None


def to_out(user: AppUser) -> UserOut:
    return UserOut(id=user.id or 0, townpass_id=user.townpass_id, name=user.name)


def __issue(user_id: int, ttl: int | None = None) -> str:
    payload = {
        "uid": user_id,
        "exp": int(time.time()) + (ttl if ttl is not None else config.TOKEN_TTL_SECONDS),
    }
    body = __b64(json.dumps(payload, separators=(",", ":")).encode())
    return f"{body}.{__sign(body)}"


def __verify(token: str) -> int | None:
    try:
        body, sig = token.split(".", 1)
        if not hmac.compare_digest(sig, __sign(body)):
            return None
        payload = json.loads(__unb64(body))
        if int(payload["exp"]) < time.time():
            return None
        return int(payload["uid"])
    except (ValueError, KeyError, TypeError):
        return None


def __sign(body: str) -> str:
    return __b64(hmac.new(config.SECRET_KEY.encode(), body.encode(), hashlib.sha256).digest())


def __b64(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()


def __unb64(s: str) -> bytes:
    return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))


def issue_token_for_tests(user_id: int, ttl: int) -> str:
    """Test helper (e.g. already-expired tokens). Not used by the API."""
    return __issue(user_id, ttl)
