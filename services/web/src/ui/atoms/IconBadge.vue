<script setup lang="ts">
/** @component A06 IconBadge — 圓形圖示底 */
import type { Component } from 'vue'

withDefaults(defineProps<{ icon: Component; size?: 'sm' | 'md' }>(), { size: 'md' })
</script>

<template>
  <span
    class="grid shrink-0 place-items-center rounded-full bg-primary-50 text-primary-500"
    :class="size === 'sm' ? 'size-9' : 'size-10'"
  >
    <component :is="icon" class="size-5" aria-hidden="true" />
  </span>
</template>
