<script setup lang="ts">
/** Grey shimmering placeholder lines while data loads. */
withDefaults(defineProps<{ lines?: number }>(), { lines: 3 })
</script>

<template>
  <div class="animate-pulse space-y-2.5" aria-busy="true" aria-label="載入中">
    <div v-for="i in lines" :key="i" class="h-4 rounded bg-grey-100" :class="i === lines && lines > 1 ? 'w-2/3' : 'w-full'" />
  </div>
</template>
