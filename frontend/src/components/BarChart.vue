<script setup>
import { computed } from 'vue'

const props = defineProps({
  items: { type: Array, required: true }, // [{ key, emoji, label, value }]
  max: { type: Number, default: 8 },
  title: { type: String, default: '' },
  height: { type: Number, default: 220 },
  wrong: { type: Array, default: () => [] } // claves de barras a revisar
})
const ticks = computed(() => {
  const t = []
  for (let v = props.max; v >= 0; v -= 2) t.push(v)
  return t
})
const colors = ['#2F6BFF', '#8B3DFF', '#FF8A00', '#00A6C7']
</script>

<template>
  <figure class="bc" :style="{ '--n': items.length }">
    <figcaption v-if="title">{{ title }}</figcaption>
    <div class="wrap">
      <div class="y" :style="{ height: height + 'px' }"><span v-for="t in ticks" :key="t">{{ t }}</span></div>
      <div class="plot" :style="{ height: height + 'px' }">
        <i v-for="t in ticks" :key="t" class="line" :style="{ bottom: (t / max) * 100 + '%' }"></i>
        <div class="cols">
          <div v-for="(it, i) in items" :key="it.key" class="col">
            <div class="bb" :class="{ wrong: wrong.includes(it.key) }" :style="{ height: (it.value / max) * 100 + '%', background: colors[i % 4] }">
              <span class="val">{{ it.value }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="labels">
      <div v-for="it in items" :key="it.key" class="lab">
        <span class="e" aria-hidden="true">{{ it.emoji }}</span><b>{{ it.label }}</b>
        <slot name="foot" :item="it" />
      </div>
    </div>
  </figure>
</template>

<style scoped>
.bc { margin: 0; }
figcaption { font: 700 20px var(--font-title); text-align: center; margin-bottom: 10px; }
.wrap { display: flex; gap: 8px; margin-top: 34px; } /* espacio para los números sobre las barras */
.y { width: 36px; display: flex; flex-direction: column; justify-content: space-between; align-items: flex-end; font-weight: 800; font-size: 16px; transform: translateY(-9px); padding-bottom: 0; }
.y span { line-height: 18px; }
.plot { position: relative; flex: 1; border-left: 3px solid var(--text-main); border-bottom: 3px solid var(--text-main); }
.line { position: absolute; left: 0; right: 0; border-top: 1px dashed var(--border-card); }
.cols { position: absolute; inset: 0; display: grid; grid-template-columns: repeat(var(--n), 1fr); gap: 16px; padding: 0 16px; align-items: end; }
.col { height: 100%; display: flex; align-items: flex-end; }
.bb { position: relative; width: 100%; border-radius: 10px 10px 0 0; transition: height .25s; }
.bb.wrong { outline: 4px solid var(--feedback-alert); outline-offset: 2px; }
.val { position: absolute; top: -28px; left: 0; right: 0; text-align: center; font: 800 20px var(--font-body); }
.labels { display: grid; grid-template-columns: repeat(var(--n), 1fr); gap: 16px; margin: 8px 0 0 47px; padding: 0 16px; }
.lab { display: grid; justify-items: center; gap: 2px; text-align: center; }
.e { font-size: 30px; line-height: 1; }
.lab b { font-size: 17px; }
</style>