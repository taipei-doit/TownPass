"""DATA - tables owned by auth. Only the columns this module needs (data minimisation).
(Inside class bodies Python mangles `__names`, so defaults use inline lambdas, not `__` helpers.)
"""

from datetime import UTC, datetime

from sqlmodel import Field, SQLModel


class AppUser(SQLModel, table=True):
    __tablename__ = "app_user"

    id: int | None = Field(default=None, primary_key=True)
    townpass_id: str = Field(index=True, unique=True, max_length=64)
    name: str = Field(default="", max_length=50)
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
    last_login_at: datetime = Field(default_factory=lambda: datetime.now(UTC))
