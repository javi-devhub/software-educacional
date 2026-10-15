<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAppStore } from '../stores/app'
import { etapas } from '../data/activity'

// Importamos los componentes de las etapas desde la carpeta src/stages/
import StageSurvey from '../stages/StageSurvey.vue'
import StageCharts from '../stages/StageCharts.vue'
import StageInterpret from '../stages/StageInterpret.vue'
import StageBuild from '../stages/StageBuild.vue'

const store = useAppStore()
const route = useRoute()
const router = useRouter()
const paused = computed(() => !!store.session?.paused)

// Mapeamos los ID de activity.js con los nombres de tus archivos Vue
const stageComponents = {
  'encuesta': StageSurvey,
  'graficos': StageCharts,
  'interpretar': StageInterpret,
  'crear': StageBuild
}

// Determinamos qué componente y qué colores cargar basados en la URL
const currentEtapaId = computed(() => route.params.etapa)
const currentComponent = computed(() => stageComponents[currentEtapaId.value] || StageSurvey)
const currentEtapaData = computed(() => etapas.find(e => e.id === currentEtapaId.value) || etapas[0])

function volverAlDashboard() {
  router.push('/')
}
</script>

<template>
  <div class="proyeccion-container" :style="{ '--theme': currentEtapaData.color, '--bg': currentEtapaData.tint }">
    <header class="proj-header">
      <button @click="volverAlDashboard" class="btn-back">⬅ Volver al Dashboard</button>
      <h2 class="stage-title">{{ currentEtapaData.emoji }} {{ currentEtapaData.title }}</h2>
      <div class="header-actions">
        <button class="btn-pause" type="button" @click="store.togglePause">
          {{ paused ? '▶ Continuar' : '⏸ Pausar' }}
        </button>
        <div class="curso-badge">{{ store.curso }}</div>
      </div>
    </header>

    <main class="proj-content">
      <!-- Carga dinámicamente StageSurvey, StageCharts, etc. -->
      <div class="stage-content" :inert="paused">
        <component :is="currentComponent" />
      </div>
      <div v-if="paused" class="pause-overlay" role="status" aria-live="polite">
        <div class="pause-message">
          <strong>Actividad en pausa</strong>
          <span>Pulsa “Continuar” para seguir.</span>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
.proyeccion-container { min-height: 100vh; background: var(--bg); display: flex; flex-direction: column; }
.proj-header { display: flex; justify-content: space-between; align-items: center; gap: 16px; padding: 16px 32px; background: white; border-bottom: 3px solid var(--theme); box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
.btn-back { background: transparent; border: none; font-weight: bold; cursor: pointer; color: #555; font-size: 15px; }
.btn-back:hover { color: var(--theme); }
.stage-title { font-size: 22px; margin: 0; color: #333; }
.header-actions { display: flex; align-items: center; gap: 12px; }
.btn-pause { background: var(--theme); color: #fff; border: 0; border-radius: 12px; padding: 8px 14px; font: 700 14px var(--font-body); cursor: pointer; white-space: nowrap; }
.btn-pause:hover { filter: brightness(.92); }
.curso-badge { font-weight: bold; color: var(--theme); background: var(--bg); padding: 6px 14px; border-radius: 12px; font-size: 14px; }
.proj-content { position: relative; flex: 1; padding: 32px; max-width: 1200px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; }
.stage-content { flex: 1; }
.pause-overlay { position: absolute; inset: 0; z-index: 1; display: grid; place-items: center; padding: 32px; background: rgba(255, 255, 255, .82); backdrop-filter: blur(3px); }
.pause-message { display: flex; flex-direction: column; align-items: center; gap: 8px; padding: 24px 32px; border-radius: 16px; background: #fff; box-shadow: 0 4px 20px rgba(0, 0, 0, .12); color: #333; text-align: center; }
.pause-message strong { font-size: 24px; }
@media (max-width: 700px) {
  .proj-header { flex-wrap: wrap; padding: 12px 16px; }
  .stage-title { order: 3; width: 100%; font-size: 18px; }
  .proj-content { padding: 20px 16px; }
}
</style>