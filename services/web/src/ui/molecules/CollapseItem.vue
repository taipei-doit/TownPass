<script setup lang="ts">
/** @component M04 CollapseItem — 可展開列 */
import { ref, useId, type Component } from 'vue'
import { ChevronDown } from 'lucide-vue-next'

/** Expandable row, e.g. 注意事項 / FAQ entries. */
const props = defineProps<{ title: string; icon?: Component; defaultOpen?: boolean }>()
const open = ref(!!props.defaultOpen)
const id = useId()
</script>

<template>
  <div class="border-b border-grey-100 last:border-b-0">
    <button
      type="button"
      class="flex w-full items-center gap-2 py-3.5 text-left"
      :aria-expanded="open"
      :aria-controls="id"
      @click="open = !open"
    >
      <component :is="icon" v-if="icon" class="size-5 shrink-0 text-primary-500" aria-hidden="true" />
      <span class="flex-1 font-medium text-grey-800">{{ title }}</span>
      <ChevronDown class="size-5 shrink-0 text-grey-400 transition-transform" :class="open && 'rotate-180'" aria-hidden="true" />
    </button>
    <div v-show="open" :id="id" class="pb-4 text-sm leading-relaxed text-grey-600">
      <slot />
    </div>
  </div>
</template>
