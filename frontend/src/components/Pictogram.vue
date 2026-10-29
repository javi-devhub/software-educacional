<script setup>
defineProps({
  items: { type: Array, required: true },
  title: { type: String, default: '' },
  scale: { type: Number, default: 1 }
})
</script>

<template>
  <figure class="pg">
    <figcaption>{{ title }}</figcaption>
    <div v-for="it in items" :key="it.key" class="row">
      <b class="lab">{{ it.label }}</b>
      <span class="icons" :aria-label="`${it.value} unidades`">
        <span v-for="n in Math.ceil(it.value / scale)" :key="n" class="symbol" aria-hidden="true">
          <span :style="{ clipPath: `inset(0 ${100 - Math.min(1, it.value / scale - n + 1) * 100}% 0 0)` }">{{ it.emoji || '●' }}</span>
        </span>
        <small>{{ it.value }}</small>
      </span>
    </div>
    <p class="key">Cada símbolo = {{ scale }} {{ scale === 1 ? 'unidad' : 'unidades' }}</p>
  </figure>
</template>

<style scoped>
.pg { margin: 0; }
figcaption { font: 700 20px var(--font-title); text-align: center; margin-bottom: 10px; }
.row { display: grid; grid-template-columns: 110px 1fr; align-items: center; gap: 12px; padding: 6px 0; border-bottom: 2px solid var(--border-card); }
.lab { font-size: 18px; }
.icons { display: flex; flex-wrap: wrap; gap: 4px; font-size: 30px; line-height: 1.1; }
.symbol { display: inline-block; }
.icons small { font-size: 16px; align-self: center; margin-left: 8px; }
.key { margin-top: 10px; font-weight: 800; text-align: right; color: var(--text-muted); }
</style>
