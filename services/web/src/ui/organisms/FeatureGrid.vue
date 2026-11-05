<script setup lang="ts">
/** @component O06 FeatureGrid — 服務卡片兩欄網格 */
import type { Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import BaseCard from '../molecules/BaseCard.vue'
import SectionTitle from '../molecules/SectionTitle.vue'

export type GridItem = { key: string; title: string; description: string; icon: Component; to: RouteLocationRaw }
withDefaults(defineProps<{ items: GridItem[]; title?: string }>(), { title: '服務' })
</script>

<template>
  <section>
    <SectionTitle :title="title" />
    <div class="grid grid-cols-2 gap-3">
      <BaseCard v-for="f in items" :key="f.key" :to="f.to" class="!p-3.5">
        <component :is="f.icon" class="mb-2 size-7 text-primary-500" aria-hidden="true" />
        <p class="font-semibold text-grey-900">{{ f.title }}</p>
        <p class="mt-0.5 line-clamp-2 text-xs text-grey-500">{{ f.description }}</p>
      </BaseCard>
    </div>
  </section>
</template>
