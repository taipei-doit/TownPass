<script setup lang="ts">
/** @component RG-P01 RagLabPage — 裝置端 RAG 實驗頁（硬體檢查、下載模型、提問） */
import { computed, defineAsyncComponent, onMounted, ref } from 'vue'
import { Download } from 'lucide-vue-next'
import { BaseButton, ChatComposer, EmptyState, PageContainer, type InfoRow } from '@/ui'
import { DeviceModelCard as loadDeviceModelCard, EMBEDDING_MODEL, useModel, type ModelKey } from '@/addons/model'
import { useRag, type RagAnswer } from '../index'
import AnswerCard from './AnswerCard.vue'

const DeviceModelCard = defineAsyncComponent(loadDeviceModelCard)

const { status, docsCount, error: prepareError, inspect, prepare, ask } = useRag()
const { progress, message, hardware, choice, disclosure, isOffline } = useModel()
const override = ref<'auto' | ModelKey>('auto')
const query = ref('')
const answering = ref(false)
const streamed = ref('')
const result = ref<RagAnswer | null>(null)
const error = ref('')

const ov = () => (override.value === 'auto' ? undefined : override.value)
const hwRows = computed<InfoRow[]>(() => {
  const h = hardware.value
  if (!h) return []
  return [
    { label: 'WebGPU', value: h.webgpu ? `有（${h.gpuName || 'GPU'}，fp16 ${h.shaderF16 ? '支援' : '不支援'}）` : '沒有' },
    { label: '記憶體', value: h.memoryGB === null ? '無法得知' : `約 ${h.memoryGB} GB` },
    { label: 'CPU', value: `${h.cores} 核` },
    { label: '可用空間', value: h.freeStorageMB === null ? '無法得知' : `${h.freeStorageMB} MB` },
  ]
})
const busy = computed(() => ['probing', 'downloading', 'indexing'].includes(status.value))
const MODE_LABEL = { llm: '模型生成', extractive: '摘錄（未使用語言模型）', guarded: '模型回答未通過檢查，改顯示資料原文' } as const
const examples = [{ label: '公園可以帶寵物嗎？' }, { label: '哪裡可以自習？' }, { label: '運動中心幾點開？' }]

async function setOverride(v: 'auto' | ModelKey) {
  override.value = v
  await inspect(ov())
}

async function submit(text: string) {
  if (!text.trim() || answering.value) return
  answering.value = true
  streamed.value = ''
  result.value = null
  error.value = ''
  try {
    result.value = await ask(text, (t) => (streamed.value += t))
    streamed.value = result.value.answer // may differ from the stream if the grounding guard rejected it
  } catch (err) {
    error.value = err instanceof Error ? err.message : String(err)
  } finally {
    answering.value = false
  }
}

onMounted(() => inspect(ov()))
</script>

<template>
  <PageContainer title="AI 問答（實驗）" back>
    <div class="space-y-4 pt-2">
      <DeviceModelCard
        v-if="choice"
        :hardware="hwRows"
        :model-label="choice.label"
        :size-m-b="choice.sizeMB"
        :reasons="choice.reasons"
        :disclosure="disclosure"
        :override="override"
        :offline="isOffline"
        @override="setOverride"
      />

      <div v-if="status !== 'ready'" class="space-y-2">
        <BaseButton block :icon="Download" :loading="busy" @click="prepare(ov())">
          {{ isOffline ? '載入模型' : `下載並載入（約 ${(choice?.sizeMB ?? 0) + EMBEDDING_MODEL.sizeMB} MB，只需一次）` }}
        </BaseButton>
        <div v-if="busy" class="h-2 overflow-hidden rounded-full bg-grey-100">
          <div class="h-full bg-primary-500 transition-all" :style="{ width: `${Math.round(progress * 100)}%` }" />
        </div>
        <p v-if="status === 'error'" class="text-sm text-warn-200">{{ prepareError }}</p>
        <p v-else-if="message" class="text-sm text-grey-500">{{ message }}</p>
      </div>
      <p v-else class="text-sm text-grey-500">已就緒：App 內資料已切成 {{ docsCount }} 個片段並向量化；{{ choice!.key === 'none' ? '只做檢索與摘錄（不使用語言模型）' : `${choice!.label} 在手機上執行` }}。</p>

      <AnswerCard
        v-if="streamed || answering"
        :text="streamed"
        :busy="answering"
        :sources="result?.sources ?? []"
        :meta="result ? `${MODE_LABEL[result.mode]}・${(result.ms / 1000).toFixed(1)} 秒` : ''"
      />
      <p v-if="error" class="text-sm text-warn-200">{{ error }}</p>
      <EmptyState v-if="!streamed && !answering && status === 'ready'" title="問一個關於 App 內服務的問題" description="回答只會根據 App 內的資料" />
    </div>

    <template v-if="status === 'ready'" #bottom>
      <ChatComposer
        v-model="query"
        :quick-actions="examples"
        :ready="!answering"
        placeholder="例如：公園可以帶寵物嗎？"
        @submit="(t) => { submit(t); query = '' }"
        @pick="(i) => submit(examples[i]!.label)"
      />
    </template>
  </PageContainer>
</template>
