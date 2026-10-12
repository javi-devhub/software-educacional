<script setup>
defineProps({
  items: { type: Array, required: true },
  title: { type: String, default: '' }
})
</script>

<template>
  <figure class="pg">
    <figcaption>{{ title }}</figcaption>
    <div v-for="it in items" :key="it.key" class="row">
      <b class="lab">{{ it.label }}</b>
      <span class="icons"><span v-for="n in it.value" :key="n" aria-hidden="true">{{ it.emoji }}</span></span>
    </div>
    <p class="key">Cada ícono = 1 estudiante</p>
  </figure>
</template>

<style scoped>
.pg { margin: 0; }
figcaption { font: 700 20px var(--font-title); text-align: center; margin-bottom: 10px; }
.row { display: grid; grid-template-columns: 110px 1fr; align-items: center; gap: 12px; padding: 6px 0; border-bottom: 2px solid var(--border-card); }
.lab { font-size: 18px; }
.icons { display: flex; flex-wrap: wrap; gap: 4px; font-size: 30px; line-height: 1.1; }
.key { margin-top: 10px; font-weight: 800; text-align: right; color: var(--text-muted); }
</style>