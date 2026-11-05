"""Copy to features/<name>.py to start a backend feature (underscore files are ignored).

Then: rename the prefix/tags, define tables + endpoints. Restart the server and it shows
up at http://localhost:8000/docs - share that page with the frontend as the API contract.
Remember: no LLM inference on the backend (competition rule).
"""

from fastapi import APIRouter
from sqlmodel import Field, Session, SQLModel, select

from townpass_backend.db import SessionDep

router = APIRouter(prefix="/template", tags=["template"])


class TemplateRow(SQLModel, table=True):
    __tablename__ = "template_row"

    id: int | None = Field(default=None, primary_key=True)
    name: str


@router.get("/rows")
def list_rows(session: SessionDep) -> list[TemplateRow]:
    return list(session.exec(select(TemplateRow)))


def seed(session: Session) -> None:
    """Optional: runs at startup. Keep it idempotent (check before inserting)."""
