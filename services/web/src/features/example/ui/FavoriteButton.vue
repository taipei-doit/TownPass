<script setup lang="ts">
/** @component EX-C02 FavoriteButton — 收藏切換（需要登入） */
import { Heart } from 'lucide-vue-next'

defineProps<{ active: boolean; busy?: boolean }>()
defineEmits<{ toggle: [] }>()
</script>

<template>
  <button
    type="button"
    class="-m-2 p-2 transition-opacity disabled:opacity-40"
    :aria-pressed="active"
    :aria-label="active ? '取消收藏' : '收藏'"
    :disabled="busy"
    @click="$emit('toggle')"
  >
    <Heart class="size-6" :class="active ? 'fill-warn-200 text-warn-200' : 'text-grey-400'" />
  </button>
</template>
