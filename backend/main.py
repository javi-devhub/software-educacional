import json
import os
from typing import List, Optional
import bcrypt
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from database import get_connection
from schemas import ActividadResponse, LoginRequest
from actividades import preparar_actividades

# Configuración de CORS
origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
]

app = FastAPI(title="Plataforma Educativa", version="1.0.0")

# CORS configuration para permitir requests desde el frontend
cors_origins = os.getenv(
    "CORS_ORIGINS", "http://localhost:5173,http://localhost:8000"
).split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def inicio():
    return {"mensaje": "Backend funcionando"}


@app.get("/db-test")
def probar_base_datos():
    conexion = get_connection()
    cursor = conexion.cursor()

    cursor.execute("SELECT DATABASE()")
    base_datos = cursor.fetchone()[0]

    cursor.close()
    conexion.close()

    return {"conexion": "correcta", "base_datos": base_datos}


@app.post("/login")
def login(datos: LoginRequest):
    conexion = get_connection()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT id_docente, nombre, nickname, contrasena_hash, rol
        FROM docente
        WHERE nickname = %s
        """,
        (datos.nickname,),
    )

    docente = cursor.fetchone()

    cursor.close()
    conexion.close()

    if docente is None:
        raise HTTPException(status_code=401, detail="Nickname o contraseña incorrectos")

    contrasena_correcta = bcrypt.checkpw(
        datos.contrasena.encode("utf-8"), docente["contrasena_hash"].encode("utf-8")
    )

    if not contrasena_correcta:
        raise HTTPException(status_code=401, detail="Nickname o contraseña incorrectos")

    if docente["rol"] != "docente":
        raise HTTPException(status_code=403, detail="Usuario sin permisos de docente")

    return {
        "mensaje": "Inicio de sesión correcto",
        "docente": {
            "id_docente": docente["id_docente"],
            "nombre": docente["nombre"],
            "nickname": docente["nickname"],
            "rol": docente["rol"],
        },
    }


# =====================================================================
# ENDPOINTS PARA ACTIVIDADES (SPRINT 2 - CAPÍTULO 11)
# =====================================================================


def catalogo_actividades():
    conexion = get_connection()
    cursor = conexion.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT c.id_contenido, c.titulo, c.descripcion, c.recurso, c.estado,
                   tc.nombre_tipo AS tipo_etapa,
                   GROUP_CONCAT(DISTINCT oa.codigo_oa ORDER BY oa.codigo_oa SEPARATOR ', ') AS oas
            FROM contenido c
            INNER JOIN tipo_contenido tc ON c.id_tipo = tc.id_tipo
            LEFT JOIN contenido_oa coa ON c.id_contenido = coa.id_contenido
            LEFT JOIN objetivo_aprendizaje oa ON coa.id_oa = oa.id_oa
            WHERE c.estado = 'activo' AND JSON_VALID(c.recurso)
              AND JSON_EXTRACT(c.recurso, '$.capitulo') = 11
            GROUP BY c.id_contenido, c.titulo, c.descripcion, c.recurso, c.estado, tc.nombre_tipo
        """)
        return preparar_actividades(cursor.fetchall())
    finally:
        cursor.close()
        conexion.close()


@app.get("/actividades", response_model=List[ActividadResponse])
def listar_actividades(seccion: Optional[str] = None):
    actividades = catalogo_actividades()
    return [a for a in actividades if not seccion or a.seccion == seccion]


@app.get("/actividades/{id_contenido}", response_model=ActividadResponse)
def obtener_actividad(id_contenido: int):
    for actividad in catalogo_actividades():
        if actividad.id_contenido == id_contenido:
            return actividad
    raise HTTPException(status_code=404, detail="Actividad no encontrada")
