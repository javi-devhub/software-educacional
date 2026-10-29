USE plataforma_educativa;

START TRANSACTION;

-- Asegurar los OA involucrados en el Capítulo 11
INSERT INTO
  objetivo_aprendizaje (codigo_oa, descripcion, nivel)
VALUES
  (
    'OA 23',
    'Realizar encuestas y clasificar y organizar los datos obtenidos en tablas y visualizarlos en gráficos de barra.',
    '3° básico'
  ),
  (
    'OA 24',
    'Registrar y ordenar datos obtenidos de juegos aleatorios con dados y monedas, encontrando el menor, el mayor y estimando el punto medio entre ambos.',
    '3° básico'
  ),
  (
    'OA 25',
    'Construir, leer e interpretar pictogramas y gráficos de barra simple con escala, en base a información recolectada o dada.',
    '3° básico'
  ),
  (
    'OA 26',
    'Representar datos usando diagramas de puntos.',
    '3° básico'
  ) ON DUPLICATE KEY
UPDATE descripcion =
VALUES
  (descripcion);

-- Limpiar vínculos previos del capítulo 11
DELETE coa
FROM
  contenido_oa coa
  JOIN contenido c ON coa.id_contenido = c.id_contenido
WHERE
  JSON_VALID (c.recurso)
  AND JSON_EXTRACT (c.recurso, '$.capitulo') = 11;

-- 1. Tablas y gráficos de barra generales -> OA 23 y OA 25
INSERT INTO
  contenido_oa (id_contenido, id_oa)
SELECT
  c.id_contenido,
  oa.id_oa
FROM
  contenido c
  CROSS JOIN objetivo_aprendizaje oa
WHERE
  JSON_VALID (c.recurso)
  AND JSON_EXTRACT (c.recurso, '$.capitulo') = 11
  AND JSON_UNQUOTE (JSON_EXTRACT (c.recurso, '$.seccion')) IN (
    'Tablas',
    'Gráficos de barra',
    'Interpretar gráficos'
  )
  AND oa.codigo_oa IN ('OA 23', 'OA 25');

-- 2. Pictogramas -> OA 25
INSERT INTO
  contenido_oa (id_contenido, id_oa)
SELECT
  c.id_contenido,
  oa.id_oa
FROM
  contenido c
  CROSS JOIN objetivo_aprendizaje oa
WHERE
  JSON_VALID (c.recurso)
  AND JSON_EXTRACT (c.recurso, '$.capitulo') = 11
  AND JSON_UNQUOTE (JSON_EXTRACT (c.recurso, '$.seccion')) = 'Pictogramas'
  AND oa.codigo_oa = 'OA 25';

-- 3. Cierre: Diagrama de puntos -> OA 26
INSERT INTO
  contenido_oa (id_contenido, id_oa)
SELECT
  c.id_contenido,
  oa.id_oa
FROM
  contenido c
  CROSS JOIN objetivo_aprendizaje oa
WHERE
  JSON_VALID (c.recurso)
  AND JSON_EXTRACT (c.recurso, '$.capitulo') = 11
  AND c.titulo LIKE '%Diagrama de puntos%'
  AND oa.codigo_oa = 'OA 26';

-- 4. Cierre: Juegos aleatorios -> OA 24
INSERT INTO
  contenido_oa (id_contenido, id_oa)
SELECT
  c.id_contenido,
  oa.id_oa
FROM
  contenido c
  CROSS JOIN objetivo_aprendizaje oa
WHERE
  JSON_VALID (c.recurso)
  AND JSON_EXTRACT (c.recurso, '$.capitulo') = 11
  AND c.titulo LIKE '%juegos aleatorios%'
  AND oa.codigo_oa = 'OA 24';

-- 5. Cierre: Resto de actividades de síntesis -> OA 25
INSERT INTO
  contenido_oa (id_contenido, id_oa)
SELECT
  c.id_contenido,
  oa.id_oa
FROM
  contenido c
  CROSS JOIN objetivo_aprendizaje oa
WHERE
  JSON_VALID (c.recurso)
  AND JSON_EXTRACT (c.recurso, '$.capitulo') = 11
  AND JSON_UNQUOTE (JSON_EXTRACT (c.recurso, '$.seccion')) = 'Cierre'
  AND c.titulo NOT LIKE '%Diagrama de puntos%'
  AND c.titulo NOT LIKE '%juegos aleatorios%'
  AND oa.codigo_oa = 'OA 25' ON DUPLICATE KEY
UPDATE id_contenido =
VALUES
  (id_contenido);

COMMIT;