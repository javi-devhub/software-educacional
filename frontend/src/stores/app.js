import { defineStore } from 'pinia'
import { etapas, etapaIndex, encuesta, preguntas, datosDeportes } from '../data/activity'
import { API_URL } from '../config'

const PREFIX = 'lyc:'
const load = (key, fallback) => {
  try {
    const raw = localStorage.getItem(PREFIX + key)
    return raw ? JSON.parse(raw) : fallback
  } catch {
    return fallback
  }
}
const save = (key, value) => {
  try {
    localStorage.setItem(PREFIX + key, JSON.stringify(value))
  } catch {
    /* sin almacenamiento: la app sigue funcionando */
  }
}
const remove = (key) => {
  try {
    localStorage.removeItem(PREFIX + key)
  } catch {
    /* nada que borrar */
  }
}
const zeros = (items) => Object.fromEntries(items.map((o) => [o.key, 0]))

export const useAppStore = defineStore('app', {
  state: () => ({
    docente: load('docente', null), // { id_docente, nombre, nickname, rol } tras iniciar sesión (HU-1)
    curso: '3° básico',
    readSize: load('readSize', 22),
    ultimaEtapa: load('ultimaEtapa', null), // última etapa proyectada
    session: load('session', null), // estado global de la actividad proyectada (HU-6)

    // === ESTADO SPRINT 2: ACTIVIDADES CAPÍTULO 11 ===
    actividades: [], // lista descargada desde GET /actividades
    actividadActual: load('actividadActual', null), // actividad seleccionada activa
    chapterProgress: load('chapterProgress', {}),
    seccionSeleccionada: null, // filtro: 'Tablas', 'Pictogramas', 'Gráficos de barra', etc.
    cargandoActividades: false,
    errorActividades: null
  }),

  getters: {
    isAuth: (state) => !!state.docente,
    doneCount: (state) => (state.session ? Object.keys(state.session.done).length : 0),
    
    // Lista de actividades filtradas por sección actual en el store
    actividadesFiltradas: (state) => {
      if (!state.seccionSeleccionada) return state.actividades
      return state.actividades.filter((a) => a.seccion === state.seccionSeleccionada)
    }
  },

  actions: {
    persistProgress() {
      if (this.session) {
        save('session', this.session)
        save('actividadActual', this.actividadActual)
      } else {
        remove('session')
        remove('actividadActual')
      }
    },

    getChapterProgress(activityId) {
      return this.chapterProgress[activityId] || {}
    },

    saveChapterProgress(activityId, progress) {
      this.chapterProgress[activityId] = {
        ...this.chapterProgress[activityId],
        ...progress
      }
      save('chapterProgress', this.chapterProgress)
    },

    // Autenticación (HU-1)
    async login(nickname, contrasena) {
      let res
      try {
        res = await fetch(`${API_URL}/login`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ nickname, contrasena })
        })
      } catch {
        throw new Error('No se pudo conectar con el servidor. Revisa que el backend esté encendido.')
      }
      const data = await res.json().catch(() => ({}))
      if (!res.ok) {
        throw new Error(typeof data.detail === 'string' ? data.detail : 'No se pudo iniciar sesión.')
      }
      this.docente = data.docente
      save('docente', data.docente)
    },

    logout() {
      this.docente = null
      remove('docente')
    },

    setReadSize(px) {
      this.readSize = px
      save('readSize', px)
    },

    // =====================================================================
    // ACCIONES SPRINT 2: CONSUMO DE API Y CARGA DINÁMICA
    // =====================================================================
    async fetchActividades(seccion = this.seccionSeleccionada) {
      this.cargandoActividades = true
      this.errorActividades = null
      this.seccionSeleccionada = seccion

      // Conservar el catálogo completo permite cambiar de filtro sin perder secciones.
      const url = `${API_URL}/actividades`

      try {
        const res = await fetch(url)
        if (!res.ok) throw new Error('Error al consultar las actividades.')
        this.actividades = await res.json()
      } catch (err) {
        this.actividades = []
        this.errorActividades = err.message || 'Error de conexión con el backend'
      } finally {
        this.cargandoActividades = false
      }
    },

    // Selecciona una actividad de la BD y la monta dinámicamente en session
    setActividad(actividad, etapa = 'encuesta') {
      const mismaActividad = this.session?.actividadId === actividad.id_contenido
      if (mismaActividad) {
        this.goTo(etapaIndex(etapa))
      } else {
        this.launch(etapa)
      }
      this.actividadActual = actividad

      // Mapear según el tipo de contenido/mecánica
      const datos = actividad.datos || {}
      const filas = datos.filas || []

      // Si no hay sesión activa, inicializarla
      if (!this.session) {
        this.launch(etapa)
      }

      // Inyectar datos en una sesión nueva sin sobrescribir el progreso restaurado.
      if (!mismaActividad) {
        const votosDinamicos = {}
        filas.forEach((f) => {
          const key = f.categoria.toLowerCase().replace(/\s+/g, '_')
          votosDinamicos[key] = f.total || f.cantidad || 0
        })
        this.session.votes = { ...votosDinamicos }
      }
      this.session.actividadId = actividad.id_contenido
      this.session.tituloActividad = actividad.titulo
      this.session.datosActividad = datos
      this.persistProgress()
    },

    // Lanzar proyección (HU-4 / HU-6)
    launch(id = 'encuesta') {
      this.actividadActual = null
      const i = Math.max(0, etapaIndex(id))
      this.ultimaEtapa = etapas[i].id
      save('ultimaEtapa', this.ultimaEtapa)
      this.session = {
        i,
        paused: false,
        finished: false,
        done: {},
        votes: zeros(encuesta.opciones),
        sortDesc: false, // etapa 1
        seen: {}, // etapa 2
        quiz: {},
        qi: 0, // etapa 3
        chart: zeros(datosDeportes.items),
        checked: null // etapa 4
      }
      this.persistProgress()
    },

    goTo(i) {
      this.session.i = Math.min(Math.max(i, 0), etapas.length - 1)
      this.ultimaEtapa = etapas[this.session.i].id
      save('ultimaEtapa', this.ultimaEtapa)
      this.persistProgress()
    },

    // Etapa 1: Encuesta y tabla
    vote(key) {
      this.session.votes[key] = (this.session.votes[key] || 0) + 1
      this.session.done[0] = true
      this.persistProgress()
    },

    loadSample() {
      // Si hay una actividad de BD cargada con filas, usar sus datos como muestra
      if (this.actividadActual?.datos?.filas) {
        const muestra = {}
        this.actividadActual.datos.filas.forEach((f) => {
          const key = f.categoria.toLowerCase().replace(/\s+/g, '_')
          muestra[key] = f.total || f.cantidad || 0
        })
        this.session.votes = muestra
      } else {
        this.session.votes = { ...encuesta.ejemplo }
      }
      this.session.done[0] = true
      this.persistProgress()
    },

    resetVotes() {
      if (this.actividadActual?.datos?.filas) {
        const vacio = {}
        this.actividadActual.datos.filas.forEach((f) => {
          const key = f.categoria.toLowerCase().replace(/\s+/g, '_')
          vacio[key] = 0
        })
        this.session.votes = vacio
      } else {
        this.session.votes = zeros(encuesta.opciones)
      }
      delete this.session.done[0]
      this.persistProgress()
    },

    toggleSort() {
      this.session.sortDesc = !this.session.sortDesc
      this.persistProgress()
    },

    // Etapa 2: Conocimiento de gráficos
    seeChart(tipo) {
      const s = this.session
      s.seen[tipo] = true
      if (s.seen.pictograma && s.seen.barras) s.done[1] = true
      this.persistProgress()
    },

    // Etapa 3: Interpretación
    answerQuiz(q, option) {
      const s = this.session
      if (s.quiz[q]?.ok) return

      // Si la actividad actual tiene preguntas en su JSON, evaluar con ellas
      const preguntasActuales = this.actividadActual?.datos?.preguntas || preguntas
      const preg = preguntasActuales[q]
      const esCorrecta = Array.isArray(preg.options)
        ? !!preg.options[option][2]
        : preg.r === option || preg.respuesta === option

      s.quiz[q] = { sel: option, ok: esCorrecta }
      if (preguntasActuales.every((_, k) => s.quiz[k]?.ok)) s.done[2] = true
      this.persistProgress()
    },

    setQuestion(q) {
      this.session.qi = q
      this.persistProgress()
    },

    answerQuizText(q, selText, isCorrect) {
      const s = this.session
      if (!s) return
      s.quiz[q] = { selText, ok: isCorrect }
      const preguntasActuales = this.actividadActual?.datos?.preguntas || preguntas
      if (preguntasActuales.every((_, k) => s.quiz[k]?.ok)) s.done[2] = true
      this.persistProgress()
    },

    // Etapa 4: Creación de gráficos
    setBar(key, delta) {
      const s = this.session
      const maxVal = this.actividadActual?.datos?.escala_eje ? this.actividadActual.datos.escala_eje * 10 : datosDeportes.max
      s.chart[key] = Math.min(maxVal, Math.max(0, (s.chart[key] || 0) + delta))
      s.checked = null
      this.persistProgress()
    },

    checkChart() {
      const s = this.session
      const itemsObjetivo = this.actividadActual?.datos?.filas
        ? this.actividadActual.datos.filas.map((f) => ({
            key: f.categoria.toLowerCase().replace(/\s+/g, '_'),
            value: f.total || f.cantidad || 0
          }))
        : datosDeportes.items

      const wrong = itemsObjetivo
        .filter((d) => (s.chart[d.key] || 0) !== d.value)
        .map((d) => d.key)

      s.checked = { ok: wrong.length === 0, wrong }
      if (s.checked.ok) s.done[3] = true
      this.persistProgress()
    },

    togglePause() {
      this.session.paused = !this.session.paused
      this.persistProgress()
    },

    restart() {
      if (this.actividadActual) {
        this.setActividad(this.actividadActual, etapas[this.session.i].id)
        return
      }
      this.launch('encuesta')
    }
  }
})
