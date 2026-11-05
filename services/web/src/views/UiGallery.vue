<script setup lang="ts">
// Every base component in one page, for teammates (and AI assistants) to copy from. Route: /#/dev/ui
import { ref } from 'vue'
import { Bus, MapPin, Phone, Search } from 'lucide-vue-next'
import {
  BaseButton,
  BaseCard,
  BaseChip,
  BaseInput,
  BaseSheet,
  BaseTag,
  CollapseItem,
  EmptyState,
  ListItem,
  OsmMap,
  PageContainer,
  SectionTitle,
  SkeletonBlock,
} from '@/ui'

const text = ref('')
const sheet = ref(false)
const chip = ref('全部')
const swatches = ['primary', 'secondary', 'grey', 'main', 'orange']
const steps = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
</script>

<template>
  <PageContainer title="UI 元件" back>
    <div class="space-y-8 pt-2">
      <section>
        <SectionTitle title="色票（官方 TownPass tokens）" />
        <div v-for="s in swatches" :key="s" class="mb-1 flex">
          <span class="w-20 text-xs text-grey-500">{{ s }}</span>
          <span v-for="n in steps" :key="n" class="h-6 flex-1" :class="`bg-${s}-${n}`" :title="`${s}-${n}`" />
        </div>
        <!-- safelist so Tailwind generates the dynamic swatch classes above -->
        <span class="hidden bg-primary-50 bg-primary-100 bg-primary-200 bg-primary-300 bg-primary-400 bg-primary-500 bg-primary-600 bg-primary-700 bg-primary-800 bg-primary-900 bg-secondary-50 bg-secondary-100 bg-secondary-200 bg-secondary-300 bg-secondary-400 bg-secondary-500 bg-secondary-600 bg-secondary-700 bg-secondary-800 bg-secondary-900 bg-grey-50 bg-grey-100 bg-grey-200 bg-grey-300 bg-grey-400 bg-grey-500 bg-grey-600 bg-grey-700 bg-grey-800 bg-grey-900 bg-main-50 bg-main-100 bg-main-200 bg-main-300 bg-main-400 bg-main-500 bg-main-600 bg-main-700 bg-main-800 bg-main-900 bg-orange-50 bg-orange-100 bg-orange-200 bg-orange-300 bg-orange-400 bg-orange-500 bg-orange-600 bg-orange-700 bg-orange-800 bg-orange-900" />
      </section>

      <section class="space-y-2">
        <SectionTitle title="BaseButton" />
        <BaseButton block :icon="Search">primary</BaseButton>
        <div class="flex flex-wrap gap-2">
          <BaseButton variant="secondary">secondary</BaseButton>
          <BaseButton variant="outline">outline</BaseButton>
          <BaseButton variant="ghost">ghost</BaseButton>
          <BaseButton variant="danger" size="sm">danger sm</BaseButton>
          <BaseButton loading>loading</BaseButton>
          <BaseButton disabled>disabled</BaseButton>
        </div>
      </section>

      <section>
        <SectionTitle title="BaseChip / BaseTag" />
        <div class="mb-3 flex gap-2">
          <BaseChip v-for="c in ['全部', '附近', '免費']" :key="c" :active="chip === c" @click="chip = c">{{ c }}</BaseChip>
        </div>
        <div class="flex gap-1.5">
          <BaseTag>primary</BaseTag><BaseTag tone="secondary">secondary</BaseTag><BaseTag tone="grey">grey</BaseTag>
          <BaseTag tone="warn">warn</BaseTag><BaseTag tone="success">success</BaseTag>
        </div>
      </section>

      <section class="space-y-3">
        <SectionTitle title="BaseInput" />
        <BaseInput v-model="text" label="搜尋" placeholder="輸入關鍵字" :icon="Search" hint="提示文字" />
        <BaseInput label="錯誤狀態" error="這個欄位必填" />
        <BaseInput label="多行" multiline placeholder="意見回饋…" />
      </section>

      <section class="space-y-3">
        <SectionTitle title="BaseCard / ListItem" />
        <BaseCard><p class="font-semibold">一般卡片</p><p class="text-sm text-grey-500">shadow-card</p></BaseCard>
        <BaseCard flat><p class="font-semibold">flat 卡片</p></BaseCard>
        <div class="divide-y divide-grey-100">
          <ListItem title="可點擊的列" subtitle="有 to 就會出現箭頭" :icon="MapPin" to="/" />
          <ListItem title="一般列" subtitle="沒有 to" :icon="Bus" />
        </div>
      </section>

      <section>
        <SectionTitle title="CollapseItem" />
        <CollapseItem title="開放時間" default-open>每日 06:00–22:00，除夕休館。</CollapseItem>
        <CollapseItem title="注意事項">請勿攜帶寵物入內。</CollapseItem>
      </section>

      <section class="space-y-3">
        <SectionTitle title="BaseSheet / EmptyState / Skeleton" />
        <BaseButton variant="outline" :icon="Phone" @click="sheet = true">開啟 BaseSheet</BaseButton>
        <BaseSheet v-model:open="sheet" title="底部面板">
          <p class="mb-4 text-grey-600">用於確認、篩選、更多選項。</p>
          <BaseButton block @click="sheet = false">知道了</BaseButton>
        </BaseSheet>
        <EmptyState title="沒有資料" description="換個關鍵字試試" />
        <SkeletonBlock :lines="3" />
      </section>

      <section>
        <SectionTitle title="OsmMap" />
        <OsmMap :markers="[{ lat: 25.0375, lng: 121.5637, label: '臺北市政府' }]" />
      </section>
    </div>
  </PageContainer>
</template>
