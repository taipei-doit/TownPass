<script setup lang="ts">
import type { RouteLocationRaw } from 'vue-router'

/** White rounded card with the official card shadow. Pass `to` to make the whole card a link. */
defineProps<{ to?: RouteLocationRaw; flat?: boolean }>()
</script>

<template>
  <component
    :is="to ? 'RouterLink' : 'div'"
    :to="to"
    class="block rounded-xl bg-white p-4"
    :class="[flat ? 'border border-grey-100' : 'shadow-card', to && 'transition-colors active:bg-grey-50']"
  >
    <slot />
  </component>
</template>
