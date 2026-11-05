<script setup lang="ts">
/** @component O07 RecentStrip — 近期使用（橫向 chips） */
import { Clock } from 'lucide-vue-next'
import BaseChip from '../atoms/BaseChip.vue'
import ChipRail from '../molecules/ChipRail.vue'
import SectionTitle from '../molecules/SectionTitle.vue'

export type RecentItem = { title: string; path: string }
defineProps<{ items: RecentItem[] }>()
defineEmits<{ open: [path: string] }>()
</script>

<template>
  <section v-if="items.length">
    <SectionTitle title="近期使用" />
    <ChipRail>
      <BaseChip v-for="r in items" :key="r.path" :icon="Clock" @click="$emit('open', r.path)">{{ r.title }}</BaseChip>
    </ChipRail>
  </section>
</template>
