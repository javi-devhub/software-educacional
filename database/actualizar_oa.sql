-- TT-10 | Mapeo curricular de Matemática 3° básico, capítulo 11.
-- Diseñado para el schema.sql del proyecto actual y las bases anteriores
-- que también contienen la columna objetivo_aprendizaje.nivel.
-- No toca DOCENTE ni sus credenciales; NO borra contenidos ni tipos.
-- Ejecutar DESPUÉS de cargar datos_matematica.sql, en DBeaver.
-- ATENCIÓN: reemplaza los vínculos OA 23–26 del capítulo 11 para corregir
-- la asignación anterior que etiquetaba todos los registros con OA 25.
-- Puedes volver a ejecutarlo sin duplicar relaciones.
USE plataforma_educativa;

START TRANSACTION;

-- El formato permitido de código en MySQL es 'OA 23', no 'MA03 OA 23'.
-- Incluir 'nivel' hace compatible la inserción con la versión antigua
-- (nivel sin DEFAULT) y con la nueva (con DEFAULT).
INSERT INTO objetivo_aprendizaje (codigo_oa, descripcion, nivel) VALUES
('OA 23', 'Realizar encuestas y clasificar y organizar los datos obtenidos en tablas y visualizarlos en gráficos de barra.', '3° básico'),
('OA 24', 'Registrar y ordenar datos obtenidos de juegos aleatorios con dados y monedas, encontrando el menor, el mayor y estimando el punto medio entre ambos.', '3° básico'),
('OA 25', 'Construir, leer e interpretar pictogramas y gráficos de barra simple con escala, en base a información recolectada o dada.', '3° básico'),
('OA 26', 'Representar datos usando diagramas de puntos.', '3° básico')
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion);

-- Limpiar solo las relaciones curriculares de OA 23–26 para los recursos
-- del capítulo 11. Otras relaciones, contenidos y docentes se mantienen.
DELETE co
FROM contenido_oa co
JOIN contenido c ON c.id_contenido = co.id_contenido
JOIN objetivo_aprendizaje oa ON oa.id_oa = co.id_oa
WHERE oa.codigo_oa IN ('OA 23', 'OA 24', 'OA 25', 'OA 26')
  AND JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.capitulo')) = '11';

-- Mapeo curricular por páginas de cada recurso.
-- Se puede mapear un mismo recurso a varios OA si corresponden.
-- OA 23: encuesta, organización de datos y uso de tablas / gráfico de barras.
-- OA 24: experimentos con dados y monedas.
-- OA 25: pictogramas y gráficos de barras, lectura y construcción.
-- OA 26: diagramas de puntos.
-- La página 418 (diagrama de conjuntos) queda pendiente de revisión docente.
INSERT IGNORE INTO contenido_oa (id_contenido, id_oa)
SELECT c.id_contenido, oa.id_oa
FROM contenido c
JOIN objetivo_aprendizaje oa ON oa.codigo_oa IN ('OA 23', 'OA 24', 'OA 25', 'OA 26')
WHERE JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.capitulo')) = '11'
  AND (
    (oa.codigo_oa = 'OA 23' AND CAST(JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS UNSIGNED) IN (388,389,390,391,392,393,400,401,410,411,413))
    OR (oa.codigo_oa = 'OA 24' AND CAST(JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS UNSIGNED) IN (414,415))
    OR (oa.codigo_oa = 'OA 25' AND (
         CAST(JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS UNSIGNED) BETWEEN 394 AND 411
         OR CAST(JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS UNSIGNED) IN (414,415,416,417,419,420,421)))
    OR (oa.codigo_oa = 'OA 26' AND CAST(JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS UNSIGNED) IN (412,413,419,420))
  );

COMMIT;

-- Verificación. Se esperan contenidos relacionados con OA 23–26.
-- Si no aparecen filas: comprobar que se haya cargado datos_matematica.sql.
SELECT c.id_contenido, c.titulo,
  JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS pagina,
  COALESCE(GROUP_CONCAT(oa.codigo_oa ORDER BY oa.codigo_oa SEPARATOR ', '), 'PENDIENTE DE REVISIÓN') AS oa_asignados
FROM contenido c
LEFT JOIN contenido_oa co ON co.id_contenido = c.id_contenido
LEFT JOIN objetivo_aprendizaje oa ON oa.id_oa = co.id_oa
WHERE JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.capitulo')) = '11'
GROUP BY c.id_contenido, c.titulo, c.recurso
ORDER BY CAST(JSON_UNQUOTE(JSON_EXTRACT(IF(JSON_VALID(c.recurso), c.recurso, '{}'), '$.pagina')) AS UNSIGNED), c.id_contenido;
