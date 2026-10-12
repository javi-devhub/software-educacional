<script setup>
import { useAppStore } from '../stores/app'
const store = useAppStore()
const sizes = [{ px: 22, label: 'Normal (22 px)' }, { px: 28, label: 'Grande (28 px)' }]
</script>

<template>
  <section class="cfg">
    <h1>Configuración</h1>
    <div class="card">
      <h3>Tamaño del texto en proyección</h3>
      <div class="row">
        <button v-for="s in sizes" :key="s.px" class="chip" :class="{ on: store.readSize === s.px }" :aria-pressed="store.readSize === s.px" @click="store.setReadSize(s.px)">{{ s.label }}</button>
      </div>
    </div>
  </section>
</template>

<style scoped>
.cfg { display: grid; gap: 12px; max-width: 560px; align-content: start; }
h1 { font-size: 30px; }
h3 { font-size: 20px; margin-bottom: 10px; }
.row { display: flex; gap: 8px; flex-wrap: wrap; }
</style>
