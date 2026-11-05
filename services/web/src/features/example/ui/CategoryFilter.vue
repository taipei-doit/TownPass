<script setup lang="ts">
/** @component EX-C01 CategoryFilter — 分類篩選 chips */
import { BaseChip, ChipRail } from '@/ui'

defineProps<{ categories: string[]; active: string }>()
defineEmits<{ select: [category: string] }>()
</script>

<template>
  <ChipRail class="py-2">
    <BaseChip v-for="c in categories" :key="c" :active="active === c" @click="$emit('select', c)">{{ c }}</BaseChip>
  </ChipRail>
</template>
