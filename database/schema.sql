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
    nickname VARCHAR(100) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL
) ENGINE=InnoDB;


-- ==========================================
-- TABLA TIPO_CONTENIDO
-- ==========================================

CREATE TABLE IF NOT EXISTS tipo_contenido (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
) ENGINE=InnoDB;


-- ==========================================
-- TABLA OBJETIVO_APRENDIZAJE
-- ==========================================

CREATE TABLE IF NOT EXISTS objetivo_aprendizaje (
    id_oa INT AUTO_INCREMENT PRIMARY KEY,
    codigo_oa VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    nivel VARCHAR(50) NOT NULL
) ENGINE=InnoDB;


-- ==========================================
-- TABLA CONTENIDO
-- ==========================================

CREATE TABLE IF NOT EXISTS contenido (
    id_contenido INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    recurso TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    id_tipo INT NOT NULL,

    CONSTRAINT fk_contenido_tipo
        FOREIGN KEY (id_tipo)
        REFERENCES tipo_contenido(id_tipo)
        ON DELETE RESTRICT
) ENGINE=InnoDB;


-- ==========================================
-- TABLA PUENTE CONTENIDO_OA
-- ==========================================

CREATE TABLE IF NOT EXISTS contenido_oa (
    id_contenido INT NOT NULL,
    id_oa INT NOT NULL,

    PRIMARY KEY (id_contenido, id_oa),

    CONSTRAINT fk_contenido_oa_contenido
        FOREIGN KEY (id_contenido)
        REFERENCES contenido(id_contenido)
        ON DELETE CASCADE,

    CONSTRAINT fk_contenido_oa_objetivo
        FOREIGN KEY (id_oa)
        REFERENCES objetivo_aprendizaje(id_oa)
        ON DELETE CASCADE
) ENGINE=InnoDB;