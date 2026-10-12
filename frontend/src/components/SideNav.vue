<script setup>
const links = [
  { to: '/', label: 'Inicio' },
  { to: '/configuracion', label: 'Configuración' }
]
</script>

<template>
  <nav class="nav" aria-label="Principal">
    <RouterLink v-for="l in links" :key="l.to" :to="l.to">{{ l.label }}</RouterLink>
  </nav>
</template>

<style scoped>
.nav { padding: 16px 12px; display: flex; flex-direction: column; gap: 4px; }
a { padding: 10px 14px; border-radius: 12px; color: var(--text-main); text-decoration: none; font-weight: 700; }
a:hover { background: var(--bg-surface); }
a.router-link-exact-active { background: var(--brand-primary); color: #fff; box-shadow: 0 3px 0 var(--brand-primary-hover); }
@media (max-width: 820px) { .nav { flex-direction: row; overflow-x: auto; } a { white-space: nowrap; } }
</style>