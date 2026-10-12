<script setup>
import { computed } from 'vue'
import BarChart from '../components/BarChart.vue'
import { datosMascotas, preguntas } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const s = computed(() => store.session)
const p = computed(() => preguntas[s.value.qi])
const ans = computed(() => s.value.quiz[s.value.qi])
const cls = (i) => (ans.value?.sel === i ? (ans.value.ok ? 'good' : 'bad') : '')
</script>

<template>
  <div class="interp">
    <h2>Interpretamos la información</h2>
    <div class="grid">
      <BarChart :items="datosMascotas.items" :title="datosMascotas.titulo" :height="200" />
      <div class="qa">
        <div class="qtabs">
          <button v-for="(_, i) in preguntas" :key="i" class="qtab" :class="{ on: i === s.qi, ok: s.quiz[i]?.ok }" @click="store.setQuestion(i)">
            {{ s.quiz[i]?.ok ? '✓' : '' }} Pregunta {{ i + 1 }}
          </button>
        </div>
        <h3>{{ p.q }}</h3>
        <div class="opts">
          <button v-for="(o, i) in p.options" :key="i" class="qopt" :class="cls(i)" @click="store.answerQuiz(s.qi, i)">
            <span aria-hidden="true">{{ o[0] }}</span>{{ o[1] }}
          </button>
        </div>
        <p v-if="ans" class="msg" :class="ans.ok ? 'good' : 'bad'" role="status">
          {{ ans.ok ? '¡Muy bien! Leyeron bien el gráfico.' : 'Inténtenlo de nuevo. ' + p.hint }}
        </p>
        <p v-else class="msg" role="status">Miren el gráfico y elijan una respuesta entre todos.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
h2 { font-size: 30px; margin-bottom: 12px; }
.grid { display: grid; grid-template-columns: 1.1fr 1fr; gap: 22px; align-items: start; }
.qtabs { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 10px; }
.qtab { border: 3px solid var(--border-card); background: #fff; border-radius: 99px; padding: 5px 14px; font: 800 17px var(--font-body); color: var(--text-main); cursor: pointer; }
.qtab.on { background: #FF8A00; border-color: #FF8A00; color: var(--text-main); }
.qtab.ok:not(.on) { border-color: var(--feedback-success); }
h3 { font-size: 26px; margin-bottom: 12px; }
.opts { display: grid; gap: 8px; }
.qopt { display: flex; align-items: center; gap: 12px; text-align: left; background: #FFEBD2; border: 3px solid #FF8A00; border-radius: 16px; padding: 10px 14px; font: 800 21px var(--font-body); color: var(--text-main); cursor: pointer; }
.qopt span { font-size: 30px; }
.qopt:hover { transform: translateY(-1px); }
.qopt.good { border-color: var(--feedback-success); background: #DDF8EA; }
.qopt.bad { border-color: var(--feedback-alert); background: #FFE3E8; }
.msg { margin-top: 12px; border-radius: 14px; padding: 10px 14px; font-weight: 800; font-size: 19px; background: var(--bg-main); }
.msg.good { background: #ECFDF5; color: #065F46; }
.msg.bad { background: #FFF1F2; color: #9F1239; }
@media (max-width: 820px) { .grid { grid-template-columns: 1fr; } }
</style>
