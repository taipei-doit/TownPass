<script setup lang="ts">
import type { Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import { ChevronRight } from 'lucide-vue-next'

/** One row in a list. With `to` it becomes a link and shows a chevron. */
defineProps<{ title: string; subtitle?: string; icon?: Component; to?: RouteLocationRaw }>()
</script>

<template>
  <component
    :is="to ? 'RouterLink' : 'div'"
    :to="to"
    class="flex min-h-14 items-center gap-3 py-3"
    :class="to && 'active:bg-grey-50'"
  >
    <span v-if="icon" class="grid size-10 shrink-0 place-items-center rounded-full bg-primary-50 text-primary-500">
      <component :is="icon" class="size-5" aria-hidden="true" />
    </span>
    <span class="min-w-0 flex-1">
      <span class="block truncate font-medium text-grey-800">{{ title }}</span>
      <span v-if="subtitle" class="block truncate text-sm text-grey-500">{{ subtitle }}</span>
    </span>
    <slot name="trailing">
      <ChevronRight v-if="to" class="size-5 shrink-0 text-grey-300" aria-hidden="true" />
    </slot>
  </component>
</template>
