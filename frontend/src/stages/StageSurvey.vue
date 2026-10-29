<script setup>
import { computed } from 'vue'
import { encuesta as encuestaEstatica } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const s = computed(() => store.session)

// Si hay una actividad seleccionada desde la BD, extraemos sus datos dinámicos; sino, usamos los estáticos
const datosActividad = computed(() => {
  const act = store.actividadActual
  if (act && act.datos) {
    const d = act.datos
    // Caso 1: viene con lista de preguntas/encuestas (ej: página 389)
    if (d.encuestas && d.encuestas.length > 0) {
      const enc = d.encuestas[0]
      return {
        pregunta: enc.pregunta,
        opciones: enc.opciones.map(opt => ({
          key: opt.toLowerCase().replace(/\s+/g, '_'),
          emoji: '📌',
          label: opt
        }))
      }
    }
    // Caso 2: viene con filas estructuradas (ej: juego de mesa, color favorito, etc.)
    if (d.filas && d.filas.length > 0) {
      return {
        pregunta: d.titulo || d.titulo_tabla || act.titulo,
        opciones: d.filas.map(f => ({
          key: f.categoria.toLowerCase().replace(/\s+/g, '_'),
          emoji: '📌',
          label: f.categoria
        }))
      }
    }
  }
  return encuestaEstatica
})

const total = computed(() => {
  if (!s.value || !s.value.votes) return 0
  return Object.values(s.value.votes).reduce((a, b) => a + b, 0)
})

const rows = computed(() => {
  if (!s.value || !s.value.votes) return []
  const r = datosActividad.value.opciones.map((o) => ({
    ...o,
    n: s.value.votes[o.key] || 0
  }))
  return s.value.sortDesc ? [...r].sort((a, b) => b.n - a.n) : r
})
</script>

<template>
  <div class="survey">
    <h2>Encuesta: {{ datosActividad.pregunta }}</h2>
    <p class="help">Cada estudiante vota y la docente toca la opción elegida. Los votos se ordenan en la tabla.</p>

    <div class="opts" :style="{ gridTemplateColumns: `repeat(${Math.min(datosActividad.opciones.length, 6)}, 1fr)` }">
      <button v-for="o in datosActividad.opciones" :key="o.key" class="vote" @click="store.vote(o.key)">
        <span class="em" aria-hidden="true">{{ o.emoji }}</span>
        <b>{{ o.label }}</b>
        <span class="plus">+1 voto</span>
      </button>
    </div>

    <h3 class="cap">Tabla de votos</h3>
    <table class="tabla">
      <thead>
        <tr>
          <th>Categoría</th>
          <th>Marcas</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="r in rows" :key="r.key">
          <td>{{ r.emoji }} {{ r.label }}</td>
          <td class="marks"><span v-for="n in r.n" :key="n" aria-hidden="true">●</span></td>
          <td class="n">{{ r.n }}</td>
        </tr>
      </tbody>
      <tfoot>
        <tr>
          <td colspan="2">Total de votos</td>
          <td class="n">{{ total }}</td>
        </tr>
      </tfoot>
    </table>

    <div class="row">
      <button class="btn btn-sec" @click="store.toggleSort()">
        {{ s?.sortDesc ? 'Volver al orden original' : 'Ordenar de mayor a menor' }}
      </button>
      <button class="btn btn-sec" @click="store.loadSample()">Cargar votos de ejemplo</button>
      <button class="btn btn-sec" @click="store.resetVotes()">Borrar votos</button>
    </div>
  </div>
</template>

<style scoped>
h2 { font-size: 30px; margin-bottom: 4px; }
.help { font-size: 19px; color: var(--text-muted); margin-bottom: 14px; }
.opts { display: grid; gap: 10px; margin-bottom: 16px; }
.vote { display: grid; justify-items: center; gap: 2px; padding: 10px 6px; border-radius: 18px; border: 3px solid var(--c, #5636FF); background: var(--t, #EDE9FE); font: 700 19px var(--font-body); color: var(--text-main); cursor: pointer; }
.vote:nth-child(1) { --c: #2F6BFF; --t: #E4ECFF; }
.vote:nth-child(2) { --c: #8B3DFF; --t: #EFE4FF; }
.vote:nth-child(3) { --c: #FF8A00; --t: #FFEBD2; }
.vote:nth-child(4) { --c: #00A6C7; --t: #D6F3FA; }
.vote:nth-child(5) { --c: #10B981; --t: #D1FAE5; }
.vote:nth-child(6) { --c: #EC4899; --t: #FCE7F3; }
.vote:hover { transform: translateY(-2px); }
.vote:active { transform: scale(.97); }
.em { font-size: 38px; line-height: 1.1; }
.plus { font-size: 15px; font-weight: 800; color: var(--text-muted); }
.tabla { width: 100%; border-collapse: separate; border-spacing: 0; border: 3px solid var(--text-main); border-radius: 14px; overflow: hidden; font-size: 20px; margin-bottom: 14px; }
.cap { font: 700 20px var(--font-title); margin-bottom: 6px; }
th { background: var(--text-main); color: #fff; text-align: left; padding: 8px 14px; font-weight: 800; }
td { padding: 8px 14px; border-top: 2px solid var(--border-card); font-weight: 700; }
.marks { color: var(--brand-primary); letter-spacing: 3px; font-size: 18px; }
.n { text-align: right; font: 800 22px var(--font-title); width: 90px; }
tfoot td { background: #FFF3C4; border-top: 3px solid var(--text-main); font-weight: 800; }
.row { display: flex; gap: 8px; flex-wrap: wrap; }
@media (max-width: 820px) { .opts { grid-template-columns: repeat(2, 1fr) !important; } }
</style>