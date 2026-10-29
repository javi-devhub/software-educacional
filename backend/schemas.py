from pydantic import BaseModel
from typing import Any, Dict, List, Optional


class LoginRequest(BaseModel):
    nickname: str
    contrasena: str


class ActividadResponse(BaseModel):
    id_contenido: int
    titulo: str
    descripcion: Optional[str] = None
    seccion: str
    tipo_mecanica: Optional[str] = None
    pagina: Optional[int] = None
    datos: Dict[str, Any]
    tipo_etapa: str
    oa_asociados: List[str] = []
