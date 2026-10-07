from pydantic import BaseModel


class LoginRequest(BaseModel):
    nickname: str
    contrasena: str