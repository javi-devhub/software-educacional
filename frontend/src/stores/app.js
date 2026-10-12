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
    ultimaEtapa: load('ultimaEtapa', null), // solo la última etapa proyectada; no hay registro de desempeño
    session: null // estado global de la actividad proyectada (HU-6)
  }),
  getters: {
    isAuth: (state) => !!state.docente,
    doneCount: (state) => (state.session ? Object.keys(state.session.done).length : 0)
  },
  actions: {
    // Autenticación (HU-1): llama al endpoint POST /login del backend
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
      this.session = null
      remove('docente')
    },
    setReadSize(px) {
      this.readSize = px
      save('readSize', px)
    },
    launch(id = 'encuesta') {
      const i = Math.max(0, etapaIndex(id))
      this.ultimaEtapa = etapas[i].id
      save('ultimaEtapa', this.ultimaEtapa)
      this.session = {
        i, paused: false, finished: false, done: {},
        votes: zeros(encuesta.opciones), sortDesc: false, // etapa 1
        seen: {}, // etapa 2
        quiz: {}, qi: 0, // etapa 3
        chart: zeros(datosDeportes.items), checked: null // etapa 4
      }
    },
    goTo(i) {
      this.session.i = Math.min(Math.max(i, 0), etapas.length - 1)
      this.ultimaEtapa = etapas[this.session.i].id
      save('ultimaEtapa', this.ultimaEtapa)
    },
    // Etapa 1
    vote(key) {
      this.session.votes[key]++
      this.session.done[0] = true
    },
    loadSample() {
      this.session.votes = { ...encuesta.ejemplo }
      this.session.done[0] = true
    },
    resetVotes() {
      this.session.votes = zeros(encuesta.opciones)
      delete this.session.done[0]
    },
    toggleSort() {
      this.session.sortDesc = !this.session.sortDesc
    },
    // Etapa 2
    seeChart(tipo) {
      const s = this.session
      s.seen[tipo] = true
      if (s.seen.pictograma && s.seen.barras) s.done[1] = true
    },
    // Etapa 3
    answerQuiz(q, option) {
      const s = this.session
      if (s.quiz[q]?.ok) return
      s.quiz[q] = { sel: option, ok: !!preguntas[q].options[option][2] }
      if (preguntas.every((_, k) => s.quiz[k]?.ok)) s.done[2] = true
    },
    setQuestion(q) {
      this.session.qi = q
    },
    // Etapa 4
    setBar(key, delta) {
      const s = this.session
      s.chart[key] = Math.min(datosDeportes.max, Math.max(0, s.chart[key] + delta))
      s.checked = null
    },
    checkChart() {
      const s = this.session
      const wrong = datosDeportes.items.filter((d) => s.chart[d.key] !== d.value).map((d) => d.key)
      s.checked = { ok: wrong.length === 0, wrong }
      if (s.checked.ok) s.done[3] = true
    },
    togglePause() {
      this.session.paused = !this.session.paused
    },
    restart() {
      this.launch('encuesta')
    }
  }
})
