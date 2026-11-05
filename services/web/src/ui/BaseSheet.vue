<script setup lang="ts">
import { onBeforeUnmount, watch } from 'vue'
import { X } from 'lucide-vue-next'

/** Bottom sheet (mobile-style dialog). v-model:open controls visibility. */
const open = defineModel<boolean>('open', { default: false })
defineProps<{ title?: string }>()

const onKey = (e: KeyboardEvent) => e.key === 'Escape' && (open.value = false)
watch(open, (v) => {
  document.body.style.overflow = v ? 'hidden' : ''
  if (v) window.addEventListener('keydown', onKey)
  else window.removeEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onKey)
})
</script>

<template>
  <Teleport to="body">
    <Transition enter-from-class="opacity-0" leave-to-class="opacity-0" enter-active-class="transition-opacity" leave-active-class="transition-opacity">
      <div v-if="open" class="fixed inset-0 z-40 bg-black/40" @click="open = false" />
    </Transition>
    <Transition enter-from-class="translate-y-full" leave-to-class="translate-y-full" enter-active-class="transition-transform duration-200" leave-active-class="transition-transform duration-200">
      <section
        v-if="open"
        role="dialog"
        aria-modal="true"
        :aria-label="title"
        class="fixed inset-x-0 bottom-0 z-50 mx-auto max-h-[85vh] max-w-md overflow-y-auto rounded-t-2xl bg-white px-4 pt-3 pb-[max(1rem,env(safe-area-inset-bottom))]"
      >
        <header class="mb-3 flex items-center justify-between">
          <h2 class="text-lg font-semibold text-grey-900">{{ title }}</h2>
          <button type="button" class="-mr-2 p-2 text-grey-500" aria-label="關閉" @click="open = false">
            <X class="size-5" />
          </button>
        </header>
        <slot />
      </section>
    </Transition>
  </Teleport>
</template>
