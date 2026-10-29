<script setup>
import { computed } from 'vue'

const props = defineProps({
  items: { type: Array, required: true }, // [{ key, emoji, label, value }]
  max: { type: Number, default: 8 },
  step: { type: Number, default: null },
  title: { type: String, default: '' },
  height: { type: Number, default: 220 },
  wrong: { type: Array, default: () => [] } // claves de barras a revisar
})

// Calcula una escala limpia y proporcional para que no se amontonen los números
const computedStep = computed(() => {
  if (props.step && props.step > 0) return props.step
  if (props.max <= 10) return 2
  if (props.max <= 25) return 5
  if (props.max <= 60) return 10
  if (props.max <= 100) return 20
  return Math.ceil(props.max / 5 / 10) * 10
})

const ticks = computed(() => {
  const s = computedStep.value
  const limit = Math.ceil(props.max / s) * s
  const t = []
  for (let v = limit; v >= 0; v -= s) {
    t.push(v)
  }
  return t
})

const effectiveMax = computed(() => ticks.value[0] || props.max || 1)
const colors = ['#2F6BFF', '#8B3DFF', '#FF8A00', '#00A6C7', '#10B981', '#EC4899']
</script>

<template>
  <figure class="bc" :style="{ '--n': items.length }">
    <figcaption v-if="title">{{ title }}</figcaption>
    
    <div class="wrap">
      <!-- Eje Y con números posicionados exactamente en su línea -->
      <div class="y" :style="{ height: height + 'px' }">
        <span 
          v-for="t in ticks" 
          :key="t" 
          :style="{ bottom: (t / effectiveMax) * 100 + '%' }"
        >
          {{ t }}
        </span>
      </div>

      <!-- Área de trazado de barras y líneas guía -->
      <div class="plot" :style="{ height: height + 'px' }">
        <i 
          v-for="t in ticks" 
          :key="t" 
          class="line" 
          :style="{ bottom: (t / effectiveMax) * 100 + '%' }"
        ></i>
        <div class="cols">
          <div v-for="(it, i) in items" :key="it.key" class="col">
            <div 
              class="bb" 
              :class="{ wrong: wrong.includes(it.key) }" 
              :style="{ 
                height: Math.min(100, Math.max(0, (it.value / effectiveMax) * 100)) + '%', 
                background: colors[i % colors.length] 
              }"
            >
              <span class="val">{{ it.value }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Etiquetas inferiores de cada barra -->
    <div class="labels">
      <div v-for="it in items" :key="it.key" class="lab">
        <span class="e" aria-hidden="true" v-if="it.emoji">{{ it.emoji }}</span>
        <b>{{ it.label }}</b>
        <slot name="foot" :item="it" />
      </div>
    </div>
  </figure>
</template>

<style scoped>
.bc { margin: 0; width: 100%; }
figcaption { font: 700 20px var(--font-title); text-align: center; margin-bottom: 12px; }
.wrap { display: flex; gap: 12px; margin-top: 36px; }

/* Eje Y con posicionamiento relativo a cada porcentaje */
.y { position: relative; width: 40px; font-weight: 800; font-size: 15px; color: var(--text-main); }
.y span { position: absolute; right: 0; transform: translateY(50%); line-height: 1; }

.plot { position: relative; flex: 1; border-left: 3px solid var(--text-main); border-bottom: 3px solid var(--text-main); }
.line { position: absolute; left: 0; right: 0; border-top: 1px dashed var(--border-card); }

.cols { position: absolute; inset: 0; display: grid; grid-template-columns: repeat(var(--n), 1fr); gap: 16px; padding: 0 16px; align-items: end; }
.col { height: 100%; display: flex; align-items: flex-end; }
.bb { position: relative; width: 100%; border-radius: 10px 10px 0 0; transition: height .25s; min-height: 2px; }
.bb.wrong { outline: 4px solid var(--feedback-alert); outline-offset: 2px; }
.val { position: absolute; top: -28px; left: 0; right: 0; text-align: center; font: 800 18px var(--font-body); color: var(--text-main); }

.labels { display: grid; grid-template-columns: repeat(var(--n), 1fr); gap: 16px; margin: 10px 0 0 52px; padding: 0 16px; }
.lab { display: grid; justify-items: center; gap: 4px; text-align: center; }
.e { font-size: 26px; line-height: 1; }
.lab b { font-size: 15px; word-break: break-word; }
</style>