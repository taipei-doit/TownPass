"""DATA - only the columns this module needs. Adding a field later is fine: it is added on startup."""

from sqlmodel import Field, SQLModel


class TemplateItem(SQLModel, table=True):
    __tablename__ = "template_item"  # prefix table names with your feature name

    id: int | None = Field(default=None, primary_key=True)
    name: str
