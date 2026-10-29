<script setup>
import { computed } from 'vue'
import BarChart from '../components/BarChart.vue'
import { datosDeportes as datosEstaticos } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const s = computed(() => store.session)

const datosActividad = computed(() => {
  const act = store.actividadActual
  if (act && act.datos && act.datos.filas) {
    const maximo = Math.max(...act.datos.filas.map(f => f.total || f.cantidad || 0), 8)
    return {
      titulo: act.datos.titulo || act.titulo,
      max: maximo,
      items: act.datos.filas.map(f => ({
        key: f.categoria.toLowerCase().replace(/\s+/g, '_'),
        emoji: '📊',
        label: f.categoria,
        value: f.total || f.cantidad || 0
      }))
    }
  }
  return datosEstaticos
})

// El gráfico que va armando el curso con los botones
const items = computed(() => {
  if (!s.value || !s.value.chart) return []
  return datosActividad.value.items.map((d) => ({
    ...d,
    value: s.value.chart[d.key] || 0
  }))
})

const labelOf = (key) => datosActividad.value.items.find((d) => d.key === key)?.label || key
</script>

<template>
  <div class="build">
    <h2>Creamos el gráfico</h2>
    <p class="help">Usen la tabla para construir el gráfico de barras. Suban o bajen cada barra con los botones.</p>
    <div class="grid">
      <div>
        <h3 class="cap">{{ datosActividad.titulo }}</h3>
        <table class="tabla">
          <thead><tr><th>Categoría</th><th>Cantidad</th></tr></thead>
          <tbody>
            <tr v-for="d in datosActividad.items" :key="d.key">
              <td>{{ d.emoji }} {{ d.label }}</td>
              <td class="n">{{ d.value }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <BarChart 
        :items="items" 
        :max="datosActividad.max" 
        title="Nuestro gráfico" 
        :height="210" 
        :wrong="s.checked && !s.checked.ok ? s.checked.wrong : []"
      >
        <template #foot="{ item }">
          <span class="ctl">
            <button class="step" :aria-label="'Bajar ' + item.label" @click="store.setBar(item.key, -1)">▼</button>
            <button class="step" :aria-label="'Subir ' + item.label" @click="store.setBar(item.key, 1)">▲</button>
          </span>
        </template>
      </BarChart>
    </div>
    <div class="check">
      <button class="btn btn-cta" @click="store.checkChart()">Revisar gráfico</button>
      <p v-if="s.checked" class="msg" :class="s.checked.ok ? 'good' : 'bad'" role="status">
        {{ s.checked.ok ? '¡Muy bien! El gráfico coincide con la tabla.' : 'Casi. Revisen la barra de ' + s.checked.wrong.map(labelOf).join(' y ') + '.' }}
      </p>
    </div>
  </div>
</template>

<style scoped>
h2 { font-size: 30px; margin-bottom: 4px; }
.help { font-size: 19px; color: var(--text-muted); margin-bottom: 14px; }
.grid { display: grid; grid-template-columns: 320px 1fr; gap: 22px; align-items: start; }
.tabla { width: 100%; border-collapse: separate; border-spacing: 0; border: 3px solid var(--text-main); border-radius: 14px; overflow: hidden; font-size: 20px; }
.cap { font: 700 19px var(--font-title); margin-bottom: 6px; }
th { background: var(--text-main); color: #fff; text-align: left; padding: 8px 12px; font-weight: 800; font-size: 17px; }
td { padding: 8px 12px; border-top: 2px solid var(--border-card); font-weight: 700; }
.n { text-align: right; font: 800 22px var(--font-title); }
.ctl { display: flex; gap: 4px; margin-top: 4px; }
.step { border: 2px solid #00A6C7; background: #D6F3FA; color: var(--text-main); border-radius: 10px; width: 38px; height: 34px; font-size: 16px; cursor: pointer; }
.step:hover { background: #BDEBF6; }
.check { display: flex; align-items: center; gap: 14px; flex-wrap: wrap; margin-top: 16px; }
.msg { border-radius: 14px; padding: 10px 14px; font-weight: 800; font-size: 19px; }
.msg.good { background: #ECFDF5; color: #065F46; }
.msg.bad { background: #FFF1F2; color: #9F1239; }
@media (max-width: 820px) { .grid { grid-template-columns: 1fr; } }
</style>