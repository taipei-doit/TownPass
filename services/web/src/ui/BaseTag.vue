<script setup lang="ts">
withDefaults(defineProps<{ tone?: 'primary' | 'secondary' | 'grey' | 'warn' | 'success' }>(), { tone: 'primary' })

const tones = {
  primary: 'bg-primary-50 text-primary-700',
  secondary: 'bg-secondary-50 text-secondary-800',
  grey: 'bg-grey-50 text-grey-600',
  warn: 'bg-orange-50 text-warn-200',
  success: 'bg-[#f0f7e6] text-success',
}
</script>

<template>
  <span class="inline-flex items-center rounded px-2 py-0.5 text-xs font-medium" :class="tones[tone]">
    <slot />
  </span>
</template>
