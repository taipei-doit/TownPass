<script setup lang="ts">
/** @component M07 ResultCard — 搜尋結果卡片（圖示 + 標題 + 副標 + 標籤） */
import type { Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import IconBadge from '../atoms/IconBadge.vue'
import BaseTag from '../atoms/BaseTag.vue'
import BaseCard from './BaseCard.vue'

defineProps<{ title: string; subtitle?: string; tags?: string[]; icon: Component; to: RouteLocationRaw }>()
</script>

<template>
  <BaseCard :to="to" flat class="flex items-start gap-3 !p-3">
    <IconBadge :icon="icon" size="sm" />
    <span class="min-w-0 flex-1">
      <span class="block font-medium text-grey-900">{{ title }}</span>
      <span v-if="subtitle" class="block truncate text-sm text-grey-500">{{ subtitle }}</span>
      <span v-if="tags?.length" class="mt-1 flex flex-wrap gap-1">
        <BaseTag v-for="t in tags.slice(0, 3)" :key="t">{{ t }}</BaseTag>
      </span>
    </span>
  </BaseCard>
</template>
