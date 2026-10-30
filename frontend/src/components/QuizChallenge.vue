<script setup>
import { computed, ref, watch } from 'vue'
import { answerChoices } from '../data/playful'
import { useAppStore } from '../stores/app'

const props = defineProps({
  questions: { type: Array, required: true },
  progressKey: { type: String, default: 'quiz' }
})
const store = useAppStore()
const activityId = store.actividadActual?.id_contenido
const saved = activityId ? store.getChapterProgress(activityId).quizzes?.[props.progressKey] || {} : {}
const current = ref(saved.current || 0)
const solved = ref(saved.solved || {})
const selected = ref(saved.selected ?? null)
const hint = ref(saved.hint || false)
const complete = ref(saved.complete || false)
const question = computed(() => props.questions[current.value])
const choices = computed(() => answerChoices(question.value.answer, current.value))
const correct = computed(() => !!solved.value[current.value])
const stars = computed(() => Object.keys(solved.value).length)
function answer(value) {
  if (correct.value) return
  selected.value = value
  if (value === question.value.answer) solved.value[current.value] = true
}
function next() {
  if (current.value === props.questions.length - 1) complete.value = true
  else current.value++
  selected.value = null
  hint.value = false
}
function reset() {
  current.value = 0
  solved.value = {}
  complete.value = false
  selected.value = null
  hint.value = false
}

watch(
  [current, solved, selected, hint, complete],
  () => {
    if (!activityId) return
    const progress = store.getChapterProgress(activityId)
    store.saveChapterProgress(activityId, {
      quizzes: {
        ...progress.quizzes,
        [props.progressKey]: {
          current: current.value,
          solved: solved.value,
          selected: selected.value,
          hint: hint.value,
          complete: complete.value
        }
      }
    })
  },
  { deep: true, flush: 'sync' }
)
</script>

<template>
  <section class="challenge" aria-label="Desafío de detectives">
    <header><span class="eyebrow">🔎 DETECTIVES DE DATOS</span><span class="star-count">⭐ {{ stars }} / {{ questions.length }}</span></header>
    <div class="progress" role="progressbar" aria-label="Desafíos resueltos" :aria-valuenow="stars" :aria-valuemax="questions.length" aria-valuemin="0"><span :style="{ width: `${stars / questions.length * 100}%` }"></span></div>
    <div v-if="complete" class="celebration" role="status">
      <span aria-hidden="true">🏆 ✨</span><h2>¡Misión cumplida, equipo!</h2><p>Encontraron todas las respuestas. ¡Un aplauso para ustedes!</p><button @click="reset">Volver a jugar ↻</button>
    </div>
    <template v-else>
      <p class="step">Pista {{ current + 1 }} de {{ questions.length }} · Miren los datos y elijan una tarjeta</p>
      <h2>{{ question.text }}</h2>
      <div class="answer-tiles">
        <button v-for="(value, i) in choices" :key="`${current}:${value}`" class="answer-tile" :class="{ correct: correct && selected === value, retry: !correct && selected === value }" :disabled="correct" :aria-label="`Responder ${value}`" @click="answer(value)">
          <span class="letter">{{ ['A', 'B', 'C', 'D'][i] }}</span><strong>{{ value }}</strong><span aria-hidden="true">{{ correct && selected === value ? '⭐' : '✦' }}</span>
        </button>
      </div>
      <div class="feedback" aria-live="polite">
        <p v-if="correct">🌈 ¡Lo descubrieron! Ganaron una estrella.</p>
        <p v-else-if="selected !== null">🌱 ¡Buen intento! Miren los datos y prueben otra tarjeta.</p>
        <p v-else>Conversen con su equipo antes de elegir.</p>
      </div>
      <footer><button class="hint" @click="hint = !hint" :aria-expanded="hint">💡 {{ hint ? 'Ocultar pista' : 'Dame una pista' }}</button><button v-if="correct" @click="next">{{ current === questions.length - 1 ? 'Ver mi premio 🏆' : 'Siguiente desafío →' }}</button></footer>
      <p v-if="hint" class="hint-text">{{ question.hint || 'Busquen la categoría en la tabla. Para el total, sumen las cantidades; para la diferencia, resten la menor de la mayor.' }}</p>
    </template>
  </section>
</template>

<style scoped>
.challenge { padding: clamp(20px, 4vw, 36px); border: 2px solid #ded5f5; border-radius: 28px; background: #fff; box-shadow: 0 7px 0 #e3dbf0; }
header, footer { display: flex; justify-content: space-between; gap: 12px; align-items: center; flex-wrap: wrap; }
.eyebrow { font-weight: 900; font-size: 13px; letter-spacing: 1.3px; color: #67519b; }
.star-count { background: #fff3bf; color: #725306; padding: 8px 14px; border-radius: 100px; font-weight: 900; }
.progress { height: 10px; border-radius: 20px; background: #efeaf8; margin: 16px 0 24px; overflow: hidden; }
.progress span { display: block; height: 100%; background: #6c55ca; transition: width .3s; border-radius: inherit; }
.step { color: #726985; font-size: 15px; margin-bottom: 12px; }
h2 { font-size: clamp(22px, 3vw, 30px); line-height: 1.3; }
.answer-tiles { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin: 26px 0 20px; }
button { font: 800 17px var(--font-body); border-radius: 14px; border: 0; background: #6440ce; color: #fff; padding: 12px 20px; cursor: pointer; }
.answer-tile { display: flex; align-items: center; justify-content: space-between; gap: 8px; border: 2px solid #d6cef1; border-bottom-width: 6px; background: #f7f3ff; color: #433270; padding: 20px 14px; transition: transform .15s; }
.answer-tile:hover:not(:disabled) { transform: translateY(-4px); background: #eee6ff; }
.answer-tile strong { font-size: 32px; }
.letter { font-size: 12px; border: 1px solid #c7bbdf; border-radius: 8px; padding: 3px 6px; }
.answer-tile.correct { background: #ddf8eb; border-color: #3a9c72; color: #195b40; }
.answer-tile.retry { background: #fff3df; border-color: #d99b42; }
.feedback { min-height: 50px; font-weight: 800; color: #325f58; }
.hint { background: #fff5d9; color: #73531b; }
.hint-text { background: #fff9e9; padding: 16px; margin-top: 14px; border-radius: 14px; }
.celebration { text-align: center; padding: 30px 0; display: grid; gap: 18px; justify-items: center; }
.celebration > span { font-size: 64px; animation: pop .35s ease-out; }
@keyframes pop { from { transform: scale(.6); } to { transform: scale(1); } }
@media(max-width: 650px) { .answer-tiles { grid-template-columns: repeat(2, 1fr); } }
</style>
