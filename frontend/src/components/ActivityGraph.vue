<script setup>
import { computed } from 'vue'
import BarChart from './BarChart.vue'
import Pictogram from './Pictogram.vue'

const props = defineProps({
  items: { type: Array, required: true },
  title: { type: String, default: '' },
  type: { type: String, default: 'barras' },
  scale: { type: Number, default: 1 },
  step: { type: Number, default: 1 },
  orientation: { type: String, default: 'vertical' },
  max: { type: Number, default: 0 }
})
const maximum = computed(() => Math.max(props.max, ...props.items.map(i => i.value), 1))
const ticks = computed(() => Array.from({ length: Math.ceil(maximum.value / props.step) + 1 }, (_, i) => i * props.step))
</script>

<template>
  <Pictogram v-if="type === 'pictograma'" :items="items" :title="title" :scale="scale" />
  <figure v-else-if="type === 'puntos' || type === 'diagrama de puntos'" class="points">
    <figcaption>{{ title }}</figcaption>
    <div class="dot-columns">
      <div v-for="item in items" :key="item.key" class="dot-column">
        <strong>{{ item.value }}</strong>
        <span class="dots" :aria-label="`${item.value} puntos`"><span v-for="n in item.value" :key="n" aria-hidden="true">●</span></span>
        <b>{{ item.label }}</b>
      </div>
    </div>
    <p>Cada punto representa 1 unidad.</p>
  </figure>
  <figure v-else-if="orientation === 'horizontal'" class="horizontal">
    <figcaption>{{ title }}</figcaption>
    <div v-for="item in items" :key="item.key" class="horizontal-row">
      <b>{{ item.label }}</b>
      <div class="track"><div class="bar" :style="{ width: `${item.value / ticks.at(-1) * 100}%` }"></div></div>
      <strong>{{ item.value }}</strong>
    </div>
    <div class="ticks"><span v-for="n in ticks" :key="n">{{ n }}</span></div>
  </figure>
  <div v-else class="scroll-chart">
    <div :style="{ minWidth: `${Math.max(360, items.length * 75)}px` }">
      <BarChart :items="items" :title="title" :max="maximum" :step="step" />
    </div>
  </div>
</template>

<style scoped>
figure { margin: 0; }
figcaption { font-weight: 800; text-align: center; margin-bottom: 18px; }
.scroll-chart { overflow-x: auto; padding-top: 8px; }
.dot-columns { display: flex; align-items: end; gap: 16px; overflow-x: auto; padding-bottom: 10px; }
.dot-column { display: flex; flex-direction: column; align-items: center; gap: 8px; min-width: 85px; flex: 1; text-align: center; }
.dots { display: flex; flex-direction: column-reverse; min-height: 12px; line-height: 1.1; color: #5636ff; }
.dot-column b { border-top: 3px solid #333; padding-top: 8px; width: 100%; }
.horizontal-row { display: grid; grid-template-columns: 120px 1fr 40px; gap: 12px; align-items: center; margin: 12px 0; }
.track { background: #e9e7f5; border-left: 2px solid #333; }
.bar { height: 28px; background: #5636ff; }
.ticks { display: flex; justify-content: space-between; margin: 8px 52px 0 132px; font-size: 14px; }
</style>
