<script setup lang="ts">
/** @component ML-C01 DeviceModelCard — 手機硬體、選用模型與理由、模型揭露 */
import { Cpu } from 'lucide-vue-next'
import { BaseCard, BaseChip, BaseTag, ChipRail, InfoTable, type InfoRow } from '@/ui'

defineProps<{
  hardware: InfoRow[]
  modelLabel: string
  sizeMB: number
  reasons: string[]
  disclosure: InfoRow[]
  override: 'auto' | 'none' | 'small' | 'large'
  offline: boolean
}>()
defineEmits<{ override: [value: 'auto' | 'none' | 'small' | 'large'] }>()
</script>

<template>
  <BaseCard class="space-y-3">
    <div class="flex items-center gap-2">
      <Cpu class="size-5 text-primary-500" aria-hidden="true" />
      <p class="flex-1 font-semibold text-grey-900">{{ modelLabel }}<template v-if="sizeMB">（約 {{ sizeMB }} MB）</template></p>
      <BaseTag :tone="offline ? 'success' : 'grey'">{{ offline ? '可離線' : '需先下載' }}</BaseTag>
    </div>
    <ul class="list-disc space-y-0.5 pl-5 text-sm text-grey-600">
      <li v-for="r in reasons" :key="r">{{ r }}</li>
    </ul>
    <ChipRail>
      <BaseChip :active="override === 'auto'" @click="$emit('override', 'auto')">自動選擇</BaseChip>
      <BaseChip :active="override === 'none'" @click="$emit('override', 'none')">只摘錄</BaseChip>
      <BaseChip :active="override === 'small'" @click="$emit('override', 'small')">Granite 350M</BaseChip>
      <BaseChip :active="override === 'large'" @click="$emit('override', 'large')">Gemma 1B</BaseChip>
    </ChipRail>
    <InfoTable :rows="hardware" />
    <InfoTable :rows="disclosure" />
  </BaseCard>
</template>
