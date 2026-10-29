import json
import os
from typing import List, Optional
import bcrypt
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from database import get_connection
from schemas import ActividadResponse, LoginRequest

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


@app.get("/actividades", response_model=List[ActividadResponse])
def listar_actividades(seccion: Optional[str] = None):
    """
    Retorna la lista de actividades del Capítulo 11.
    Permite filtrar opcionalmente por sección mediante query param:
    /actividades?seccion=Tablas
    /actividades?seccion=Pictogramas
    /actividades?seccion=Gráficos de barra
    /actividades?seccion=Interpretar gráficos
    /actividades?seccion=Cierre
    """
    conexion = get_connection()
    cursor = conexion.cursor(dictionary=True)

    query = """
        SELECT 
            c.id_contenido,
            c.titulo,
            c.descripcion,
            c.recurso,
            tc.nombre_tipo AS tipo_etapa,
            COALESCE(GROUP_CONCAT(oa.codigo_oa ORDER BY oa.codigo_oa SEPARATOR ', '), '') AS oas
        FROM contenido c
        INNER JOIN tipo_contenido tc ON c.id_tipo = tc.id_tipo
        LEFT JOIN contenido_oa coa ON c.id_contenido = coa.id_contenido
        LEFT JOIN objetivo_aprendizaje oa ON coa.id_oa = oa.id_oa
        WHERE JSON_VALID(c.recurso) 
          AND JSON_EXTRACT(c.recurso, '$.capitulo') = 11
    """
    params = []

    if seccion:
        query += " AND JSON_UNQUOTE(JSON_EXTRACT(c.recurso, '$.seccion')) = %s"
        params.append(seccion)

    query += (
        " GROUP BY c.id_contenido, c.titulo, c.descripcion, c.recurso, tc.nombre_tipo"
    )
    query += " ORDER BY c.id_contenido ASC"

    cursor.execute(query, tuple(params))
    filas = cursor.fetchall()

    cursor.close()
    conexion.close()

    resultado = []
    for fila in filas:
        recurso_obj = (
            json.loads(fila["recurso"])
            if isinstance(fila["recurso"], str)
            else fila["recurso"]
        )

        resultado.append(
            ActividadResponse(
                id_contenido=fila["id_contenido"],
                titulo=fila["titulo"],
                descripcion=fila["descripcion"],
                seccion=recurso_obj.get("seccion", "General"),
                tipo_mecanica=recurso_obj.get("tipo_mecanica"),
                pagina=recurso_obj.get("pagina"),
                datos=recurso_obj.get("datos", {}),
                tipo_etapa=fila["tipo_etapa"],
                oa_asociados=[oa.strip() for oa in fila["oas"].split(",") if oa.strip()]
                if fila["oas"]
                else [],
            )
        )

    return resultado


@app.get("/actividades/{id_contenido}", response_model=ActividadResponse)
def obtener_actividad(id_contenido: int):
    """
    Retorna una actividad específica por su ID con todos sus datos listos para
    ser consumidos por la escena de Phaser o el componente en Vue 3.
    """
    conexion = get_connection()
    cursor = conexion.cursor(dictionary=True)

    cursor.execute(
        """
        SELECT 
            c.id_contenido,
            c.titulo,
            c.descripcion,
            c.recurso,
            tc.nombre_tipo AS tipo_etapa,
            COALESCE(GROUP_CONCAT(oa.codigo_oa ORDER BY oa.codigo_oa SEPARATOR ', '), '') AS oas
        FROM contenido c
        INNER JOIN tipo_contenido tc ON c.id_tipo = tc.id_tipo
        LEFT JOIN contenido_oa coa ON c.id_contenido = coa.id_contenido
        LEFT JOIN objetivo_aprendizaje oa ON coa.id_oa = oa.id_oa
        WHERE c.id_contenido = %s
        GROUP BY c.id_contenido, c.titulo, c.descripcion, c.recurso, tc.nombre_tipo
        """,
        (id_contenido,),
    )
    fila = cursor.fetchone()

    cursor.close()
    conexion.close()

    if not fila:
        raise HTTPException(status_code=404, detail="Actividad no encontrada")

    recurso_obj = (
        json.loads(fila["recurso"])
        if isinstance(fila["recurso"], str)
        else fila["recurso"]
    )

    return ActividadResponse(
        id_contenido=fila["id_contenido"],
        titulo=fila["titulo"],
        descripcion=fila["descripcion"],
        seccion=recurso_obj.get("seccion", "General"),
        tipo_mecanica=recurso_obj.get("tipo_mecanica"),
        pagina=recurso_obj.get("pagina"),
        datos=recurso_obj.get("datos", {}),
        tipo_etapa=fila["tipo_etapa"],
        oa_asociados=[oa.strip() for oa in fila["oas"].split(",") if oa.strip()]
        if fila["oas"]
        else [],
    )
