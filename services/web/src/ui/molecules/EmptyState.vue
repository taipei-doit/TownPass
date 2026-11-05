<script setup lang="ts">
/** @component M05 EmptyState — 空狀態 */
import type { Component } from 'vue'
import { Inbox } from 'lucide-vue-next'

defineProps<{ title: string; description?: string; icon?: Component }>()
</script>

<template>
  <div class="flex flex-col items-center px-6 py-10 text-center">
    <span class="mb-3 grid size-14 place-items-center rounded-full bg-grey-50 text-grey-400">
      <component :is="icon ?? Inbox" class="size-7" aria-hidden="true" />
    </span>
    <p class="font-medium text-grey-700">{{ title }}</p>
    <p v-if="description" class="mt-1 text-sm text-grey-500">{{ description }}</p>
    <div v-if="$slots.default" class="mt-4"><slot /></div>
  </div>
</template>
