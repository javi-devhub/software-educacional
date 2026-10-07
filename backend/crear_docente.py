import bcrypt
from getpass import getpass

from database import get_connection


nombre = "Docente Prueba"
nickname = "docente_prueba"
contrasena = getpass("Contraseña de la docente: ")
rol = "docente"

contrasena_hash = bcrypt.hashpw(
    contrasena.encode("utf-8"),
    bcrypt.gensalt()
).decode("utf-8")

conexion = get_connection()
cursor = conexion.cursor()

sql = """
INSERT INTO docente (nombre, nickname, contrasena_hash, rol)
VALUES (%s, %s, %s, %s)
"""

cursor.execute(
    sql,
    (nombre, nickname, contrasena_hash, rol)
)

conexion.commit()

print("Docente creada correctamente")

cursor.close()
conexion.close()