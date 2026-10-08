-- =====================================================================
-- EP-2 · Modelo relacional y restricciones de integridad (contenido MINEDUC)
-- Base de datos: plataforma_educativa   (MySQL 8.0.16 o superior)
-- Reglas implementadas: RI-01 a RI-16 (ver comentarios en cada tabla)
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

    CONSTRAINT uq_docente_nickname UNIQUE (nickname),                       
    CONSTRAINT ck_docente_nombre_no_vacio CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT ck_docente_nickname_no_vacio CHECK (CHAR_LENGTH(TRIM(nickname)) > 0),  
    CONSTRAINT ck_docente_hash_no_vacio CHECK (CHAR_LENGTH(contrasena_hash) >= 20),   
    CONSTRAINT ck_docente_rol_no_vacio CHECK (CHAR_LENGTH(TRIM(rol)) > 0)
) ENGINE=InnoDB;


-- ==========================================
-- TABLA TIPO_CONTENIDO
-- ==========================================

CREATE TABLE IF NOT EXISTS tipo_contenido (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL,
    descripcion TEXT,

    CONSTRAINT uq_tipo_nombre UNIQUE (nombre_tipo),                         
    CONSTRAINT ck_tipo_nombre_no_vacio CHECK (CHAR_LENGTH(TRIM(nombre_tipo)) > 0)     
) ENGINE=InnoDB;


-- ==========================================
-- TABLA OBJETIVO_APRENDIZAJE
-- ==========================================

CREATE TABLE IF NOT EXISTS objetivo_aprendizaje (
    id_oa INT AUTO_INCREMENT PRIMARY KEY,
    codigo_oa VARCHAR(50) NOT NULL,
    descripcion TEXT NOT NULL,
    nivel VARCHAR(50) NOT NULL,

    CONSTRAINT uq_oa_codigo UNIQUE (codigo_oa),                             
    CONSTRAINT ck_oa_codigo_no_vacio CHECK (CHAR_LENGTH(TRIM(codigo_oa)) > 0),        
    CONSTRAINT ck_oa_descripcion_no_vacia CHECK (CHAR_LENGTH(TRIM(descripcion)) > 0),
    CONSTRAINT ck_oa_nivel_no_vacio CHECK (CHAR_LENGTH(TRIM(nivel)) > 0)              
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
        ON DELETE RESTRICT,                                                 

    CONSTRAINT ck_contenido_titulo_no_vacio CHECK (CHAR_LENGTH(TRIM(titulo)) > 0),    
    CONSTRAINT ck_contenido_recurso_no_vacio CHECK (CHAR_LENGTH(TRIM(recurso)) > 0),  
    CONSTRAINT ck_contenido_estado CHECK (estado IN ('activo', 'inactivo'))           
) ENGINE=InnoDB;


-- ==========================================
-- TABLA PUENTE CONTENIDO_OA  (relación N:M)
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
