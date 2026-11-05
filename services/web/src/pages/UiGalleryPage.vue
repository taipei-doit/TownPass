<script setup lang="ts">
/** @component P03 UiGalleryPage — UI 元件總覽（每個元件標示編號） */
// Every UI-kit component in one page, labelled with its ID, for teammates and AI assistants. Route: /#/dev/ui
import { ref } from 'vue'
import { Bus, Lightbulb, MapPin, Phone, Search } from 'lucide-vue-next'
import {
  BaseButton,
  BaseCard,
  BaseChip,
  BaseInput,
  BaseSheet,
  BaseTag,
  ChatBubble,
  ChatComposer,
  ChatThread,
  ChipRail,
  CollapseItem,
  EmptyState,
  FeatureGrid,
  IconBadge,
  InfoTable,
  ListItem,
  NoticeList,
  OsmMap,
  PageContainer,
  RecentStrip,
  ResultCard,
  SectionTitle,
  SkeletonBlock,
  SourceNote,
  type ThreadMessage,
} from '@/ui'

const text = ref('')
const draft = ref('')
const sheet = ref(false)
const chip = ref('全部')
const swatches = ['primary', 'secondary', 'grey', 'main', 'orange']
const steps = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
const thread: ThreadMessage[] = [
  { id: 1, role: 'user', text: '附近的公園' },
  { id: 2, role: 'bot', text: '找到 1 筆：', results: [{ key: 'a', title: '範例公園', subtitle: '信義區', tags: ['免費'], icon: MapPin, to: '/' }] },
]
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

      <h2 class="border-b border-grey-100 pb-1 text-sm font-bold tracking-wide text-grey-400">ATOMS</h2>
      <section class="space-y-2">
        <SectionTitle title="A01 BaseButton" />
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
        <SectionTitle title="A02 BaseTag ・ A03 BaseChip" />
        <div class="mb-3 flex gap-1.5">
          <BaseTag>primary</BaseTag><BaseTag tone="secondary">secondary</BaseTag><BaseTag tone="grey">grey</BaseTag>
          <BaseTag tone="warn">warn</BaseTag><BaseTag tone="success">success</BaseTag>
        </div>
        <div class="flex gap-2">
          <BaseChip v-for="c in ['全部', '附近', '免費']" :key="c" :active="chip === c" @click="chip = c">{{ c }}</BaseChip>
        </div>
      </section>
      <section class="space-y-3">
        <SectionTitle title="A04 BaseInput" />
        <BaseInput v-model="text" label="搜尋" placeholder="輸入關鍵字" :icon="Search" hint="提示文字" />
        <BaseInput label="錯誤狀態" error="這個欄位必填" />
        <BaseInput label="多行" multiline placeholder="意見回饋…" />
      </section>
      <section class="space-y-3">
        <SectionTitle title="A05 SkeletonBlock ・ A06 IconBadge ・ A07 SourceNote" />
        <SkeletonBlock :lines="2" />
        <div class="flex gap-2"><IconBadge :icon="Bus" /><IconBadge :icon="Lightbulb" size="sm" /></div>
        <SourceNote source="臺北資料大平台" />
      </section>

      <h2 class="border-b border-grey-100 pb-1 text-sm font-bold tracking-wide text-grey-400">MOLECULES</h2>
      <section class="space-y-3">
        <SectionTitle title="M01 BaseCard ・ M02 ListItem ・ M03 SectionTitle" />
        <BaseCard><p class="font-semibold">一般卡片</p><p class="text-sm text-grey-500">shadow-card</p></BaseCard>
        <BaseCard flat><p class="font-semibold">flat 卡片</p></BaseCard>
        <div class="divide-y divide-grey-100">
          <ListItem title="可點擊的列" subtitle="有 to 就會出現箭頭" :icon="MapPin" to="/" />
          <ListItem title="一般列" subtitle="沒有 to" :icon="Bus" />
        </div>
      </section>
      <section>
        <SectionTitle title="M04 CollapseItem ・ M05 EmptyState" />
        <CollapseItem title="開放時間" default-open>每日 06:00–22:00，除夕休館。</CollapseItem>
        <EmptyState title="沒有資料" description="換個關鍵字試試" />
      </section>
      <section class="space-y-3">
        <SectionTitle title="M06 InfoTable ・ M07 ResultCard" />
        <InfoTable :rows="[{ label: '地址', value: '臺北市信義區' }, { label: '電話', value: '1999' }]" />
        <ResultCard title="範例公園" subtitle="信義區・公園" :tags="['免費']" :icon="MapPin" to="/" />
      </section>
      <section class="space-y-2">
        <SectionTitle title="M08 ChatBubble ・ M09 ChipRail" />
        <ChatBubble role="user">使用者的問題</ChatBubble>
        <ChatBubble role="bot">系統的回覆</ChatBubble>
        <ChipRail><BaseChip v-for="n in 8" :key="n">選項 {{ n }}</BaseChip></ChipRail>
      </section>

      <h2 class="border-b border-grey-100 pb-1 text-sm font-bold tracking-wide text-grey-400">ORGANISMS</h2>
      <section class="space-y-3">
        <SectionTitle title="O01 BaseSheet" />
        <BaseButton variant="outline" :icon="Phone" @click="sheet = true">開啟 BaseSheet</BaseButton>
        <BaseSheet v-model:open="sheet" title="底部面板">
          <p class="mb-4 text-grey-600">用於確認、篩選、更多選項。</p>
          <BaseButton block @click="sheet = false">知道了</BaseButton>
        </BaseSheet>
      </section>
      <section>
        <SectionTitle title="O02 OsmMap" />
        <OsmMap :markers="[{ lat: 25.0375, lng: 121.5637, label: '臺北市政府' }]" />
      </section>
      <NoticeList :notices="[{ title: 'O03 NoticeList', body: '第一項預設展開' }, { title: '第二項', body: '內容' }]" />
      <section>
        <SectionTitle title="O04 ChatComposer" />
        <ChatComposer v-model="draft" :quick-actions="[{ label: '找公園' }, { label: '找圖書館' }]" />
      </section>
      <section>
        <SectionTitle title="O05 ChatThread" />
        <ChatThread :messages="thread" />
      </section>
      <FeatureGrid title="O06 FeatureGrid" :items="[{ key: 'a', title: '功能 A', description: '說明', icon: MapPin, to: '/' }, { key: 'b', title: '功能 B', description: '說明', icon: Bus, to: '/' }]" />
      <section>
        <p class="mb-1 text-xs text-grey-400">O07 RecentStrip</p>
        <RecentStrip :items="[{ title: '範例公園', path: '/' }, { title: '圖書館', path: '/' }]" />
      </section>

      <h2 class="border-b border-grey-100 pb-1 text-sm font-bold tracking-wide text-grey-400">TEMPLATES</h2>
      <p class="text-sm text-grey-500">T01 PageContainer（這一頁本身）・T02 DetailPage（見範例功能的詳細頁）</p>
    </div>
  </PageContainer>
</template>
