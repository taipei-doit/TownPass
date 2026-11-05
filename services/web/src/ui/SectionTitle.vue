<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router'

defineProps<{ title: string; actionLabel?: string; to?: RouteLocationRaw }>()
</script>

<template>
  <div class="mb-2 flex items-end justify-between">
    <h2 class="text-lg font-semibold text-grey-900">{{ title }}</h2>
    <RouterLink v-if="to && actionLabel" :to="to" class="text-sm text-primary-600">{{ actionLabel }}</RouterLink>
  </div>
</template>
