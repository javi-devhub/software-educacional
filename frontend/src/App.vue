<script setup>
import { computed, watchEffect } from 'vue'
import { useRoute } from 'vue-router'
import SideNav from './components/SideNav.vue'
import { useAppStore } from './stores/app'
import { APP_NAME, ASIGNATURA } from './config'

const route = useRoute()
const store = useAppStore()
const fullscreen = computed(() => !!route.meta.fullscreen)

// Tamaño del texto configurable por la docente
watchEffect(() => document.documentElement.style.setProperty('--read', store.readSize + 'px'))
</script>

<template>
  <!-- Modo proyección: sin barra ni menú de administración -->
  <RouterView v-if="fullscreen" />

  <div v-else class="app">
    <header class="top">
      <div class="logo">
        🔢 {{ APP_NAME }}
        <small>{{ ASIGNATURA }} · {{ store.curso }}</small>
      </div>
      <div class="who">
        {{ store.docente.nombre }}
        <small>{{ store.docente.rol }}</small>
      </div>
    </header>
    <div class="shell">
      <SideNav />
      <main class="main">
        <RouterView v-slot="{ Component }">
          <Transition name="fade" mode="out-in">
            <component :is="Component" />
          </Transition>
        </RouterView>
      </main>
    </div>
  </div>
</template>

<style scoped>
.app { min-height: 100vh; display: flex; flex-direction: column; }
.top { background: var(--brand-primary); color: #fff; border-bottom: 6px solid transparent; border-image: linear-gradient(90deg, #2F6BFF, #8B3DFF, #FF3D81, #FF8A00, #FFC400, #0BB37F) 1; display: flex; justify-content: space-between; align-items: center; gap: 12px; padding: 10px 20px; }
.logo { font: 700 22px var(--font-title); }
.logo small, .who small { display: block; font: 600 14px var(--font-body); }
.logo small { margin-top: -4px; }
.who { font-weight: 700; text-align: right; }
.who small { font-weight: 400; }
.shell { flex: 1; width: 100%; max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 200px 1fr; }
.main { padding: 20px; min-width: 0; }
@media (max-width: 820px) { .shell { grid-template-columns: 1fr; } }
</style>
