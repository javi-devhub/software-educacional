-- =====================================================================
-- Migración de una base YA CREADA (versión comprensión lectora) a Matemática
-- Úsala solo si quieres conservar la base existente en vez de recrearla.
-- Si no tienes datos que conservar, es más simple: DROP DATABASE plataforma_educativa;
-- y volver a ejecutar schema.sql.
-- ¡Haz un respaldo antes!  mysqldump plataforma_educativa > respaldo.sql
-- =====================================================================
USE plataforma_educativa;

-- 1) Eliminar el contenido y los OA de lectura (si no, los nuevos CHECK no se pueden crear)
DELETE FROM contenido;              -- también borra sus filas en contenido_oa (CASCADE)
DELETE FROM objetivo_aprendizaje;
DELETE FROM tipo_contenido;

-- 2) Nuevas columnas en objetivo_aprendizaje
ALTER TABLE objetivo_aprendizaje
    ADD COLUMN asignatura VARCHAR(50)  NOT NULL DEFAULT 'Matemática'             AFTER descripcion,
    ADD COLUMN eje        VARCHAR(100) NOT NULL DEFAULT 'Datos y probabilidades' AFTER asignatura,
    MODIFY COLUMN nivel   VARCHAR(50)  NOT NULL DEFAULT '3° básico';

-- 3) Nuevas restricciones
ALTER TABLE objetivo_aprendizaje
    ADD CONSTRAINT ck_oa_codigo_formato CHECK (codigo_oa REGEXP '^OA [0-9]{1,2}$'),
    ADD CONSTRAINT ck_oa_asignatura     CHECK (asignatura = 'Matemática'),
    ADD CONSTRAINT ck_oa_eje            CHECK (eje = 'Datos y probabilidades'),
    ADD CONSTRAINT ck_oa_nivel          CHECK (nivel = '3° básico');

ALTER TABLE tipo_contenido
    ADD CONSTRAINT ck_tipo_matematica CHECK (nombre_tipo IN (
        'Encuesta y tabla de datos',
        'Conocimiento de gráficos',
        'Interpretación de gráficos',
        'Creación de gráficos'
    ));

-- 4) Cargar los tipos de contenido (etapas)
INSERT INTO tipo_contenido (nombre_tipo, descripcion) VALUES
('Encuesta y tabla de datos',  'El curso responde una encuesta y ordena los datos en una tabla'),
('Conocimiento de gráficos',   'Reconocimiento de los tipos de gráficos (pictogramas, gráficos de barras)'),
('Interpretación de gráficos', 'Lectura e interpretación de la información que entrega un gráfico'),
('Creación de gráficos',       'Construcción de gráficos a partir de datos entregados');
