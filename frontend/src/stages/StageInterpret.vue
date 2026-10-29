<script setup>
import { computed } from 'vue'
import BarChart from '../components/BarChart.vue'
import { datosMascotas as datosEstaticos, preguntas as preguntasEstaticas } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const s = computed(() => store.session)

// Datos del gráfico (dinámicos si provienen de la BD)
const datosGrafico = computed(() => {
  const act = store.actividadActual
  if (act && act.datos && act.datos.filas) {
    return {
      titulo: act.datos.titulo || act.titulo,
      escala: act.datos.escala || act.datos.escala_eje || null,
      items: act.datos.filas.map(f => ({
        key: f.categoria.toLowerCase().replace(/\s+/g, '_'),
        label: f.categoria,
        value: f.total || f.cantidad || 0
      }))
    }
  }
  return datosEstaticos
})

const valorMaximo = computed(() => {
  const valores = datosGrafico.value.items.map(i => i.value)
  return Math.max(...valores, 10)
})

// Preguntas dinámicas basadas en los datos de la actividad
const listaPreguntas = computed(() => {
  const act = store.actividadActual
  if (act && act.datos) {
    // Si la actividad trae preguntas explícitas en su JSON
    if (act.datos.preguntas && act.datos.preguntas.length > 0) {
      return act.datos.preguntas.map((pr) => {
        const respuestaCorrecta = pr.r || pr.respuesta
        // Crear alternativas distractoras
        const otrasCategorias = datosGrafico.value.items
          .map(i => i.label)
          .filter(l => String(l).toLowerCase() !== String(respuestaCorrecta).toLowerCase())
        
        const distractor1 = otrasCategorias[0] || '10'
        const distractor2 = otrasCategorias[1] || '25'

        return {
          q: pr.p || pr.q,
          hint: 'Miren la altura de las barras y comparen los valores.',
          options: [
            ['🔘', respuestaCorrecta, true],
            ['🔘', distractor1, false],
            ['🔘', distractor2, false]
          ].sort(() => Math.random() - 0.5)
        }
      })
    }

    // Si tiene filas numéricas (ej. Kg de fruta), generamos preguntas sobre esos datos
    if (act.datos.filas && act.datos.filas.length > 1) {
      const ordenados = [...act.datos.filas].sort((a, b) => (b.total || b.cantidad || 0) - (a.total || a.cantidad || 0))
      const mayor = ordenados[0]
      const menor = ordenados[ordenados.length - 1]
      const totalGeneral = act.datos.filas.reduce((acc, f) => acc + (f.total || f.cantidad || 0), 0)

      return [
        {
          q: `¿Cuál categoría tiene la mayor cantidad en el gráfico?`,
          hint: 'Busquen la barra más alta del gráfico.',
          options: [
            ['🍎', mayor.categoria, true],
            ['🍊', menor.categoria, false],
            ['🍇', ordenados[1]?.categoria || 'Otra', false]
          ].sort(() => Math.random() - 0.5)
        },
        {
          q: `¿Cuántas unidades se registraron para ${mayor.categoria}?`,
          hint: `Miren el número que indica la barra de ${mayor.categoria}.`,
          options: [
            ['1️⃣', `${mayor.total || mayor.cantidad}`, true],
            ['2️⃣', `${menor.total || menor.cantidad}`, false],
            ['3️⃣', `${(mayor.total || mayor.cantidad) + 10}`, false]
          ].sort(() => Math.random() - 0.5)
        },
        {
          q: `¿Cuál es el total acumulado entre todas las categorías?`,
          hint: 'Sumen los valores indicados sobre cada barra.',
          options: [
            ['➕', `${totalGeneral}`, true],
            ['➕', `${totalGeneral - 10}`, false],
            ['➕', `${totalGeneral + 15}`, false]
          ].sort(() => Math.random() - 0.5)
        }
      ]
    }
  }

  return preguntasEstaticas
})

const p = computed(() => listaPreguntas.value[s.value?.qi || 0] || listaPreguntas.value[0])
const ans = computed(() => s.value?.quiz?.[s.value?.qi || 0])
const cls = (opt) => {
  if (!ans.value) return ''
  if (ans.value.selText === opt[1]) {
    return ans.value.ok ? 'good' : 'bad'
  }
  return ''
}

function responder(opcion) {
  const indexPregunta = s.value?.qi || 0
  const esCorrecta = opcion[2] === true
  
  if (!store.session.quiz) store.session.quiz = {}
  store.session.quiz[indexPregunta] = {
    selText: opcion[1],
    ok: esCorrecta
  }
}
</script>

<template>
  <div class="interp">
    <h2>Interpretamos la información</h2>
    <div class="grid">
      <BarChart 
        :items="datosGrafico.items" 
        :title="datosGrafico.titulo" 
        :height="230" 
        :max="valorMaximo" 
        :step="datosGrafico.escala"
      />
      
      <div class="qa">
        <div class="qtabs">
          <button 
            v-for="(_, i) in listaPreguntas" 
            :key="i" 
            class="qtab" 
            :class="{ on: i === (s?.qi || 0), ok: s?.quiz?.[i]?.ok }" 
            @click="store.setQuestion(i)"
          >
            {{ s?.quiz?.[i]?.ok ? '✓' : '' }} Pregunta {{ i + 1 }}
          </button>
        </div>
        
        <h3>{{ p.q }}</h3>
        
        <div class="opts">
          <button 
            v-for="(o, i) in p.options" 
            :key="i" 
            class="qopt" 
            :class="cls(o)" 
            @click="responder(o)"
          >
            <span aria-hidden="true">{{ o[0] }}</span>
            {{ o[1] }}
          </button>
        </div>
        
        <p v-if="ans" class="msg" :class="ans.ok ? 'good' : 'bad'" role="status">
          {{ ans.ok ? '¡Muy bien! Leyeron correctamente el gráfico.' : 'Inténtenlo de nuevo. ' + p.hint }}
        </p>
        <p v-else class="msg" role="status">Miren el gráfico y elijan una respuesta entre todos.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
h2 { font-size: 30px; margin-bottom: 12px; }
.grid { display: grid; grid-template-columns: 1.15fr 1fr; gap: 24px; align-items: start; }
.qtabs { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 12px; }
.qtab { border: 3px solid var(--border-card); background: #fff; border-radius: 99px; padding: 6px 14px; font: 800 16px var(--font-body); color: var(--text-main); cursor: pointer; }
.qtab.on { background: #FF8A00; border-color: #FF8A00; color: #fff; }
.qtab.ok:not(.on) { border-color: var(--feedback-success); }
h3 { font-size: 22px; margin-bottom: 14px; line-height: 1.3; }
.opts { display: grid; gap: 10px; }
.qopt { display: flex; align-items: center; gap: 12px; text-align: left; background: #FFEBD2; border: 3px solid #FF8A00; border-radius: 16px; padding: 12px 16px; font: 800 19px var(--font-body); color: var(--text-main); cursor: pointer; }
.qopt span { font-size: 24px; }
.qopt:hover { transform: translateY(-1px); }
.qopt.good { border-color: var(--feedback-success); background: #DDF8EA; }
.qopt.bad { border-color: var(--feedback-alert); background: #FFE3E8; }
.msg { margin-top: 14px; border-radius: 14px; padding: 10px 14px; font-weight: 800; font-size: 17px; background: var(--bg-main); }
.msg.good { background: #ECFDF5; color: #065F46; }
.msg.bad { background: #FFF1F2; color: #9F1239; }
@media (max-width: 820px) { .grid { grid-template-columns: 1fr; } }
</style>