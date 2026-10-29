export const sectionThemes = {
  Tablas: { icon: '🧩', color: '#236bba', tint: '#e9f3ff', invitation: '¡Ordenemos nuestras ideas!' },
  Pictogramas: { icon: '🎨', color: '#8450cc', tint: '#f3ecff', invitation: '¡Cuenta una historia con dibujos!' },
  'Gráficos de barra': { icon: '🏗️', color: '#007c83', tint: '#e1f6f2', invitation: '¡Construyamos algo increíble!' },
  'Interpretar gráficos': { icon: '🔎', color: '#a95319', tint: '#fff0df', invitation: '¡Encuentra las pistas escondidas!' },
  'Diagramas de puntos': { icon: '🪁', color: '#a43e72', tint: '#ffedf5', invitation: '¡Cada puntito cuenta!' },
  'Experimentos aleatorios': { icon: '🎲', color: '#4764ac', tint: '#edf1ff', invitation: '¡Descubramos qué puede pasar!' },
  Cierre: { icon: '🚀', color: '#786019', tint: '#fff5cc', invitation: '¡Pon a prueba tus superpoderes!' }
}
export const themeFor = section => sectionThemes[section] || sectionThemes.Tablas

export function emojiFor(label) {
  const text = label.toLocaleLowerCase('es')
  const groups = [
    [/perro/, '🐶'], [/gato/, '🐱'], [/conejo/, '🐰'], [/tortuga/, '🐢'],
    [/oso|panda/, '🐻'], [/pingüino/, '🐧'], [/koala/, '🐨'], [/ave|canario|tucán/, '🐦'],
    [/fútbol|pelota/, '⚽'], [/tenis/, '🎾'], [/natación/, '🏊'], [/bicicleta/, '🚲'],
    [/flauta|clarinete/, '🪈'], [/piano/, '🎹'], [/guitarra/, '🎸'], [/violín/, '🎻'], [/tambor|batería/, '🥁'],
    [/manzana/, '🍎'], [/plátano/, '🍌'], [/uva/, '🍇'], [/frutilla/, '🍓'], [/piña/, '🍍'], [/limón/, '🍋'],
    [/rojo|roja/, '🔴'], [/azul/, '🔵'], [/verde/, '🟢'], [/amarill/, '🟡'], [/naranj/, '🟠'],
    [/blanc/, '⚪'], [/negro/, '⚫'], [/libro|cuento|novela/, '📚'], [/auto|vehículo/, '🚗'],
    [/ajedrez/, '♟️'], [/ludo|monopolio/, '🎲'], [/naipes|cartas/, '🃏'], [/cara/, '☀️'], [/sello/, '🌙']
  ]
  return groups.find(([pattern]) => pattern.test(text))?.[1] || '🌟'
}

// Alternativas estables, distintas y no negativas; incluye siempre la respuesta correcta.
export function answerChoices(answer, index = 0) {
  const offsets = [1, -1, 2, -2, 5, 10]
  const choices = []
  for (const offset of offsets) {
    const value = answer + offset
    if (value >= 0 && value !== answer && !choices.includes(value)) choices.push(value)
    if (choices.length === 3) break
  }
  choices.splice(index % 4, 0, answer)
  return choices
}
