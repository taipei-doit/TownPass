"""INTERFACE TYPES - what goes in and out of the auth API."""

from pydantic import BaseModel, ConfigDict, Field


class LoginRequest(BaseModel):
    # extra="forbid": if a client ever sends the national ID, phone, address... it gets a 422
    # instead of us silently receiving personal data we must not store.
    model_config = ConfigDict(extra="forbid")

    townpass_id: str = Field(min_length=1, max_length=64)
    name: str = Field(default="", max_length=50)


class UserOut(BaseModel):
    id: int
    townpass_id: str
    name: str


class TokenOut(BaseModel):
    token: str
    user: UserOut
