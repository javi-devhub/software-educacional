import bcrypt
from fastapi import FastAPI, HTTPException

from database import get_connection
from schemas import LoginRequest


app = FastAPI(
    title="Plataforma Educativa",
    version="1.0.0"
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

    return {
        "conexion": "correcta",
        "base_datos": base_datos
    }


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
        (datos.nickname,)
    )

    docente = cursor.fetchone()

    cursor.close()
    conexion.close()

    if docente is None:
        raise HTTPException(
            status_code=401,
            detail="Nickname o contraseña incorrectos"
        )

    contrasena_correcta = bcrypt.checkpw(
        datos.contrasena.encode("utf-8"),
        docente["contrasena_hash"].encode("utf-8")
    )

    if not contrasena_correcta:
        raise HTTPException(
            status_code=401,
            detail="Nickname o contraseña incorrectos"
        )

    if docente["rol"] != "docente":
        raise HTTPException(
            status_code=403,
            detail="Usuario sin permisos de docente"
        )

    return {
        "mensaje": "Inicio de sesión correcto",
        "docente": {
            "id_docente": docente["id_docente"],
            "nombre": docente["nombre"],
            "nickname": docente["nickname"],
            "rol": docente["rol"]
        }
    }