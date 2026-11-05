/**
 * New feature template. Copy this whole folder:
 *   cp -r src/features/_template src/features/<your-id>
 * then change `id` below to the folder name. That's it - it shows up on the home screen,
 * its routes live at /#/f/<your-id>/..., and searchItems become chat-box answers.
 * (Folders starting with "_" are ignored by the registry, so this template never shows.)
 */
import { Sparkles } from 'lucide-vue-next'
import { defineFeature } from '@/core/feature'

export default defineFeature({
  id: '_template', // <- must equal the folder name
  title: '新功能',
  description: '一句話說明這個功能',
  icon: Sparkles, // any icon from https://lucide.dev/icons
  keywords: [],

  routes: [{ path: '', name: 'home', component: () => import('./TemplatePage.vue') }],

  quickActions: [],
  searchItems: () => [],
  sources: [],
})
