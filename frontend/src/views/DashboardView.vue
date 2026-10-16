<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { etapas } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const router = useRouter()

const nombre = computed(() => store.docente.nombre.split(' ')[0])
const hoy = new Date().toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
const fecha = hoy.charAt(0).toUpperCase() + hoy.slice(1) 

// Datos calculados para el diseño del mockup
const totalMinutes = computed(() => etapas.reduce((sum, e) => sum + e.minutes, 0))
const stageEmojis = computed(() => etapas.map(e => e.emoji).join(' ➔ '))

function launch(id) {
  store.launch(id)
  router.push({ name: 'proyeccion', params: { etapa: id } })
}

const quick = computed(() => store.ultimaEtapa ? etapas.find(e => e.id === store.ultimaEtapa) : etapas[0])
</script>

<template>
  <section class="dash">
    <header class="hello">
      <div>
        <span class="sym" aria-hidden="true">{{ stageEmojis }}</span>
        <h1>¡Hola, profesora {{ nombre }}!</h1>
        <p class="date">{{ fecha }} · ¿Qué proyectamos hoy en clase?</p>
      </div>
      <button class="btn-pri" @click="launch(quick.id)">
        {{ store.ultimaEtapa ? 'Retomar la actividad' : 'Iniciar la actividad' }}
      </button>
    </header>

    <div class="activity-header">
      <h2>La encuesta del curso</h2>
      <p>Datos y probabilidades - {{ etapas.length }} etapas - unos {{ totalMinutes }} minutos en total</p>
    </div>

    <div class="grid">
      <!-- Tarjetas fieles al mockup -->
      <div v-for="(e, index) in etapas" :key="e.id" class="etapa-card" :style="{ '--theme': e.color, '--bg': e.tint }">
        <div class="card-header">
          <div class="emoji-box">{{ e.emoji }}</div>
          <div class="step-circle">{{ index + 1 }}</div>
        </div>
        
        <div class="info">
          <h3>{{ e.title }}</h3>
          <p>{{ e.desc }}</p>
          <span class="time" :style="{ color: e.color }">{{ e.minutes }} min</span>
          <span class="oa">{{ e.oa.join(' · ') }}</span>
          <span v-if="!e.oaValidado" class="oa-warning">Pendiente de validación docente</span>
        </div>
        
        <button class="btn-pri w-100" @click="launch(e.id)">Proyectar etapa {{ index + 1 }}</button>
      </div>
    </div>

    <p class="note">Alineación curricular propuesta para Matemática 3° básico; pendiente de validación con la docente. La plataforma no registra resultados de cada estudiante.</p>
  </section>
</template>

<style scoped>
.dash { display: flex; flex-direction: column; gap: 20px; padding-bottom: 40px; }

/* Cabecera principal */
.hello { display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap; padding: 24px 32px; border-radius: 16px; background: linear-gradient(110deg, #FDF7F5 0%, #FEE8EE 40%, #EFE9FE 70%, #E6F3FF 100%); }
.sym { font-size: 18px; color: #555; margin-bottom: 8px; display: block; letter-spacing: 2px; }
h1 { font-size: 28px; margin: 0 0 6px 0; color: #222; }
.date { margin: 0; color: #555; font-size: 15px; }

/* Botones genéricos (morado principal) */
.btn-pri { background: #5636FF; color: white; padding: 12px 24px; border-radius: 12px; border: none; font-weight: bold; cursor: pointer; font-size: 15px; transition: opacity 0.2s; }
.btn-pri:hover { opacity: 0.9; }
.w-100 { width: 100%; margin-top: auto; }

/* Título de la actividad */
.activity-header { display: flex; flex-direction: column; gap: 4px; margin-top: 8px; }
.activity-header h2 { font-size: 22px; margin: 0; color: #333; }
.activity-header p { font-size: 15px; margin: 0; color: #777; }

/* Grilla de tarjetas */
.grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.etapa-card { background: #fff; border: 2px solid var(--theme); border-radius: 16px; padding: 20px; display: flex; flex-direction: column; box-shadow: 0 2px 12px rgba(0,0,0,0.02); }

/* Elementos superiores de la tarjeta */
.card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
.emoji-box { font-size: 24px; background: var(--bg); width: 44px; height: 44px; display: flex; justify-content: center; align-items: center; border-radius: 10px; }
.step-circle { width: 26px; height: 26px; border-radius: 50%; border: 2px solid var(--theme); color: var(--theme); display: flex; justify-content: center; align-items: center; font-weight: bold; font-size: 14px; }

/* Textos de la tarjeta */
.info { display: flex; flex-direction: column; flex: 1; }
.info h3 { font-size: 17px; margin: 0 0 8px 0; color: #222; line-height: 1.3; }
.info p { font-size: 14px; margin: 0 0 16px 0; color: #666; line-height: 1.4; flex: 1; }
.time { font-size: 14px; font-weight: bold; margin-bottom: 4px; }
.oa { font-size: 13px; font-weight: 700; color: #3F3482; margin-bottom: 4px; }
.oa-warning { font-size: 12px; color: #895A11; margin-bottom: 20px; }

/* Nota a pie de página */
.note { font-size: 13px; color: #777; text-align: left; margin-top: 16px; }
</style>