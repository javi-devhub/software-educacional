-- =====================================================================
-- EP-2 · Modelo relacional y restricciones de integridad
-- Contenido: MATEMÁTICA · 3° básico · eje "Datos y probabilidades"
-- Base de datos: plataforma_educativa   (MySQL 8.0.16 o superior)
-- Reglas implementadas: RI-01 a RI-21 (ver comentarios en cada tabla)
-- =====================================================================

CREATE DATABASE IF NOT EXISTS plataforma_educativa
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE plataforma_educativa;


-- ==========================================
-- TABLA DOCENTE
-- ==========================================

CREATE TABLE IF NOT EXISTS docente (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    nickname VARCHAR(100) NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL,

    CONSTRAINT uq_docente_nickname UNIQUE (nickname),                                   -- RI-01
    CONSTRAINT ck_docente_nombre_no_vacio CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT ck_docente_nickname_no_vacio CHECK (CHAR_LENGTH(TRIM(nickname)) > 0),    -- RI-01
    CONSTRAINT ck_docente_hash_no_vacio CHECK (CHAR_LENGTH(contrasena_hash) >= 20),     -- RI-02
    CONSTRAINT ck_docente_rol_no_vacio CHECK (CHAR_LENGTH(TRIM(rol)) > 0)
) ENGINE=InnoDB;


-- ==========================================
-- TABLA TIPO_CONTENIDO
-- Solo admite las 4 etapas de la actividad de Matemática (RI-20)
-- ==========================================

CREATE TABLE IF NOT EXISTS tipo_contenido (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL,
    descripcion TEXT,

    CONSTRAINT uq_tipo_nombre UNIQUE (nombre_tipo),                                     -- RI-03
    CONSTRAINT ck_tipo_nombre_no_vacio CHECK (CHAR_LENGTH(TRIM(nombre_tipo)) > 0),
    CONSTRAINT ck_tipo_matematica CHECK (nombre_tipo IN (                               -- RI-20
        'Encuesta y tabla de datos',
        'Conocimiento de gráficos',
        'Interpretación de gráficos',
        'Creación de gráficos'
    ))
) ENGINE=InnoDB;


-- ==========================================
-- TABLA OBJETIVO_APRENDIZAJE
-- Solo Matemática · 3° básico · Datos y probabilidades (RI-17, RI-18, RI-19)
-- ==========================================

CREATE TABLE IF NOT EXISTS objetivo_aprendizaje (
    id_oa INT AUTO_INCREMENT PRIMARY KEY,
    codigo_oa VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    asignatura VARCHAR(50) NOT NULL DEFAULT 'Matemática',
    eje VARCHAR(100) NOT NULL DEFAULT 'Datos y probabilidades',
    nivel VARCHAR(50) NOT NULL DEFAULT '3° básico',

    CONSTRAINT uq_oa_codigo UNIQUE (codigo_oa),                                         -- RI-08
    CONSTRAINT ck_oa_codigo_no_vacio CHECK (CHAR_LENGTH(TRIM(codigo_oa)) > 0),
    CONSTRAINT ck_oa_codigo_formato CHECK (codigo_oa REGEXP '^OA [0-9]{1,2}$'),         -- RI-21
    CONSTRAINT ck_oa_descripcion_no_vacia CHECK (CHAR_LENGTH(TRIM(descripcion)) > 0),
    CONSTRAINT ck_oa_asignatura CHECK (asignatura = 'Matemática'),                      -- RI-17
    CONSTRAINT ck_oa_eje CHECK (eje = 'Datos y probabilidades'),                        -- RI-18
    CONSTRAINT ck_oa_nivel CHECK (nivel = '3° básico')                                  -- RI-09 / RI-19
) ENGINE=InnoDB;


-- ==========================================
-- TABLA CONTENIDO
-- ==========================================

CREATE TABLE IF NOT EXISTS contenido (
    id_contenido INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    recurso TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',                                       -- RI-13
    id_tipo INT NOT NULL,                                                               -- RI-04

    CONSTRAINT fk_contenido_tipo
        FOREIGN KEY (id_tipo)
        REFERENCES tipo_contenido(id_tipo)
        ON DELETE RESTRICT,                                                             -- RI-16

    CONSTRAINT ck_contenido_titulo_no_vacio CHECK (CHAR_LENGTH(TRIM(titulo)) > 0),      -- RI-05
    CONSTRAINT ck_contenido_recurso_no_vacio CHECK (CHAR_LENGTH(TRIM(recurso)) > 0),    -- RI-06
    CONSTRAINT ck_contenido_estado CHECK (estado IN ('activo', 'inactivo'))             -- RI-07
) ENGINE=InnoDB;


-- ==========================================
-- TABLA PUENTE CONTENIDO_OA  (relación N:M)
-- ==========================================

CREATE TABLE IF NOT EXISTS contenido_oa (
    id_contenido INT NOT NULL,                                                          -- RI-11
    id_oa INT NOT NULL,                                                                 -- RI-12

    PRIMARY KEY (id_contenido, id_oa),                                                  -- RI-10

    CONSTRAINT fk_contenido_oa_contenido
        FOREIGN KEY (id_contenido)
        REFERENCES contenido(id_contenido)
        ON DELETE CASCADE,                                                              -- RI-14

    CONSTRAINT fk_contenido_oa_objetivo
        FOREIGN KEY (id_oa)
        REFERENCES objetivo_aprendizaje(id_oa)
        ON DELETE CASCADE                                                               -- RI-15
) ENGINE=InnoDB;


-- ==========================================
-- DATOS INICIALES: tipos de contenido (etapas de la actividad)
-- ==========================================

INSERT IGNORE INTO tipo_contenido (nombre_tipo, descripcion) VALUES
('Encuesta y tabla de datos',  'El curso responde una encuesta y ordena los datos en una tabla'),
('Conocimiento de gráficos',   'Reconocimiento de los tipos de gráficos (pictogramas, gráficos de barras)'),
('Interpretación de gráficos', 'Lectura e interpretación de la información que entrega un gráfico'),
('Creación de gráficos',       'Construcción de gráficos a partir de datos entregados');
