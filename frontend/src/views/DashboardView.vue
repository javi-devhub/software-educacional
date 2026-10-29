<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { etapas } from '../data/activity'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const router = useRouter()

// Datos del docente y fecha
const nombre = computed(() => store.docente?.nombre ? store.docente.nombre.split(' ')[0] : 'Docente')
const hoy = new Date().toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
const fecha = hoy.charAt(0).toUpperCase() + hoy.slice(1)

// Datos calculados del mockup original
const totalMinutes = computed(() => etapas.reduce((sum, e) => sum + e.minutes, 0))
const stageEmojis = computed(() => etapas.map(e => e.emoji).join(' ➔ '))
const quick = computed(() => store.ultimaEtapa ? etapas.find(e => e.id === store.ultimaEtapa) : etapas[0])

// Secciones del Capítulo 11 (Sprint 2)
const secciones = [
  'Todas',
  'Tablas',
  'Pictogramas',
  'Gráficos de barra',
  'Interpretar gráficos',
  'Cierre'
]
const seccionActiva = ref('Todas')

// Al montar la vista, consultar las actividades a FastAPI
onMounted(async () => {
  await store.fetchActividades()
})

// Filtrar las actividades según el botón de sección seleccionado
const actividadesMostradas = computed(() => {
  if (seccionActiva.value === 'Todas') {
    return store.actividades
  }
  return store.actividades.filter(a => a.seccion === seccionActiva.value)
})

function cambiarSeccion(sec) {
  seccionActiva.value = sec
}

// Iniciar una actividad de la base de datos y proyectarla
function proyectarActividad(actividad) {
  store.setActividad(actividad)

  // Determinar la etapa de proyección según la etapa metodológica o sección
  let etapaDestino = 'encuesta'
  if (actividad.tipo_etapa === 'Conocimiento de gráficos' || actividad.seccion === 'Pictogramas') {
    etapaDestino = 'graficos'
  } else if (actividad.tipo_etapa === 'Interpretación de gráficos' || actividad.seccion === 'Interpretar gráficos') {
    etapaDestino = 'interpretar'
  } else if (actividad.tipo_etapa === 'Creación de gráficos' || actividad.seccion === 'Cierre') {
    etapaDestino = 'crear'
  }

  store.launch(etapaDestino)
  router.push({ name: 'proyeccion', params: { etapa: etapaDestino } })
}

// Lanzar etapas generales
function launch(id) {
  store.launch(id)
  router.push({ name: 'proyeccion', params: { etapa: id } })
}
</script>

<template>
  <section class="dash">
    <!-- Cabecera principal -->
    <header class="hello">
      <div>
        <span class="sym" aria-hidden="true">{{ stageEmojis }}</span>
        <h1>¡Hola, profesora Carola!</h1>
        <p class="date">{{ fecha }} · ¿Qué proyectamos hoy en clase?</p>
      </div>
      <button class="btn-pri" @click="launch(quick.id)">
        {{ store.ultimaEtapa ? 'Retomar la actividad' : 'Iniciar la actividad' }}
      </button>
    </header>

    <!-- ================================================================= -->
    <!-- SPRINT 2: BANCO DE ACTIVIDADES CAPÍTULO 11 (6 POR SECCIÓN)         -->
    <!-- ================================================================= -->
    <div class="repo-header">
      <div>
        <h2>Capítulo 11: Pictogramas y gráficos de barra</h2>
        <p>Selecciona una sección para proyectar actividades específicas del texto escolar (30 actividades disponibles).</p>
      </div>
    </div>

    <!-- Barra de pestañas / filtros de sección -->
    <div class="secciones-bar">
      <button 
        v-for="sec in secciones" 
        :key="sec"
        class="tab-sec"
        :class="{ active: seccionActiva === sec }"
        @click="cambiarSeccion(sec)"
      >
        {{ sec }}
      </button>
    </div>

    <!-- Estado de carga o error -->
    <div v-if="store.cargandoActividades" class="status-msg">
      Cargando actividades desde la base de datos...
    </div>
    <div v-else-if="store.errorActividades" class="status-msg error">
      {{ store.errorActividades }} (Verifica que el backend esté corriendo en el puerto 8000).
    </div>

    <!-- Grilla de actividades del Capítulo 11 -->
    <div v-else class="actividades-grid">
      <div 
        v-for="act in actividadesMostradas" 
        :key="act.id_contenido" 
        class="act-card"
      >
        <div class="act-top">
          <span class="badge-sec">{{ act.seccion }}</span>
          <span class="badge-pag" v-if="act.pagina">Pág. {{ act.pagina }}</span>
        </div>
        
        <h4>{{ act.titulo }}</h4>
        <p class="act-desc">{{ act.descripcion }}</p>

        <div class="act-meta">
          <span class="tipo-tag">{{ act.tipo_etapa }}</span>
          <span class="oa-tags" v-if="act.oa_asociados?.length">
            {{ act.oa_asociados.join(' · ') }}
          </span>
        </div>

        <button class="btn-sec-launch" @click="proyectarActividad(act)">
          Proyectar recurso ➔
        </button>
      </div>
    </div>

    <p class="note">Alineación curricular propuesta para Matemática 3° básico; vinculada con OA 23, OA 24, OA 25 y OA 26 del MINEDUC. La plataforma no registra resultados individuales de los estudiantes.</p>
  </section>
</template>

<style scoped>
.dash { display: flex; flex-direction: column; gap: 20px; padding-bottom: 40px; }

/* Cabecera principal */
.hello { display: flex; justify-content: space-between; align-items: center; gap: 16px; flex-wrap: wrap; padding: 24px 32px; border-radius: 16px; background: linear-gradient(110deg, #FDF7F5 0%, #FEE8EE 40%, #EFE9FE 70%, #E6F3FF 100%); }
.sym { font-size: 18px; color: #555; margin-bottom: 8px; display: block; letter-spacing: 2px; }
h1 { font-size: 28px; margin: 0 0 6px 0; color: #222; }
.date { margin: 0; color: #555; font-size: 15px; }

/* Botones principales */
.btn-pri { background: #5636FF; color: white; padding: 12px 24px; border-radius: 12px; border: none; font-weight: bold; cursor: pointer; font-size: 15px; transition: opacity 0.2s; }
.btn-pri:hover { opacity: 0.9; }
.w-100 { width: 100%; margin-top: auto; }

/* Título de la actividad */
.activity-header, .repo-header { display: flex; flex-direction: column; gap: 4px; margin-top: 8px; }
.activity-header h2, .repo-header h2 { font-size: 22px; margin: 0; color: #333; }
.activity-header p, .repo-header p { font-size: 15px; margin: 0; color: #777; }

/* Grilla de 4 etapas */
.grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.etapa-card { background: #fff; border: 2px solid var(--theme); border-radius: 16px; padding: 20px; display: flex; flex-direction: column; box-shadow: 0 2px 12px rgba(0,0,0,0.02); }

.card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
.emoji-box { font-size: 24px; background: var(--bg); width: 44px; height: 44px; display: flex; justify-content: center; align-items: center; border-radius: 10px; }
.step-circle { width: 26px; height: 26px; border-radius: 50%; border: 2px solid var(--theme); color: var(--theme); display: flex; justify-content: center; align-items: center; font-weight: bold; font-size: 14px; }

.info { display: flex; flex-direction: column; flex: 1; }
.info h3 { font-size: 17px; margin: 0 0 8px 0; color: #222; line-height: 1.3; }
.info p { font-size: 14px; margin: 0 0 16px 0; color: #666; line-height: 1.4; flex: 1; }
.time { font-size: 14px; font-weight: bold; margin-bottom: 4px; }
.oa { font-size: 13px; font-weight: 700; color: #3F3482; margin-bottom: 4px; }
.oa-warning { font-size: 12px; color: #895A11; margin-bottom: 20px; }

/* ========================================= */
/* ESTILOS SPRINT 2: BANCO DE ACTIVIDADES    */
/* ========================================= */
.secciones-bar { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 4px; }
.tab-sec { background: #fff; border: 2px solid #E2E8F0; border-radius: 99px; padding: 8px 18px; font-weight: 700; font-size: 14px; color: #475569; cursor: pointer; transition: all 0.2s; }
.tab-sec:hover { border-color: #5636FF; color: #5636FF; }
.tab-sec.active { background: #5636FF; border-color: #5636FF; color: #fff; }

.status-msg { padding: 24px; background: #fff; border-radius: 16px; text-align: center; font-size: 15px; color: #64748B; }
.status-msg.error { color: #DC2626; background: #FEF2F2; border: 1px solid #FCA5A5; }

.actividades-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 6px; }
.act-card { background: #fff; border: 1px solid #E2E8F0; border-radius: 16px; padding: 18px; display: flex; flex-direction: column; gap: 10px; transition: transform 0.2s, box-shadow 0.2s; }
.act-card:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,0,0,0.06); border-color: #CBD5E1; }

.act-top { display: flex; justify-content: space-between; align-items: center; }
.badge-sec { background: #EDE9FE; color: #5B21B6; font-size: 12px; font-weight: 800; padding: 4px 10px; border-radius: 8px; }
.badge-pag { font-size: 12px; color: #64748B; font-weight: 700; }

.act-card h4 { font-size: 16px; margin: 0; color: #1E293B; line-height: 1.3; }
.act-desc { font-size: 13px; color: #64748B; line-height: 1.4; margin: 0; flex: 1; }

.act-meta { display: flex; flex-direction: column; gap: 4px; margin-top: 4px; }
.tipo-tag { font-size: 11px; font-weight: 800; color: #0284C7; text-transform: uppercase; letter-spacing: 0.5px; }
.oa-tags { font-size: 12px; font-weight: 700; color: #3F3482; }

.btn-sec-launch { background: #F8FAFC; border: 1px solid #CBD5E1; color: #334155; padding: 10px 14px; border-radius: 10px; font-weight: 700; font-size: 13px; cursor: pointer; transition: all 0.2s; margin-top: 8px; }
.btn-sec-launch:hover { background: #5636FF; border-color: #5636FF; color: white; }

.note { font-size: 13px; color: #777; text-align: left; margin-top: 16px; }

@media (max-width: 1024px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
  .actividades-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 700px) {
  .grid { grid-template-columns: 1fr; }
  .actividades-grid { grid-template-columns: 1fr; }
}
</style>