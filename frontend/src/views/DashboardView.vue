<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { etapas } from '../data/activity'
import { themeFor } from '../data/playful'
import { useAppStore } from '../stores/app'

const store = useAppStore()
const router = useRouter()

// Datos del docente y fecha
const hoy = new Date().toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
const fecha = hoy.charAt(0).toUpperCase() + hoy.slice(1)

// Datos calculados del mockup original
const quick = computed(() => store.ultimaEtapa ? etapas.find(e => e.id === store.ultimaEtapa) : etapas[0])

// Secciones del Capítulo 11 (Sprint 2)
const secciones = computed(() => ['Todas', ...new Set(store.actividades.map(a => a.seccion))])
const seccionActiva = computed({
  get: () => store.seccionSeleccionada || 'Todas',
  set: value => { store.seccionSeleccionada = value === 'Todas' ? null : value }
})

// Al montar la vista, consultar las actividades a FastAPI
onMounted(async () => {
  await store.fetchActividades()
})

// Filtrar las actividades según el botón de sección seleccionado
const actividadesMostradas = computed(() => store.actividadesFiltradas)

function cambiarSeccion(sec) {
  seccionActiva.value = sec
}

// Iniciar una actividad de la base de datos y proyectarla
function proyectarActividad(actividad) {

  // Determinar la etapa de proyección según la etapa metodológica o sección
  let etapaDestino = 'encuesta'
  if (actividad.tipo_etapa === 'Conocimiento de gráficos' || actividad.seccion === 'Pictogramas') {
    etapaDestino = 'graficos'
  } else if (actividad.tipo_etapa === 'Interpretación de gráficos' || actividad.seccion === 'Interpretar gráficos') {
    etapaDestino = 'interpretar'
  } else if (actividad.tipo_etapa === 'Creación de gráficos' || actividad.seccion === 'Cierre') {
    etapaDestino = 'crear'
  }

  store.setActividad(actividad, etapaDestino)
  router.push({ name: 'proyeccion', params: { etapa: etapaDestino }, query: { actividad: actividad.id_contenido } })
}

// Lanzar etapas generales
function launch(id) {
  if (store.actividadActual && store.session) {
    router.push({ name: 'proyeccion', params: { etapa: id }, query: { actividad: store.actividadActual.id_contenido } })
    return
  }
  store.launch(id)
  router.push({ name: 'proyeccion', params: { etapa: id } })
}
</script>

<template>
  <section class="dash">
    <!-- Cabecera principal -->
    <header class="hello">
      <div class="hello-copy">
        <span class="hero-eyebrow">✦ APRENDER ES UNA AVENTURA</span>
        <h1>Bienvenido profesora Carola</h1>
        <p class="hero-description">Un mundo de datos, dibujos y descubrimientos<br class="desktop-break" /> para explorar juntos en clase.</p>
        <p class="date">{{ fecha }} · Matemática, 3° básico</p>
      </div>
      <div class="hero-art" aria-hidden="true"><span class="orbit-star">✦</span><span class="orbit-dot"></span><div class="planet"><span>✦</span><div class="planet-bars"><i></i><i></i><i></i><i></i></div><b>¡Vamos a descubrir!</b></div><span class="small-star">✧</span></div>
      <button class="btn-pri" @click="launch(quick.id)">
        {{ store.ultimaEtapa ? 'Retomar la actividad' : 'Iniciar la actividad' }}
      </button>
    </header>

    <!-- ================================================================= -->
    <!-- Banco de misiones del capítulo 11 -->
    <!-- ================================================================= -->
    <div class="repo-header">
      <div>
        <span class="chapter-label">NUESTRA AVENTURA · CAPÍTULO 11</span>
        <h2>¿Qué vamos a descubrir hoy? <span aria-hidden="true">🧭</span></h2>
        <p>Pictogramas y gráficos de barra · {{ store.actividades.length }} misiones para aprender jugando.</p>
      </div>
    </div>

    <!-- Barra de pestañas / filtros de sección -->
    <div class="secciones-bar">
      <button
        v-for="sec in secciones"
        :key="sec"
        class="tab-sec"
        :class="{ active: seccionActiva === sec }"
        :aria-pressed="seccionActiva === sec"
        @click="cambiarSeccion(sec)"
      >
        {{ sec }} ({{ sec === 'Todas' ? store.actividades.length : store.actividades.filter(a => a.seccion === sec).length }})
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
    <div v-else-if="!actividadesMostradas.length" class="status-msg" role="status">No hay actividades en esta sección.</div>
    <div v-else class="actividades-grid">
      <div
        v-for="(act, index) in actividadesMostradas"
        :key="act.id_contenido"
        class="act-card"
        :style="{ '--mission-color': themeFor(act.seccion).color, '--mission-tint': themeFor(act.seccion).tint }"
      >
        <div class="mission-art" aria-hidden="true"><span>{{ themeFor(act.seccion).icon }}</span><b>✦</b><i>{{ String(index + 1).padStart(2, '0') }}</i></div>
        <div class="act-top">
          <span class="badge-sec">{{ act.seccion }}</span>
          <span class="badge-pag" v-if="act.pagina">Pág. {{ act.pagina }}</span>
        </div>

        <p class="mission-invitation">{{ themeFor(act.seccion).invitation }}</p>
        <h4>{{ act.titulo }}</h4>
        <p class="act-desc">{{ act.descripcion }}</p>

        <div class="act-meta">
          <span class="tipo-tag">{{ act.tipo_etapa }}</span>
          <span class="oa-tags" v-if="act.oa_asociados?.length">
            {{ act.oa_asociados.join(' · ') }}
          </span>
        </div>

        <button class="btn-sec-launch" @click="proyectarActividad(act)">
          ¡Vamos a jugar! <span aria-hidden="true">→</span>
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

/* Aula de aventuras: tarjetas grandes y un color reconocible por sección. */
.dash { gap: 26px; }
.hello { position: relative; overflow: hidden; min-height: 300px; padding: 34px 38px; border: 2px solid #e4dcf6; border-radius: 30px; background: radial-gradient(circle at 80% 10%, #faf2ce 0, transparent 38%), linear-gradient(115deg, #eee8fd, #f8f3ff 60%, #e8f4f5); box-shadow: 0 7px 0 #e9e0f5; }
.hello-copy { position: relative; z-index: 1; max-width: 62%; }
.hero-eyebrow { display: inline-block; font-size: 11px; font-weight: 900; color: #6e519d; letter-spacing: 1.5px; margin-bottom: 16px; }
.hello h1 { color: #302354; font-size: clamp(28px, 3.2vw, 42px); line-height: 1.15; max-width: 550px; margin-bottom: 14px; }
.hero-description { color: #675777; font-size: 18px; line-height: 1.55; margin-bottom: 16px; }
.date { font-size: 12px; color: #756b85; }
.hello > .btn-pri { position: absolute; right: 36px; bottom: 25px; z-index: 2; border-radius: 15px; background: #6540c9; box-shadow: 0 4px 0 #452398; }
.hero-art { position: absolute; right: 42px; top: 24px; width: 240px; height: 200px; }
.planet { display: grid; justify-items: center; align-content: center; gap: 10px; width: 180px; height: 180px; border-radius: 50%; background: #f9ce69; border: 10px solid #ffe8a9; transform: rotate(-9deg); box-shadow: 12px 10px 0 #e9d4f1; }
.planet > span { position: absolute; top: 10px; right: 25px; color: #9b6820; }
.planet b { color: #684d25; font-size: 12px; }
.planet-bars { display: flex; align-items: end; gap: 6px; height: 70px; border-bottom: 3px solid #946427; padding: 0 10px; }
.planet-bars i { width: 20px; height: 30px; background: #9569d6; border-radius: 6px 6px 0 0; }
.planet-bars i:nth-child(2) { height: 50px; background: #409fa0; }
.planet-bars i:nth-child(3) { height: 40px; background: #ed8a6b; }
.planet-bars i:nth-child(4) { height: 65px; background: #6588c6; }
.orbit-star { position: absolute; right: 5px; top: 15px; font-size: 45px; color: #9874cb; }
.small-star { position: absolute; bottom: 15px; right: 5px; font-size: 30px; color: #449c98; }
.orbit-dot { position: absolute; left: -18px; bottom: 30px; width: 14px; height: 14px; border-radius: 50%; background: #e7a393; }
.chapter-label { font-size: 11px; font-weight: 900; letter-spacing: 1.7px; color: #8b6c39; margin-bottom: 10px; }
.repo-header h2 { font-size: 29px; color: #342d4c; margin-bottom: 10px; }
.repo-header p { font-size: 15px; color: #7a7186; }
.secciones-bar { gap: 9px; }
.tab-sec { padding: 10px 16px; border-radius: 14px; font-size: 13px; border: 1px solid #dfdae9; box-shadow: 0 3px 0 #e8e3ef; }
.tab-sec.active { background: #6540c9; border-color: #6540c9; box-shadow: 0 3px 0 #472591; }
.actividades-grid { gap: 22px; }
.act-card { position: relative; overflow: hidden; padding: 16px; border: 2px solid #e7e1ec; border-radius: 24px; box-shadow: 0 5px 0 #eee8f1; gap: 12px; }
.act-card:hover { border-color: var(--mission-color); transform: translateY(-4px); box-shadow: 0 9px 0 var(--mission-tint); }
.mission-art { height: 105px; border-radius: 15px; background: var(--mission-tint); position: relative; display: grid; place-items: center; }
.mission-art > span { font-size: 49px; transform: rotate(-8deg); transition: transform .2s; }
.act-card:hover .mission-art > span { transform: rotate(5deg) scale(1.08); }
.mission-art b { position: absolute; right: 24%; top: 12px; color: var(--mission-color); font-size: 23px; opacity: .5; }
.mission-art i { position: absolute; right: 14px; bottom: 8px; color: var(--mission-color); opacity: .6; font: 800 25px var(--font-title); }
.badge-sec { background: var(--mission-tint); color: var(--mission-color); font-size: 10px; }
.badge-pag { font-size: 11px; }
.mission-invitation { font-size: 11px; color: var(--mission-color); font-weight: 900; }
.act-card h4 { font-size: 18px; color: #352c4b; }
.act-desc { font-size: 13px; color: #746b80; }
.tipo-tag { color: var(--mission-color); font-size: 9px; }
.oa-tags { font-size: 10px; color: #81758d; }
.btn-sec-launch { display: flex; justify-content: space-between; align-items: center; background: var(--mission-tint); color: var(--mission-color); border: 0; border-bottom: 3px solid var(--mission-color); font-size: 15px; border-radius: 13px; padding: 12px 15px; }
.btn-sec-launch:hover { background: var(--mission-color); color: white; }
@media(max-width: 900px) { .hero-art { right: 12px; transform: scale(.8); transform-origin: top right; } .hello > .btn-pri { right: 25px; } }
@media(max-width: 600px) { .hello { padding: 26px 22px 90px; min-height: auto; } .hello-copy { max-width: 100%; } .hero-art { display: none; } .hello > .btn-pri { left: 22px; right: auto; bottom: 24px; } .desktop-break { display: none; } .repo-header h2 { font-size: 25px; } }

</style>
