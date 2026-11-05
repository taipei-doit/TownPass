<script setup lang="ts">
import type { Component } from 'vue'

/** Pill-shaped quick option, e.g. suggestion chips under the chat input. */
defineProps<{ active?: boolean; icon?: Component }>()
defineEmits<{ click: [] }>()
</script>

<template>
  <button
    type="button"
    class="inline-flex h-9 shrink-0 items-center gap-1.5 rounded-full border px-3.5 text-sm whitespace-nowrap transition-colors"
    :class="
      active
        ? 'border-primary-500 bg-primary-500 text-white'
        : 'border-primary-200 bg-primary-50 text-primary-700 active:bg-primary-100'
    "
    :aria-pressed="active"
    @click="$emit('click')"
  >
    <component :is="icon" v-if="icon" class="size-4" aria-hidden="true" />
    <slot />
  </button>
</template>
