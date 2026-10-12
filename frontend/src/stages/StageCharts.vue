<script setup>
import { onMounted, ref } from 'vue'
import BarChart from '../components/BarChart.vue'
import Pictogram from '../components/Pictogram.vue'
import { datosMascotas } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const tab = ref('pictograma')
const partes = {
  pictograma: [
    ['🏷️', 'Título', 'Dice de qué trata la información.'],
    ['🔤', 'Nombres', 'Cada fila es una categoría.'],
    ['🙂', 'Íconos', 'Cada ícono vale 1 estudiante.']
  ],
  barras: [
    ['🏷️', 'Título', 'Dice de qué trata la información.'],
    ['↔️', 'Eje de abajo', 'Muestra las categorías.'],
    ['↕️', 'Eje del lado', 'Es la escala con los números.'],
    ['📶', 'Barras', 'Mientras más alta, más estudiantes.']
  ]
}
const show = (t) => {
  tab.value = t
  store.seeChart(t)
}
onMounted(() => store.seeChart('pictograma'))
</script>

<template>
  <div class="charts">
    <h2>Conocemos los gráficos</h2>
    <p class="help">La misma información se puede mostrar de distintas formas. Toquen cada pestaña.</p>
    <div class="tabs" role="tablist">
      <button class="tab" role="tab" :aria-selected="tab === 'pictograma'" :class="{ on: tab === 'pictograma' }" @click="show('pictograma')">🙂 Pictograma</button>
      <button class="tab" role="tab" :aria-selected="tab === 'barras'" :class="{ on: tab === 'barras' }" @click="show('barras')">📊 Gráfico de barras</button>
    </div>
    <div class="grid">
      <div class="chart">
        <Pictogram v-if="tab === 'pictograma'" :items="datosMascotas.items" :title="datosMascotas.titulo" />
        <BarChart v-else :items="datosMascotas.items" :title="datosMascotas.titulo" :height="210" />
      </div>
      <ul class="parts">
        <li v-for="p in partes[tab]" :key="p[1]"><span class="ic" aria-hidden="true">{{ p[0] }}</span><div><b>{{ p[1] }}</b><span>{{ p[2] }}</span></div></li>
      </ul>
    </div>
  </div>
</template>

<style scoped>
h2 { font-size: 30px; margin-bottom: 4px; }
.help { font-size: 19px; color: var(--text-muted); margin-bottom: 12px; }
.tabs { display: flex; gap: 8px; margin-bottom: 14px; }
.tab { border: 3px solid var(--border-card); background: #fff; border-radius: 99px; padding: 8px 18px; font: 800 19px var(--font-body); color: var(--text-main); cursor: pointer; }
.tab.on { background: #8B3DFF; border-color: #8B3DFF; color: #fff; }
.grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 20px; align-items: start; }
.chart { padding: 8px 4px 0; }
.parts { list-style: none; margin: 0; padding: 0; display: grid; gap: 10px; }
.parts li { display: flex; gap: 12px; align-items: center; background: #EFE4FF; border-radius: 16px; padding: 10px 14px; }
.ic { font-size: 28px; }
.parts b { display: block; font-size: 19px; color: #5B1FB8; }
.parts span:not(.ic) { font-size: 18px; }
@media (max-width: 820px) { .grid { grid-template-columns: 1fr; } }
</style>
