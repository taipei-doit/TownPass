<script setup lang="ts">
/** @component A04 BaseInput — 文字輸入（單行/多行） */
import { useId, type Component } from 'vue'

const model = defineModel<string>({ default: '' })
defineProps<{
  label?: string
  placeholder?: string
  error?: string
  hint?: string
  type?: string
  icon?: Component
  multiline?: boolean
  rows?: number
}>()
const id = useId()
</script>

<template>
  <div class="space-y-1.5">
    <label v-if="label" :for="id" class="block text-sm font-medium text-grey-700">{{ label }}</label>
    <div class="relative">
      <component
        :is="icon"
        v-if="icon"
        class="pointer-events-none absolute top-1/2 left-3 size-5 -translate-y-1/2 text-grey-400"
        aria-hidden="true"
      />
      <textarea
        v-if="multiline"
        :id="id"
        v-model="model"
        :rows="rows ?? 4"
        :placeholder="placeholder"
        class="block w-full rounded-lg border bg-white px-3 py-2.5 text-base outline-none placeholder:text-grey-400 focus:border-primary-500"
        :class="error ? 'border-warn-200' : 'border-grey-200'"
      />
      <input
        v-else
        :id="id"
        v-model="model"
        :type="type ?? 'text'"
        :placeholder="placeholder"
        class="block h-11 w-full rounded-lg border bg-white pr-3 text-base outline-none placeholder:text-grey-400 focus:border-primary-500"
        :class="[icon ? 'pl-10' : 'pl-3', error ? 'border-warn-200' : 'border-grey-200']"
      />
    </div>
    <p v-if="error" class="text-sm text-warn-200">{{ error }}</p>
    <p v-else-if="hint" class="text-sm text-grey-500">{{ hint }}</p>
  </div>
</template>
