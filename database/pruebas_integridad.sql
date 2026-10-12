
USE plataforma_educativa;
START TRANSACTION;

-- Datos válidos base
INSERT INTO docente (nombre, nickname, contrasena_hash, rol)
VALUES ('Veronica', 'Pveronica', '$2b$12$abcdefghijklmnopqrstuuabcdefghijklmnopqrstuvwxyz0123', 'docente');
INSERT INTO tipo_contenido (nombre_tipo) VALUES ('Comprensión lectora');
SET @tipo = LAST_INSERT_ID();
INSERT INTO objetivo_aprendizaje (codigo_oa, descripcion, nivel) VALUES ('OA 04', 'Leer textos', '3° básico');
SET @oa = LAST_INSERT_ID();
INSERT INTO contenido (titulo, recurso, id_tipo) VALUES ('El zorro y el bosque', 'texto...', @tipo);
SET @cont = LAST_INSERT_ID();
INSERT INTO contenido_oa VALUES (@cont, @oa);

-- [RI-01] nickname repetido  -> debe fallar (UNIQUE)
INSERT INTO docente (nombre, nickname, contrasena_hash, rol)
VALUES ('Otra', 'Pveronica', '$2b$12$abcdefghijklmnopqrstuuabcdefghijklmnopqrstuvwxyz0123', 'docente');
-- [RI-01] nickname vacío     -> debe fallar (CHECK)
INSERT INTO docente (nombre, nickname, contrasena_hash, rol)
VALUES ('Otra', '   ', '$2b$12$abcdefghijklmnopqrstuuabcdefghijklmnopqrstuvwxyz0123', 'docente');
-- [RI-01] nickname NULL      -> debe fallar (NOT NULL)
INSERT INTO docente (nombre, nickname, contrasena_hash, rol)
VALUES ('Otra', NULL, '$2b$12$abcdefghijklmnopqrstuuabcdefghijklmnopqrstuvwxyz0123', 'docente');

-- [RI-02] contraseña en texto plano (muy corta) -> debe fallar (CHECK)
INSERT INTO docente (nombre, nickname, contrasena_hash, rol)
VALUES ('Otra', 'otra', '1234', 'docente');

-- [RI-03] tipo duplicado -> debe fallar (UNIQUE)
INSERT INTO tipo_contenido (nombre_tipo) VALUES ('Comprensión lectora');

-- [RI-04] id_tipo inexistente -> debe fallar (FK)
INSERT INTO contenido (titulo, recurso, id_tipo) VALUES ('X', 'url', 99999);

-- [RI-05] título vacío -> debe fallar
INSERT INTO contenido (titulo, recurso, id_tipo) VALUES ('', 'url', @tipo);

-- [RI-06] recurso vacío -> debe fallar
INSERT INTO contenido (titulo, recurso, id_tipo) VALUES ('Algo', '', @tipo);

-- [RI-07] estado vacío o inválido -> debe fallar
INSERT INTO contenido (titulo, recurso, estado, id_tipo) VALUES ('Algo', 'url', '', @tipo);
INSERT INTO contenido (titulo, recurso, estado, id_tipo) VALUES ('Algo', 'url', 'borrado', @tipo);

-- [RI-08] código OA duplicado -> debe fallar
INSERT INTO objetivo_aprendizaje (codigo_oa, descripcion, nivel) VALUES ('OA 04', 'otro', '3° básico');

-- [RI-09] nivel vacío -> debe fallar
INSERT INTO objetivo_aprendizaje (codigo_oa, descripcion, nivel) VALUES ('OA 99', 'otro', '');

-- [RI-10] asociación repetida -> debe fallar (PK compuesta)
INSERT INTO contenido_oa VALUES (@cont, @oa);

-- [RI-11] contenido inexistente -> debe fallar (FK)
INSERT INTO contenido_oa VALUES (99999, @oa);

-- [RI-12] OA inexistente -> debe fallar (FK)
INSERT INTO contenido_oa VALUES (@cont, 99999);

-- [RI-13] estado por defecto -> debe devolver 'activo' (sin error)
SELECT 'RI-13 (esperado: activo)' AS prueba, estado FROM contenido WHERE id_contenido = @cont;

-- [RI-16] borrar tipo con contenidos -> debe fallar (RESTRICT)
DELETE FROM tipo_contenido WHERE id_tipo = @tipo;

-- [RI-15] borrar un OA borra su vínculo (sin error, devuelve 0)
DELETE FROM objetivo_aprendizaje WHERE id_oa = @oa;
SELECT 'RI-15 (esperado: 0)' AS prueba, COUNT(*) AS vinculos_restantes FROM contenido_oa WHERE id_oa = @oa;

-- [RI-14] borrar un contenido borra sus vínculos (sin error, devuelve 0)
INSERT INTO objetivo_aprendizaje (codigo_oa, descripcion, nivel) VALUES ('OA 05', 'Leer', '3° básico');
SET @oa2 = LAST_INSERT_ID();
INSERT INTO contenido_oa VALUES (@cont, @oa2);
DELETE FROM contenido WHERE id_contenido = @cont;
SELECT 'RI-14 (esperado: 0)' AS prueba, COUNT(*) AS vinculos_restantes FROM contenido_oa WHERE id_contenido = @cont;

ROLLBACK;
