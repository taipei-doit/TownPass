/**
 * AI 問答, ready to switch on. Folders starting with "_" are ignored, so this is OFF.
 * Switch on (docs/system/09-addons.md §2):
 *   Copy-Item -Recurse services/web/src/features/_ai services/web/src/features/ai
 *   then set id: 'ai' below in the copy, and list your documents in searchItems.
 * The copy adds a lab page (hardware, model download, disclosure) and lets the home chat box answer
 * from retrieval once the models are loaded. Until then the chat box keeps its rules and search.
 */
import { Sparkles } from 'lucide-vue-next'
import { defineFeature } from '@/framework'
import { createAgent } from '@/addons/agent'
import { RagLabPage } from '@/addons/rag'

export default defineFeature({
  id: '_ai', // <- must equal the folder name: 'ai'
  code: 'AI',
  title: 'AI 問答',
  description: '在手機上執行，只根據 App 內資料回答',
  icon: Sparkles,
  keywords: ['AI', '問答'],
  routes: [{ path: '', name: 'lab', component: RagLabPage }],
  assistant: createAgent(),
  // Other features' searchItems are indexed automatically. For documents built with pnpm rag:build:
  //   searchItems: () => collectionItems(`${import.meta.env.BASE_URL}rag/notices.json`, (doc) => featureRoute('ai', 'lab'))
  sources: [],
})
