<script setup>
import { computed, ref } from 'vue'
import ActivityGraph from '../components/ActivityGraph.vue'
import QuizChallenge from '../components/QuizChallenge.vue'
import { themeFor, emojiFor } from '../data/playful'

const props = defineProps({ actividad: { type: Object, required: true } })
const d = computed(() => props.actividad.datos)
const theme = computed(() => themeFor(props.actividad.seccion))
const lastRoll = ref(null)
const voteHistory = ref([])
const flipped = ref({})
const buildingHint = ref(false)
const isBuild = computed(() => props.actividad.tipo_etapa === 'Creación de gráficos')
const surveyIndex = ref(0)
const customQuestions = ref({})
const customOptionsBySurvey = ref(Array.from({ length: d.value.num_encuestas || 1 }, () => ['', '', '', '']))
const customQuestion = computed({
  get: () => customQuestions.value[surveyIndex.value] || '',
  set: value => { customQuestions.value[surveyIndex.value] = value }
})
const customOptions = computed(() => customOptionsBySurvey.value[surveyIndex.value])
const counts = ref({})
const checked = ref(false)
const symbolScale = ref(d.value.valor_simbolo || 1)
const graphType = ref(d.value.tipo_grafico)
const orientation = ref(d.value.orientacion || 'vertical')
const surveys = computed(() => d.value.encuestas || (d.value.preguntas || []).filter(p => p.opciones))
const isCustom = computed(() => !!(d.value.alternativas_por_pregunta || d.value.num_opciones))
const isSurvey = computed(() => isCustom.value || surveys.value.length > 0 || d.value.opciones || d.value.moneda || d.value.dados)
const options = computed(() => {
  if (isCustom.value) return customOptions.value
  if (surveys.value.length) return surveys.value[surveyIndex.value].opciones
  if (d.value.moneda) return d.value.moneda.opciones
  if (d.value.dados) return Array.from({ length: 11 }, (_, i) => String(i + 2))
  return d.value.opciones || []
})
const question = computed(() => customQuestion.value || surveys.value[surveyIndex.value]?.pregunta || surveys.value[surveyIndex.value]?.item || d.value.pregunta || props.actividad.titulo)
const groupKey = computed(() => `${surveyIndex.value}:`)
const limit = computed(() => d.value.moneda?.lanzamientos || d.value.lanzamientos || d.value.encuestados || d.value.grupo || (surveys.value.length || isCustom.value ? 10 : Infinity))
const surveyRows = computed(() => options.value.map((categoria, i) => ({ categoria: categoria || `Opción ${i + 1}`, total: counts.value[groupKey.value + i] || 0 })))
const totalVotes = computed(() => surveyRows.value.reduce((n, row) => n + row.total, 0))
const sets = computed(() => d.value.conjuntos || [])
const combinations = computed(() => sets.value.length ? [sets.value[0], sets.value[1], sets.value[2], `${sets.value[0]} y ${sets.value[1]}`, `${sets.value[0]} y ${sets.value[2]}`, `${sets.value[1]} y ${sets.value[2]}`, 'Los tres sabores'] : [])
const rows = computed(() => {
  if (isSurvey.value) return surveyRows.value
  if (d.value.simbolos_conocidos) return d.value.simbolos_conocidos.map(f => ({ categoria: f.categoria, total: f.total * d.value.valor_simbolo }))
  return d.value.filas || []
})
const itemsFor = filas => filas.map((f, i) => ({ key: String(i), label: f.categoria, value: f.total ?? f.cantidad ?? 0, emoji: emojiFor(f.categoria) }))
const targetItems = computed(() => itemsFor(rows.value))
const chartItems = computed(() => isBuild.value ? targetItems.value.map(i => ({ ...i, value: counts.value[i.key] || 0 })) : targetItems.value)
const maximum = computed(() => Math.max(...targetItems.value.map(i => i.value), 1))
const buildOK = computed(() => targetItems.value.every(i => i.value === (counts.value[i.key] || 0)))
const questions = computed(() => {
  if (d.value.series) {
    const series = d.value.series
    return series.flatMap(serie => serie.filas.map(fila => ({
      text: `¿Cuántas medallas obtuvo ${fila.categoria} en ${serie.anio}?`,
      answer: fila.total,
      hint: `Busquen el gráfico del año ${serie.anio} y la barra de ${fila.categoria}.`
    }))).slice(0, d.value.num_preguntas || 6)
  }
  if (!targetItems.value.length || isSurvey.value) return []
  const items = targetItems.value
  const total = items.reduce((sum, i) => sum + i.value, 0)
  const count = d.value.num_preguntas || Math.min(items.length + 2, 6)
  return [
    ...items.slice(0, Math.max(0, count - 2)).map(i => ({ text: `¿Cuántas unidades corresponden a ${i.label}?`, answer: i.value })),
    { text: '¿Cuántas unidades hay en total?', answer: total },
    { text: '¿Cuál es la diferencia entre la cantidad mayor y la menor?', answer: Math.max(...items.map(i => i.value)) - Math.min(...items.map(i => i.value)) }
  ]
})
function vote(i) {
  if (totalVotes.value >= limit.value) return
  const key = groupKey.value + i
  counts.value[key] = (counts.value[key] || 0) + 1
  voteHistory.value.push(key)
}
function resetSurvey() {
  options.value.forEach((_, i) => { counts.value[groupKey.value + i] = 0 })
  voteHistory.value = voteHistory.value.filter(key => !key.startsWith(groupKey.value))
  lastRoll.value = null
}
function adjustBar(key, value) {
  counts.value[key] = Math.min(maximum.value, Math.max(0, Math.trunc(Number(value) || 0)))
  checked.value = false
}
function undoVote() {
  const index = voteHistory.value.findLastIndex(key => key.startsWith(groupKey.value))
  if (index < 0) return
  const [key] = voteHistory.value.splice(index, 1)
  counts.value[key] = Math.max(0, (counts.value[key] || 0) - 1)
}
function roll() {
  if (totalVotes.value >= limit.value) return
  if (d.value.dados) {
    const dice = [1 + Math.floor(Math.random() * 6), 1 + Math.floor(Math.random() * 6)]
    lastRoll.value = { dice, text: `${dice[0]} + ${dice[1]} = ${dice[0] + dice[1]}` }
    vote(dice[0] + dice[1] - 2)
  } else {
    const i = Math.floor(Math.random() * 2)
    lastRoll.value = { text: d.value.moneda.opciones[i] }
    vote(i)
  }
}
const puzzleQuestions = computed(() => [
  { text: '¿Cuántas cartas tiene Josefa?', answer: 15, hint: 'Entre Josefa y Matías tienen 20 cartas. Josefa tiene 10 más que Matías.' },
  { text: '¿Cuántas cartas tiene Matías?', answer: 5, hint: 'Sumen las cartas conocidas y resten esa suma de 75. Repartan lo que queda usando la pista.' }
])
</script>

<template>
  <section class="resource" :style="{ '--mission-color': theme.color, '--mission-tint': theme.tint }">
    <header class="mission-header">
      <span class="mission-icon" aria-hidden="true">{{ theme.icon }}</span>
      <div><p class="reference">MISIÓN · {{ actividad.seccion }} · Página {{ actividad.pagina }}</p>
      <h1>{{ actividad.titulo }}</h1><p class="mission-cheer">{{ theme.invitation }}</p></div>
    </header>
    <div class="guide"><span aria-hidden="true">🦉</span><p>{{ actividad.descripcion }}</p></div>

    <div v-if="d.tipos" class="summary">
      <article v-for="(tipo, i) in d.tipos" :key="tipo" class="discovery-card">
        <button class="discovery-toggle" :aria-expanded="!!flipped[tipo]" @click="flipped[tipo] = !flipped[tipo]"><span aria-hidden="true">{{ ['🎨', '🏗️', '🪁'][i] }}</span><h2>{{ tipo }}</h2><small>{{ flipped[tipo] ? '¡Misterio descubierto! ✨' : 'Toca para descubrir el secreto ↻' }}</small></button>
        <div v-if="flipped[tipo]" class="discovery-answer">
        <p v-if="tipo === 'pictograma'">Representa cantidades con símbolos. Lee la clave para conocer el valor de cada símbolo.</p>
        <p v-else-if="tipo === 'gráfico de barra'">Compara cantidades mediante barras. Revisa el título, las categorías y la graduación de los ejes.</p>
        <p v-else>Cada punto representa un dato. Cuenta los puntos de cada categoría para comparar sus frecuencias.</p>
        </div>
      </article>
    </div>

    <div v-if="isSurvey" class="survey">
      <div v-if="surveys.length > 1 || isCustom" class="controls">
        <button v-for="(_, i) in (isCustom ? Array.from({ length: d.num_encuestas || 1 }) : surveys)" :key="i" :aria-pressed="surveyIndex === i" @click="surveyIndex = i">Encuesta {{ i + 1 }}</button>
      </div>
      <div v-if="isCustom" class="custom">
        <label>Pregunta <input v-model="customQuestion" placeholder="Escribe la pregunta de la encuesta" /></label>
        <label v-for="(_, i) in customOptions" :key="i">Opción {{ i + 1 }} <input v-model="customOptions[i]" /></label>
      </div>
      <h2>{{ question }}</h2>
      <p v-if="d.dados">Lancen dos dados y registren la suma. Las sumas posibles van de 2 a 12.</p>
      <div v-if="d.dado" class="table-wrap">
        <h3>Registro del dado</h3>
        <table><thead><tr><th>Resultado</th><th>Frecuencia</th></tr></thead><tbody><tr v-for="row in d.dado" :key="row.categoria"><td>{{ row.categoria }}</td><td>{{ row.total }}</td></tr></tbody></table>
        <h3>Ahora registren los lanzamientos de la moneda</h3>
      </div>
      <div v-if="d.dados || d.moneda" class="experiment">
        <div class="roll-display" aria-live="polite"><span aria-hidden="true">{{ d.dados ? '🎲 🎲' : '🪙' }}</span><strong>{{ lastRoll?.text || '¿Qué saldrá esta vez?' }}</strong></div>
        <button class="roll-button" :disabled="totalVotes >= limit" @click="roll">{{ d.dados ? '¡Lanzar los dados!' : '¡Lanzar la moneda!' }} ✨</button>
        <p>El resultado se registra en la tabla. También pueden usar sus propios dados y tocar el resultado.</p>
      </div>
      <div class="vote-tiles">
        <button v-for="(row, i) in surveyRows" :key="i" class="vote-tile" :disabled="totalVotes >= limit || (isCustom && !customOptions[i].trim())" @click="vote(i)"><span class="vote-icon" aria-hidden="true">{{ d.dados ? '🎲' : emojiFor(row.categoria) }}</span><strong>{{ row.categoria }}</strong><span class="vote-count">{{ row.total }}</span><small>¡Sumar uno! +</small></button>
      </div>
      <div class="survey-footer"><p role="status">{{ totalVotes === limit ? '🌟 ¡Registro completo!' : '🧩 Cada respuesta cuenta' }} · {{ totalVotes }}<span v-if="Number.isFinite(limit)"> / {{ limit }}</span></p><div class="controls"><button class="soft-button" :disabled="!surveyRows.some((_, i) => counts[groupKey + i])" @click="undoVote">↶ Deshacer</button><button class="soft-button" @click="resetSurvey">↻ Reiniciar registro</button></div></div>
      <div v-if="Number.isFinite(limit)" class="vote-progress" role="progressbar" aria-label="Respuestas registradas" :aria-valuenow="totalVotes" :aria-valuemax="limit" aria-valuemin="0"><span :style="{ width: `${totalVotes / limit * 100}%` }"></span></div>
    </div>

    <div v-if="rows.length" class="data-layout">
      <div class="table-wrap">
        <h2>{{ d.titulo }}</h2>
        <table>
          <thead><tr><th>Categoría</th><th>Cantidad</th><th v-if="isBuild">Nuestro gráfico</th></tr></thead>
          <tbody><tr v-for="item in targetItems" :key="item.key">
            <th scope="row"><span aria-hidden="true">{{ item.emoji }}</span> {{ item.label }}</th><td><span class="quantity">{{ item.value }}</span></td>
            <td v-if="isBuild"><div class="builder-controls"><button class="step-button" :aria-label="`Quitar uno de ${item.label}`" :disabled="!counts[item.key]" @click="adjustBar(item.key, (counts[item.key] || 0) - 1)">−</button><output :aria-label="`Cantidad construida para ${item.label}`">{{ counts[item.key] || 0 }}</output><button class="step-button" :aria-label="`Agregar uno a ${item.label}`" :disabled="counts[item.key] >= maximum" @click="adjustBar(item.key, (counts[item.key] || 0) + 1)">+</button></div><input class="bar-slider" :value="counts[item.key] || 0" type="range" min="0" step="1" :max="maximum" :aria-label="`Mover barra de ${item.label}`" @input="adjustBar(item.key, $event.target.value)" /></td>
          </tr></tbody>
        </table>
      </div>
      <div v-if="actividad.seccion !== 'Tablas'" class="graph-panel">
        <div class="controls">
          <label v-if="graphType === 'pictograma'">Valor del símbolo
            <select v-model.number="symbolScale"><option v-for="n in [...new Set([d.valor_simbolo || 1, ...(d.valores_simbolo || [])])]" :key="n" :value="n">{{ n }}</option></select>
          </label>
          <label v-if="d.orientaciones">Orientación <select v-model="orientation"><option v-for="o in d.orientaciones" :key="o">{{ o }}</option></select></label>
          <label v-if="actividad.pagina === 420">Representación <select v-model="graphType"><option value="pictograma">Pictograma</option><option value="puntos">Diagrama de puntos</option></select></label>
        </div>
        <ActivityGraph :items="chartItems" :title="isBuild ? 'Nuestro gráfico' : d.titulo" :type="graphType" :scale="symbolScale" :step="d.escala" :orientation="orientation" :max="maximum" />
      </div>
    </div>

    <div v-if="isBuild && rows.length" class="build-check">
      <p>🏗️ Arrastren los controles o usen + y − para construir el gráfico.</p>
      <div class="controls"><button @click="checked = true">¡Comprobar mi creación! ✨</button><button class="soft-button" @click="buildingHint = !buildingHint">💡 Una ayudita</button></div>
      <p v-if="buildingHint">El número de cada barra debe coincidir con la cantidad que está a su lado en la tabla.</p>
      <p v-if="checked" class="build-feedback" :class="{ success: buildOK }" role="status">{{ buildOK ? '🏆 ¡Construcción increíble! El gráfico coincide con la tabla.' : '🌱 ¡Van por buen camino! Comparen las barras con la tabla y sigan construyendo.' }}</p>
    </div>

    <div v-if="d.series" class="series">
      <ActivityGraph v-for="serie in d.series" :key="serie.anio" :items="itemsFor(serie.filas)" :title="`${d.titulo} · ${serie.anio}`" :step="d.escala" :max="Math.max(...d.series.flatMap(s => s.filas.map(f => f.total)))" />
      <p>Comparen ambos años: ¿qué países aumentaron o disminuyeron su cantidad de medallas?</p>
    </div>

    <div v-if="sets.length" class="sets">
      <p>Observen el diagrama de la página {{ actividad.pagina }} del texto y registren cuántos niños hay en cada región. Cuenten cada niño una sola vez.</p>
      <div v-for="(label, i) in combinations" :key="label" class="ice-card"><span aria-hidden="true">🍦</span><strong>{{ i < 3 ? 'Solo ' : '' }}{{ label }}</strong><div class="builder-controls"><button :aria-label="`Quitar uno de ${label}`" :disabled="!counts[label]" @click="counts[label] = Math.max(0, (counts[label] || 0) - 1)">−</button><output>{{ counts[label] || 0 }}</output><button :aria-label="`Agregar uno a ${label}`" @click="counts[label] = (counts[label] || 0) + 1">+</button></div></div>
      <p>Total de niños registrados: {{ Object.values(counts).reduce((a, n) => a + (Number(n) || 0), 0) }}</p>
    </div>

    <div v-if="d.simbolos_conocidos" class="puzzle-intro"><p>🃏 Total: {{ d.total_cartas }} cartas. {{ d.condicion }}. Cada símbolo representa {{ d.valor_simbolo }} cartas.</p><QuizChallenge :questions="puzzleQuestions" /></div>
    <QuizChallenge v-if="questions.length && !d.simbolos_conocidos" :questions="questions" />
    <label v-if="d.num_preguntas_a_inventar" class="reflection">Inventen y respondan {{ d.num_preguntas_a_inventar }} preguntas sobre estos datos.<textarea rows="4" /></label>
  </section>
</template>

<style scoped>
.resource { display: grid; gap: 20px; }
h1 { font-size: 28px; margin: 0; }
h2 { font-size: 21px; }
.reference { margin: 0; color: #51457b; font-weight: 700; }
.description { font-size: 20px; margin: 0; }
.data-layout, .series { display: grid; grid-template-columns: minmax(260px, 1fr) minmax(0, 2fr); gap: 24px; align-items: start; }
.series { grid-template-columns: repeat(2, minmax(0, 1fr)); }
.series p { grid-column: 1 / -1; }
.table-wrap { overflow-x: auto; }
table { border-collapse: collapse; width: 100%; background: white; }
td, th { padding: 10px; border: 1px solid #c9c8d6; text-align: left; }
thead { background: #ece7ff; }
input, select, textarea { font: inherit; padding: 8px; border: 2px solid #9e98b8; border-radius: 8px; max-width: 100%; }
input[type=number] { width: 90px; }
input { background: #fff; }
.controls { display: flex; flex-wrap: wrap; gap: 12px; align-items: center; margin-bottom: 16px; }
button { font: inherit; font-weight: 700; padding: 10px 16px; background: #5636ff; color: white; border: 0; border-radius: 10px; cursor: pointer; }
button:disabled { opacity: .45; cursor: default; }
button[aria-pressed=false] { background: #eee9ff; color: #362475; }
.custom, .sets, .summary { display: grid; gap: 14px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
label { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.questions { padding: 20px; background: white; border-radius: 14px; }
.questions label { margin: 16px 0; }
.questions summary { cursor: pointer; font-weight: 700; }
.summary article { background: white; border-radius: 14px; padding: 20px; }
.reflection { flex-direction: column; align-items: stretch; }
@media(max-width: 820px) { .data-layout, .series { grid-template-columns: 1fr; } }

.resource { gap: 26px; }
.mission-header { display: flex; gap: 22px; align-items: center; padding: 28px; background: white; border: 2px solid #e9e0f2; border-radius: 28px; box-shadow: 0 6px 0 #e4ddec; }
.mission-icon { display: grid; place-items: center; flex-shrink: 0; width: 95px; height: 95px; border-radius: 26px; background: var(--mission-tint); font-size: 52px; transform: rotate(-6deg); }
.reference { font-size: 11px; letter-spacing: 1px; color: var(--mission-color); margin-bottom: 10px; font-weight: 900; }
h1 { font-size: clamp(23px, 3vw, 33px); color: #352b4c; line-height: 1.2; }
.mission-cheer { color: var(--mission-color); font-size: 15px; font-weight: 800; margin-top: 10px; }
.guide { display: flex; gap: 16px; align-items: center; padding: 18px 24px; background: #fff8e9; border: 1px solid #eadbb8; border-radius: 22px; color: #715d3b; }
.guide > span { font-size: 35px; }
.guide p { font-size: 17px; line-height: 1.6; }
.survey, .table-wrap, .graph-panel, .experiment, .build-check, .series { padding: 24px; border-radius: 25px; background: white; border: 2px solid #e8e1ef; }
.survey h2 { margin-bottom: 18px; }
.survey .table-wrap { border: 0; padding: 0 0 20px; }
.data-layout { grid-template-columns: minmax(310px, 1fr) minmax(0, 1.4fr); }
.table-wrap h2 { font-size: 20px; margin-bottom: 16px; }
.table-wrap { padding: 20px; }
.table-wrap:only-child { grid-column: 1 / -1; }
.graph-panel { padding: 24px; min-width: 0; }
.table-wrap table { border: 0; }
.table-wrap td, .table-wrap th { border: 0; border-bottom: 1px solid #eee8f2; padding: 12px 9px; }
.table-wrap thead { background: var(--mission-tint); color: var(--mission-color); font-size: 12px; }
.table-wrap tbody th { color: #524663; font-size: 15px; }
.table-wrap tbody th span { margin-right: 5px; }
.quantity { display: inline-grid; place-items: center; min-width: 33px; height: 33px; border-radius: 10px; background: var(--mission-tint); color: var(--mission-color); font-weight: 900; }
button { background: var(--mission-color); box-shadow: 0 3px 0 #0002; border-radius: 14px; }
button:hover:not(:disabled) { transform: translateY(-2px); }
.vote-tiles { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 14px; margin: 18px 0; }
.vote-tile { display: grid; place-items: center; gap: 8px; padding: 22px 12px; background: var(--mission-tint); color: var(--mission-color); border: 2px solid #d9e1ef; border-bottom: 5px solid var(--mission-color); }
.vote-icon { font-size: 35px; }
.vote-count { background: white; padding: 2px 14px; border-radius: 50px; font-size: 22px; }
.vote-tile small { font-size: 12px; }
.survey-footer { display: flex; justify-content: space-between; flex-wrap: wrap; gap: 14px; align-items: center; font-size: 14px; font-weight: 800; color: #61536e; }
.survey-footer .controls { margin: 0; }
.vote-progress { height: 12px; border-radius: 30px; background: #ece7f2; overflow: hidden; margin-top: 18px; }
.vote-progress span { display: block; height: 100%; border-radius: inherit; background: #5b9e85; transition: width .2s; }
.soft-button { background: #f3eef9; color: #635078; box-shadow: none; }
.builder-controls { display: flex; align-items: center; justify-content: center; gap: 8px; }
.builder-controls button { padding: 2px; width: 34px; height: 34px; border-radius: 10px; font-size: 23px; }
.builder-controls output { min-width: 30px; text-align: center; font-weight: 900; font-size: 19px; }
.bar-slider { display: block; width: 100%; min-width: 100px; accent-color: var(--mission-color); cursor: pointer; margin-top: 10px; padding: 0; height: 28px; }
.build-check { display: grid; gap: 16px; }
.build-check .controls { margin: 0; }
.build-feedback { background: #fff4de; color: #7f5820; padding: 16px; border-radius: 16px; font-weight: 800; }
.build-feedback.success { background: #e2f6e9; color: #236048; }
.roll-display { display: flex; gap: 22px; align-items: center; justify-content: center; margin: 10px 0 20px; }
.roll-display > span { font-size: 46px; }
.roll-display strong { font-size: 28px; color: #554078; }
.roll-button { display: block; margin: 0 auto 14px; }
.experiment p { text-align: center; font-size: 13px; color: #786c86; }
.discovery-card { text-align: center; border: 2px solid #e1d8ee; box-shadow: 0 6px 0 #e9e0f2; }
.discovery-toggle { background: transparent; color: #4c396b; box-shadow: none; width: 100%; display: grid; justify-items: center; gap: 16px; }
.discovery-toggle > span { font-size: 52px; }
.discovery-toggle small { font-size: 13px; color: #7e6b95; }
.discovery-answer { padding: 20px 6px 0; font-size: 18px; }
.ice-card { padding: 20px; display: grid; gap: 16px; justify-items: center; text-align: center; background: #fff5e7; border: 2px solid #eedbc2; border-radius: 20px; }
.ice-card > span { font-size: 35px; }
.sets > p { grid-column: 1 / -1; }
.puzzle-intro { display: grid; gap: 20px; }
@media(max-width: 900px) { .data-layout { grid-template-columns: 1fr; } }
@media(max-width: 600px) { .mission-header { padding: 20px; align-items: start; gap: 14px; } .mission-icon { width: 55px; height: 55px; font-size: 30px; border-radius: 16px; } .reference { font-size: 10px; } .survey, .graph-panel { padding: 16px; } .vote-tiles { grid-template-columns: repeat(2, 1fr); } }

</style>
