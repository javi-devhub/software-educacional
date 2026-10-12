import { createRouter, createWebHashHistory } from 'vue-router'
import DashboardView from './views/DashboardView.vue'
import ProjectionView from './views/ProjectionView.vue'
import SettingsView from './views/SettingsView.vue'

// Rutas internas: la navegación no recarga la página (HU-4).
const routes = [
  { path: '/', name: 'inicio', component: DashboardView },
  { path: '/configuracion', name: 'configuracion', component: SettingsView },
  // Modo proyección: pantalla completa y sin controles de administración (HU-5). :etapa = id de la etapa
  { path: '/proyeccion/:etapa', name: 'proyeccion', component: ProjectionView, meta: { fullscreen: true } },
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

export default createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 })
})