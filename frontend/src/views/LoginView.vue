<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAppStore } from '../stores/app'
import { APP_NAME, ASIGNATURA, EJE } from '../config'

const store = useAppStore()
const route = useRoute()
const router = useRouter()

const nickname = ref('')
const contrasena = ref('')
const verClave = ref(false)
const cargando = ref(false)
const error = ref('')

const puedeEnviar = computed(() => nickname.value.trim() && contrasena.value && !cargando.value)

async function ingresar() {
  if (!puedeEnviar.value) return
  error.value = ''
  cargando.value = true
  try {
    await store.login(nickname.value.trim(), contrasena.value)
    // Vuelve a la ruta que se intentaba abrir, o al inicio
    const destino = typeof route.query.redirect === 'string' ? route.query.redirect : '/'
    router.replace(destino)
  } catch (e) {
    error.value = e.message
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="rainbow" aria-hidden="true"></div>
    <main class="login-wrap">
      <section class="hero" aria-hidden="true">
        <span class="sym">📝 ➔ 📊 ➔ 🔎 ➔ ✏️</span>
        <h1>🔢 {{ APP_NAME }}</h1>
        <p>{{ ASIGNATURA }} · {{ EJE }}</p>
        <p class="sub">Recursos interactivos para proyectar en clase.</p>
      </section>

      <form class="card-login" @submit.prevent="ingresar" novalidate>
        <h2>¡Bienvenida, profesora!</h2>
        <p class="lead">Ingresa con tu usuario para comenzar la clase.</p>

        <label for="nick">Usuario</label>
        <input id="nick" v-model="nickname" type="text" autocomplete="username" autofocus placeholder="Tu nickname" />

        <label for="pass">Contraseña</label>
        <div class="pass-row">
          <input id="pass" v-model="contrasena" :type="verClave ? 'text' : 'password'" autocomplete="current-password" placeholder="Tu contraseña" />
          <button type="button" class="ojo" :aria-pressed="verClave" @click="verClave = !verClave">{{ verClave ? 'Ocultar' : 'Ver' }}</button>
        </div>

        <p v-if="error" class="error" role="alert">{{ error }}</p>

        <button type="submit" class="btn-pri" :disabled="!puedeEnviar">{{ cargando ? 'Ingresando…' : 'Ingresar' }}</button>
      </form>
    </main>
  </div>
</template>

<style scoped>
.login-page { min-height: 100vh; display: flex; flex-direction: column; background: linear-gradient(110deg, #FDF7F5 0%, #FEE8EE 40%, #EFE9FE 70%, #E6F3FF 100%); }
.rainbow { height: 6px; background: linear-gradient(90deg, #2F6BFF, #8B3DFF, #FF3D81, #FF8A00, #FFC400, #0BB37F); }
.login-wrap { flex: 1; display: grid; grid-template-columns: 1fr 420px; gap: 40px; align-items: center; max-width: 1000px; width: 100%; margin: 0 auto; padding: 32px 24px; }

.hero { color: #222; }
.sym { display: block; font-size: 22px; letter-spacing: 2px; margin-bottom: 12px; }
.hero h1 { font-size: 44px; margin: 0 0 8px; color: #1B1F4B; }
.hero p { margin: 0; font-size: 20px; color: #555; font-weight: 700; }
.hero .sub { margin-top: 8px; font-size: 16px; font-weight: 400; color: #777; }

.card-login { background: #fff; border: 2px solid #5636FF; border-radius: 16px; padding: 28px; display: flex; flex-direction: column; gap: 8px; box-shadow: 0 6px 24px rgba(86, 54, 255, .10); }
.card-login h2 { font-size: 24px; margin: 0; color: #222; }
.lead { margin: 0 0 10px; color: #777; font-size: 15px; }
label { font-weight: 700; font-size: 15px; color: #333; margin-top: 6px; }
input { width: 100%; padding: 12px 14px; border: 2px solid #E3E6FF; border-radius: 12px; font: 400 16px var(--font-body); color: #1B1F4B; background: #fff; }
input:focus { outline: none; border-color: #5636FF; box-shadow: 0 0 0 3px rgba(86, 54, 255, .18); }
.pass-row { display: flex; gap: 8px; }
.ojo { background: #fff; border: 2px solid #5636FF; color: #5636FF; border-radius: 12px; padding: 0 14px; font-weight: 700; cursor: pointer; }
.ojo:hover { background: #F0EBFF; }

.error { background: #FFF1F2; color: #9F1239; border-radius: 12px; padding: 10px 14px; font-weight: 700; font-size: 15px; margin-top: 6px; }

.btn-pri { background: #5636FF; color: #fff; padding: 13px 24px; border-radius: 12px; border: none; font-weight: bold; cursor: pointer; font-size: 16px; margin-top: 14px; transition: opacity .2s; }
.btn-pri:hover:not(:disabled) { opacity: .9; }
.btn-pri:disabled { opacity: .45; cursor: not-allowed; }

@media (max-width: 820px) {
  .login-wrap { grid-template-columns: 1fr; gap: 20px; }
  .hero h1 { font-size: 34px; }
}
</style>
