// Actividad "La encuesta del curso" (eje Datos y probabilidades, 3° básico), definida con la docente:
//   1) encuesta y tabla  2) conocemos los gráficos  3) interpretamos la información  4) creamos gráficos.
// Los temas, números y preguntas son ejemplos: confirmar con la docente. Cuando exista la base de datos (EP-2),
// este archivo se reemplaza por un fetch a la API.
export const etapas = [
  { id: 'encuesta', title: 'Encuesta y tabla', short: 'Encuesta y tabla', emoji: '📝', minutes: 8, desc: 'Votamos entre todos y ordenamos los datos en una tabla.', color: '#2F6BFF', tint: '#E4ECFF', ink: '#1B3FB8' },
  { id: 'graficos', title: 'Conocemos los gráficos', short: 'Conocemos gráficos', emoji: '📊', minutes: 6, desc: 'Descubrimos cómo se ve la información en un pictograma y en un gráfico de barras.', color: '#8B3DFF', tint: '#EFE4FF', ink: '#5B1FB8' },
  { id: 'interpretar', title: 'Interpretamos la información', short: 'Interpretamos', emoji: '🔎', minutes: 8, desc: 'Leemos el gráfico y respondemos preguntas sobre los datos.', color: '#FF8A00', tint: '#FFEBD2', ink: '#8F4700' },
  { id: 'crear', title: 'Creamos gráficos', short: 'Creamos gráficos', emoji: '✏️', minutes: 10, desc: 'Con una tabla de datos, construimos el gráfico de barras.', color: '#00A6C7', tint: '#D6F3FA', ink: '#045A6E' }
]
export const etapaIndex = (id) => etapas.findIndex((e) => e.id === id)

// Etapa 1: encuesta del curso
export const encuesta = {
  pregunta: '¿Cuál es tu fruta favorita?',
  opciones: [
    { key: 'manzana', emoji: '🍎', label: 'Manzana' },
    { key: 'platano', emoji: '🍌', label: 'Plátano' },
    { key: 'uva', emoji: '🍇', label: 'Uva' },
    { key: 'frutilla', emoji: '🍓', label: 'Frutilla' }
  ],
  ejemplo: { manzana: 7, platano: 4, uva: 6, frutilla: 3 }
}

// Etapas 2 y 3: datos entregados para conocer e interpretar gráficos
export const datosMascotas = {
  titulo: 'Mascotas favoritas de 3° básico',
  items: [
    { key: 'perro', emoji: '🐶', label: 'Perro', value: 8 },
    { key: 'gato', emoji: '🐱', label: 'Gato', value: 5 },
    { key: 'conejo', emoji: '🐰', label: 'Conejo', value: 3 },
    { key: 'pez', emoji: '🐟', label: 'Pez', value: 6 }
  ]
}
export const preguntas = [
  { q: '¿Qué mascota prefieren más estudiantes?', options: [['🐱', 'Gato', false], ['🐶', 'Perro', true], ['🐟', 'Pez', false]], hint: 'Busquen la barra más alta.' },
  { q: '¿Cuántos estudiantes eligieron el gato?', options: [['3️⃣', '3 estudiantes', false], ['5️⃣', '5 estudiantes', true], ['6️⃣', '6 estudiantes', false]], hint: 'Miren el número de la barra del gato.' },
  { q: '¿Cuántos estudiantes más eligieron el perro que el conejo?', options: [['3️⃣', '3 más', false], ['5️⃣', '5 más', true], ['🔢', '11 más', false]], hint: 'Resten: 8 − 3.' }
]

// Etapa 4: tabla entregada para crear el gráfico
export const datosDeportes = {
  titulo: 'Deportes favoritos de un curso',
  max: 8,
  items: [
    { key: 'futbol', emoji: '⚽', label: 'Fútbol', value: 7 },
    { key: 'natacion', emoji: '🏊', label: 'Natación', value: 3 },
    { key: 'ciclismo', emoji: '🚴', label: 'Ciclismo', value: 5 },
    { key: 'voley', emoji: '🏐', label: 'Vóley', value: 4 }
  ]
}