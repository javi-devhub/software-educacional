import { createRouter, createWebHashHistory } from 'vue-router'
import DashboardView from './views/DashboardView.vue'
import ProjectionView from './views/ProjectionView.vue'
import SettingsView from './views/SettingsView.vue'
import LoginView from './views/LoginView.vue'
import { useAppStore } from './stores/app'
import { etapaIndex } from './data/activity'

// Rutas internas: la navegación no recarga la página (HU-4).
// meta.public: accesible sin sesión · meta.fullscreen: sin barra ni menú de administración (HU-5)
const routes = [
  { path: '/login', name: 'login', component: LoginView, meta: { public: true, fullscreen: true } },
  { path: '/', name: 'inicio', component: DashboardView },
  { path: '/configuracion', name: 'configuracion', component: SettingsView },
  // Modo proyección: pantalla completa y sin controles de administración (HU-5). :etapa = id de la etapa
  { path: '/proyeccion/:etapa', name: 'proyeccion', component: ProjectionView, meta: { fullscreen: true } },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})

// Guarda de navegación: protege las rutas privadas y mantiene coherente la sesión de proyección.
router.beforeEach(async (to) => {
  const store = useAppStore()

  // Sin sesión: todo redirige al login recordando a dónde quería ir
  if (!to.meta.public && !store.isAuth) {
    return { name: 'login', query: to.fullPath !== '/' ? { redirect: to.fullPath } : {} }
  }
  // Con sesión, no tiene sentido volver al login
  if (to.name === 'login' && store.isAuth) return { name: 'inicio' }

  if (to.name === 'proyeccion') {
    // Etapa inexistente en la URL: vuelve al inicio
    if (etapaIndex(to.params.etapa) === -1) return { name: 'inicio' }
    // Entrada directa o recarga (F5): recrea la sesión de actividad para que las etapas no fallen
    if (to.query.actividad) {
      const id = Number(to.query.actividad)
      if (store.actividadActual?.id_contenido !== id) {
        if (!store.actividades.length) await store.fetchActividades()
        const actividad = store.actividades.find(a => a.id_contenido === id)
        if (!actividad) return { name: 'inicio' }
        store.setActividad(actividad, to.params.etapa)
      }
    } else if (!store.session || store.actividadActual) {
      store.launch(to.params.etapa)
    }
  }
})

export default router
