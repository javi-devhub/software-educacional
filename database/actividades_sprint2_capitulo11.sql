-- =====================================================================
-- Sprint 2: Actividades Curriculares - Capítulo 11 (Matemática 3° básico)
-- 30 Actividades estructuradas: 6 por sección
-- Base de datos: plataforma_educativa
-- =====================================================================
USE plataforma_educativa;

-- 1. Limpieza de actividades previas del Capítulo 11 para evitar duplicidad
DELETE FROM contenido WHERE JSON_VALID(recurso) AND JSON_EXTRACT(recurso, '$.capitulo') = 11;

-- 2. Variables de tipos de contenido según schema.sql
SET @t_enc = (SELECT id_tipo FROM tipo_contenido WHERE nombre_tipo = 'Encuesta y tabla de datos');
SET @t_con = (SELECT id_tipo FROM tipo_contenido WHERE nombre_tipo = 'Conocimiento de gráficos');
SET @t_int = (SELECT id_tipo FROM tipo_contenido WHERE nombre_tipo = 'Interpretación de gráficos');
SET @t_cre = (SELECT id_tipo FROM tipo_contenido WHERE nombre_tipo = 'Creación de gráficos');

-- 3. Inserción de Actividades
INSERT INTO contenido (titulo, descripcion, recurso, id_tipo) VALUES

-- =====================================================================
-- SECCIÓN 1: TABLAS (6 Actividades)
-- =====================================================================
(
    'Tablas 1: Juego de mesa favorito',
    'Organizar en una tabla de conteo con marcas las respuestas de 10 primos sobre su juego de mesa favorito.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":388,"seccion":"Tablas","tipo_mecanica":"tabla_marcas","datos":{"titulo":"Juego de mesa favorito","filas":[{"categoria":"Ludo","total":2},{"categoria":"Naipes","total":1},{"categoria":"Monopolio","total":5},{"categoria":"Ajedrez","total":2}]}}',
    @t_enc
),
(
    'Tablas 2: Encuesta de animales en el curso',
    'Registro de respuestas de una encuesta de 4 alternativas a 10 estudiantes en tablas de conteo.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":389,"seccion":"Tablas","tipo_mecanica":"encuesta_tabla","datos":{"preguntas":[{"item":"Mascota preferida","opciones":["Perro","Gato","Conejo","Hámster"]},{"item":"Animal dormilón","opciones":["Oso","Topo","Lirón","Tapir"]}]}}',
    @t_enc
),
(
    'Tablas 3: Conteo y frecuencias de color favorito',
    'Lectura y análisis de una tabla de marcas con las preferencias de colores del curso.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":390,"seccion":"Tablas","tipo_mecanica":"lectura_tabla","datos":{"titulo":"Color favorito","filas":[{"categoria":"Rojo","total":9},{"categoria":"Verde","total":9},{"categoria":"Azul","total":11},{"categoria":"Amarillo","total":6},{"categoria":"Naranjo","total":5},{"categoria":"Café","total":0}]}}',
    @t_enc
),
(
    'Tablas 4: Creación de encuesta guiada',
    'Construir una tabla de recolección de datos definiendo categorías y registrando respuestas.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":391,"seccion":"Tablas","tipo_mecanica":"diseno_encuesta","datos":{"total_encuestados":10,"num_opciones":4,"criterio":"Organización de respuestas en filas y columnas"}}',
    @t_enc
),
(
    'Tablas 5: Comparación de pesos de tortugas marinas',
    'Interpretar una tabla de datos numéricos con el peso promedio en kilogramos de 7 especies de tortugas.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":392,"seccion":"Tablas","tipo_mecanica":"interpretacion_tabla","datos":{"titulo":"Peso de tortugas marinas (kg)","filas":[{"categoria":"Plana","total":84},{"categoria":"Verde","total":136},{"categoria":"Carey","total":68},{"categoria":"Boba","total":113},{"categoria":"Laúd","total":410},{"categoria":"Lora","total":41},{"categoria":"Golfina","total":40}]}}',
    @t_enc
),
(
    'Tablas 6: Años de vida promedio de animales',
    'Analizar datos de longevidad animal presentados en tabla para ordenar de mayor a menor y comparar diferencias.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":393,"seccion":"Tablas","tipo_mecanica":"ordenamiento_tabla","datos":{"titulo":"Años de vida de animales","filas":[{"categoria":"Gorila","total":20},{"categoria":"Caballo","total":20},{"categoria":"Conejo","total":5},{"categoria":"Perro","total":12},{"categoria":"León","total":10},{"categoria":"Gato","total":12},{"categoria":"Elefante","total":35}]}}',
    @t_enc
),

-- =====================================================================
-- SECCIÓN 2: PICTOGRAMAS (6 Actividades)
-- =====================================================================
(
    'Pictogramas 1: Frutas preferidas (escala 1 a 1)',
    'Identificar la correspondencia básica de un pictograma donde cada símbolo representa 1 elemento.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":394,"seccion":"Pictogramas","tipo_mecanica":"lectura_pictograma","datos":{"titulo":"Frutas preferidas","simbolo":"Fruta","escala":1,"datos":[{"categoria":"Manzana","cantidad":6},{"categoria":"Plátano","cantidad":4},{"categoria":"Naranja","cantidad":5}]}}',
    @t_con
),
(
    'Pictogramas 2: Cambio del valor del símbolo (escala 2 a 1)',
    'Analizar la representación cuando un símbolo equivale a 2 unidades de datos.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":395,"seccion":"Pictogramas","tipo_mecanica":"escala_pictograma","datos":{"titulo":"Libros leídos por grupo","simbolo":"Libro","escala":2,"datos":[{"categoria":"Grupo A","simbolos":4,"total":8},{"categoria":"Grupo B","simbolos":3,"total":6},{"categoria":"Grupo C","simbolos":5,"total":10}]}}',
    @t_con
),
(
    'Pictogramas 3: Instrumentos de orquesta',
    'Completar un pictograma arrastrando figuras según los datos numéricos de una tabla (escala de 2 o 5).',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":396,"seccion":"Pictogramas","tipo_mecanica":"construccion_pictograma","datos":{"titulo":"Instrumentos en la orquesta","simbolo":"Nota musical","escala":2,"filas":[{"categoria":"Violín","total":12},{"categoria":"Flauta","total":6},{"categoria":"Trompeta","total":8},{"categoria":"Tambor","total":4}]}}',
    @t_cre
),
(
    'Pictogramas 4: Instrumento musical favorito',
    'Construir un pictograma con escala seleccionando la clave simbólica adecuada.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":397,"seccion":"Pictogramas","tipo_mecanica":"seleccion_escala","datos":{"titulo":"Preferencia de instrumentos","escala_sugerida":5,"filas":[{"categoria":"Guitarra","total":20},{"categoria":"Piano","total":15},{"categoria":"Batería","total":10}]}}',
    @t_cre
),
(
    'Pictogramas 5: Venta de flores en la semana',
    'Interpretar un pictograma con escala de 10 unidades por símbolo y resolver totales semanales.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":398,"seccion":"Pictogramas","tipo_mecanica":"calculo_pictograma","datos":{"titulo":"Ramos de flores vendidos","simbolo":"Ramo","escala":10,"filas":[{"categoria":"Lunes","simbolos":3,"total":30},{"categoria":"Martes","simbolos":4,"total":40},{"categoria":"Miércoles","simbolos":2,"total":20}]}}',
    @t_con
),
(
    'Pictogramas 6: Conversión de tabla a pictograma',
    'Transformar un registro tabular de asistencia a talleres en una representación gráfica con símbolos.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":399,"seccion":"Pictogramas","tipo_mecanica":"conversion_datos","datos":{"titulo":"Asistencia a Biblioteca","escala":4,"filas":[{"categoria":"3° A","total":16},{"categoria":"3° B","total":12},{"categoria":"3° C","total":20}]}}',
    @t_cre
),

-- =====================================================================
-- SECCIÓN 3: GRÁFICOS DE BARRA (6 Actividades)
-- =====================================================================
(
    'Gráficos de barra 1: Construcción inicial desde tabla',
    'Identificar los ejes, títulos y categorías para pasar datos de una tabla a barras verticales simples.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":400,"seccion":"Gráficos de barra","tipo_mecanica":"identificacion_ejes","datos":{"titulo":"Deporte favorito","eje_x":"Deporte","eje_y":"Votos","filas":[{"categoria":"Fútbol","total":14},{"categoria":"Básquetbol","total":8},{"categoria":"Vóleibol","total":6}]}}',
    @t_con
),
(
    'Gráficos de barra 2: Barras verticales vs. horizontales',
    'Reconocer y alternar la orientación de las barras manteniendo la equivalencia de los valores.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":401,"seccion":"Gráficos de barra","tipo_mecanica":"orientacion_grafico","datos":{"titulo":"Mascotas del condominio","orientaciones":["vertical","horizontal"],"filas":[{"categoria":"Perros","total":18},{"categoria":"Gatos","total":12},{"categoria":"Aves","total":5}]}}',
    @t_con
),
(
    'Gráficos de barra 3: Color de polera de fútbol',
    'Graficar levantando barras interactivas hasta la altura indicada por la frecuencia de cada color.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":402,"seccion":"Gráficos de barra","tipo_mecanica":"dibujo_barras","datos":{"titulo":"Color de polera preferido","filas":[{"categoria":"Azul","total":7},{"categoria":"Rojo","total":11},{"categoria":"Blanco","total":5},{"categoria":"Verde","total":3}]}}',
    @t_cre
),
(
    'Gráficos de barra 4: Talleres extraprogramáticos',
    'Completar el gráfico de barras simples con cuadrícula de apoyo 1 a 1.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":403,"seccion":"Gráficos de barra","tipo_mecanica":"dibujo_barras","datos":{"titulo":"Inscritos en talleres","filas":[{"categoria":"Teatro","total":9},{"categoria":"Pintura","total":12},{"categoria":"Robótica","total":15},{"categoria":"Música","total":8}]}}',
    @t_cre
),
(
    'Gráficos de barra 5: Gráficos con escala de 2 en 2',
    'Comprender la graduación del eje numérico de 2 en 2 en el contexto de reciclaje escolar.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":404,"seccion":"Gráficos de barra","tipo_mecanica":"escala_eje","datos":{"titulo":"Envases reciclados","escala_eje":2,"filas":[{"categoria":"Lunes","total":12},{"categoria":"Martes","total":18},{"categoria":"Miércoles","total":14},{"categoria":"Jueves","total":20}]}}',
    @t_con
),
(
    'Gráficos de barra 6: Gráficos con escala de 5 en 5 (Tapas plásticas)',
    'Construir barras con escala graduada de 5 en 5 calculando alturas intermedias.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":405,"seccion":"Gráficos de barra","tipo_mecanica":"construccion_escala","datos":{"titulo":"Recolección de tapas plásticas","escala_eje":5,"filas":[{"categoria":"Semana 1","total":25},{"categoria":"Semana 2","total":40},{"categoria":"Semana 3","total":35},{"categoria":"Semana 4","total":50}]}}',
    @t_cre
),

-- =====================================================================
-- SECCIÓN 4: INTERPRETAR GRÁFICOS (6 Actividades)
-- =====================================================================
(
    'Interpretar gráficos 1: Tipos de vehículos observados',
    'Determinar categoría con mayor/menor frecuencia y calcular la diferencia entre dos barras.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":406,"seccion":"Interpretar gráficos","tipo_mecanica":"preguntas_interpretacion","datos":{"titulo":"Vehículos en la avenida","escala":10,"filas":[{"categoria":"Autos","total":60},{"categoria":"Buses","total":20},{"categoria":"Motos","total":30},{"categoria":"Camiones","total":15}],"preguntas":[{"p":"¿Qué vehículo transitó más?","r":"Autos"},{"p":"¿Cuántos autos más que buses pasaron?","r":"40"}]}}',
    @t_int
),
(
    'Interpretar gráficos 2: Sabores de jugo preferidos',
    'Responder preguntas cuantitativas directas e inferenciales a partir de un gráfico con escala de 5 en 5.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":407,"seccion":"Interpretar gráficos","tipo_mecanica":"preguntas_interpretacion","datos":{"titulo":"Sabores de jugo en el casino","escala":5,"filas":[{"categoria":"Naranja","total":35},{"categoria":"Manzana","total":20},{"categoria":"Frutilla","total":45},{"categoria":"Uva","total":15}],"preguntas":[{"p":"¿Cuál es el sabor preferido?","r":"Frutilla"},{"p":"¿Cuántos estudiantes fueron encuestados en total?","r":"115"}]}}',
    @t_int
),
(
    'Interpretar gráficos 3: Ramos de flores vendidos',
    'Comparar ventas diarias de flores a partir de barras horizontales graduadas.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":408,"seccion":"Interpretar gráficos","tipo_mecanica":"comparacion_datos","datos":{"titulo":"Venta diaria de flores","filas":[{"categoria":"Rosas","total":24},{"categoria":"Claveles","total":18},{"categoria":"Girasoles","total":12},{"categoria":"Lirios","total":6}]}}',
    @t_int
),
(
    'Interpretar gráficos 4: Cumpleaños por estación del año',
    'Analizar un gráfico de barras por agrupación y calcular totales semestrales.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":409,"seccion":"Interpretar gráficos","tipo_mecanica":"analisis_agrupado","datos":{"titulo":"Cumpleaños de 3° básico","filas":[{"categoria":"Otoño","total":8},{"categoria":"Invierno","total":11},{"categoria":"Primavera","total":9},{"categoria":"Verano","total":7}]}}',
    @t_int
),
(
    'Interpretar gráficos 5: Consumo de fruta semanal',
    'Interpretar un gráfico con escala grande (decenas) y determinar afirmaciones verdaderas o falsas.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":410,"seccion":"Interpretar gráficos","tipo_mecanica":"verdadero_falso_grafico","datos":{"titulo":"Kg de fruta consumidos en el restorán","escala":10,"filas":[{"categoria":"Manzanas","total":50},{"categoria":"Naranjas","total":70},{"categoria":"Plátanos","total":40},{"categoria":"Peras","total":30}]}}',
    @t_int
),
(
    'Interpretar gráficos 6: Comparación de dos conjuntos en gráfico',
    'Extraer conclusiones comparativas entre dos barras de categorías afines en contexto cotidiano.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":411,"seccion":"Interpretar gráficos","tipo_mecanica":"extraccion_conclusiones","datos":{"titulo":"Colaciones saludables traídas al colegio","filas":[{"categoria":"Lunes","total":28},{"categoria":"Miércoles","total":32},{"categoria":"Viernes","total":16}]}}',
    @t_int
),

-- =====================================================================
-- SECCIÓN 5: CIERRE (Tablas/Gráficos, Preguntas, Puntos, Problemas, Desafíos y Repaso)
-- =====================================================================
(
    'Cierre 1: Hacer tabla y gráfico con datos entregados',
    'Dado un registro desordenado de datos, tabular los valores y construir el gráfico de barras correspondiente.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":412,"seccion":"Cierre","tipo_mecanica":"construccion_completa","datos":{"contexto":"Puntos obtenidos en la kermesse","filas":[{"categoria":"Alianzas Rojas","total":45},{"categoria":"Alianzas Azules","total":50},{"categoria":"Alianzas Amarillas","total":35}]}}',
    @t_cre
),
(
    'Cierre 2: Inventar preguntas sobre el gráfico',
    'Formular preguntas de interpretación (mayoría, diferencia, total) que puedan responderse con el gráfico proyectado.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":413,"seccion":"Cierre","tipo_mecanica":"formulacion_preguntas","datos":{"titulo":"Lugares de vacaciones preferidos","filas":[{"categoria":"Playa","total":16},{"categoria":"Campo","total":8},{"categoria":"Sur / Lagos","total":12}]}}',
    @t_int
),
(
    'Cierre 3: Diagrama de puntos (Deportes y Mascotas)',
    'Representar datos de frecuencias individuales utilizando marcas de puntos sobre una recta o eje base.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":414,"seccion":"Cierre","tipo_mecanica":"diagrama_puntos","datos":{"titulo":"Cantidad de hermanos por estudiante","eje_valores":[0,1,2,3,4],"frecuencias":{"0":4,"1":10,"2":8,"3":3,"4":1}}}',
    @t_con
),
(
    'Cierre 4: Recolectar datos y juegos aleatorios (Moneda y dado)',
    'Simular el lanzamiento de una moneda y un dado, registrar los resultados en tabla y analizar frecuencias.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":416,"seccion":"Cierre","tipo_mecanica":"juego_aleatorio","datos":{"experimento":"Lanzamiento de dado 20 veces","resultados_posibles":[1,2,3,4,5,6]}}',
    @t_enc
),
(
    'Cierre 5: Resolver problemas con pictogramas y gráficos',
    'Resolver problemas no rutinarios de varios pasos utilizando la información provista en gráficos y pictogramas.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":418,"seccion":"Cierre","tipo_mecanica":"resolucion_problemas","datos":{"titulo":"Medallas obtenidas en olimpiadas escolares","simbolo":"Medalla","escala":5,"filas":[{"categoria":"Oro","total":15},{"categoria":"Plata","total":25},{"categoria":"Bronce","total":20}]}}',
    @t_int
),
(
    'Cierre 6: Desafíos matemáticos y Repaso del Capítulo 11',
    'Actividad integradora de síntesis con lectura crítica de gráficos con escala y resolución de incógnitas.',
    '{"fuente":"Texto del estudiante, Matemática 3° básico","capitulo":11,"pagina":420,"seccion":"Cierre","tipo_mecanica":"repaso_sintesis","datos":{"titulo":"Animales que dan más susto (Desafío)","filas":[{"categoria":"Araña","total":24},{"categoria":"Serpiente","total":18},{"categoria":"Murciélago","total":12},{"categoria":"Tiburón","total":30}]}}',
    @t_cre
);

-- =====================================================================
-- 4. Verificación de la carga
-- =====================================================================
SELECT 
    JSON_UNQUOTE(JSON_EXTRACT(recurso, '$.seccion')) AS seccion,
    COUNT(*) AS total_actividades
FROM contenido
WHERE JSON_VALID(recurso) AND JSON_EXTRACT(recurso, '$.capitulo') = 11
GROUP BY seccion;