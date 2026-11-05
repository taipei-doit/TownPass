<script setup lang="ts">
/** @component M02 ListItem — 列表列 */
import type { Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import { ChevronRight } from 'lucide-vue-next'
import IconBadge from '../atoms/IconBadge.vue'

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
    <IconBadge v-if="icon" :icon="icon" />
    <span class="min-w-0 flex-1">
      <span class="block truncate font-medium text-grey-800">{{ title }}</span>
      <span v-if="subtitle" class="block truncate text-sm text-grey-500">{{ subtitle }}</span>
    </span>
    <slot name="trailing">
      <ChevronRight v-if="to" class="size-5 shrink-0 text-grey-300" aria-hidden="true" />
    </slot>
  </component>
</template>
