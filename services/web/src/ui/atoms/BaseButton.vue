<script setup lang="ts">
/** @component A01 BaseButton — 按鈕（primary/secondary/outline/ghost/danger） */
import { computed, type Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import { LoaderCircle } from 'lucide-vue-next'

const props = withDefaults(
  defineProps<{
    variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger'
    size?: 'sm' | 'md' | 'lg'
    block?: boolean
    loading?: boolean
    disabled?: boolean
    icon?: Component
    /** Renders a RouterLink instead of a <button> */
    to?: RouteLocationRaw
    type?: 'button' | 'submit'
  }>(),
  { variant: 'primary', size: 'md', type: 'button' },
)

const variants = {
  primary: 'bg-primary-500 text-white active:bg-primary-600',
  secondary: 'bg-secondary-500 text-white active:bg-secondary-600',
  outline: 'border border-primary-500 bg-white text-primary-500 active:bg-primary-50',
  ghost: 'bg-transparent text-primary-600 active:bg-primary-50',
  danger: 'bg-warn-200 text-white active:bg-warn-100',
}
const sizes = { sm: 'h-9 px-3 text-sm', md: 'h-11 px-4 text-base', lg: 'h-13 px-5 text-lg' }

const cls = computed(() => [
  'inline-flex items-center justify-center gap-2 rounded-lg font-semibold transition-colors select-none',
  'disabled:opacity-40 aria-disabled:pointer-events-none aria-disabled:opacity-40',
  variants[props.variant],
  sizes[props.size],
  props.block && 'w-full',
])
</script>

<template>
  <RouterLink v-if="to" :to="to" :class="cls" :aria-disabled="disabled || loading || undefined">
    <component :is="icon" v-if="icon" class="size-5" aria-hidden="true" />
    <slot />
  </RouterLink>
  <button v-else :type="type" :class="cls" :disabled="disabled || loading" :aria-busy="loading || undefined">
    <LoaderCircle v-if="loading" class="size-5 animate-spin" aria-hidden="true" />
    <component :is="icon" v-else-if="icon" class="size-5" aria-hidden="true" />
    <slot />
  </button>
</template>
