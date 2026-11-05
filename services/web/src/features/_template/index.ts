/**
 * New feature template (wiring only). Copy the whole folder:
 *   cp -r src/features/_template src/features/<your-id>
 * then set `id` (= folder name) and `code` (component ID prefix), and rename XX in ui/ files.
 * It shows up on the home screen, routes live at /#/f/<your-id>/..., searchItems feed the chat box.
 * (Folders starting with "_" are ignored by the registry, so this template never shows.)
 *
 * Layers - each file only talks to the layer below it:
 *   ui/     presentation: pages (XX-Pnn) + components (XX-Cnn), composed from '@/ui'
 *   logic/  public interface: composables / use-cases; helpers prefixed __ stay private
 *   data/   backend calls (+ mock fallback); helpers prefixed __ stay private
 */
import { Sparkles } from 'lucide-vue-next'
import { defineFeature } from '@/framework'
import { templateSearchItems } from './logic'

export default defineFeature({
  id: '_template', // <- must equal the folder name
  code: 'XX', // <- 2-4 capital letters, unique across features
  title: '新功能',
  description: '一句話說明這個功能',
  icon: Sparkles, // any icon from https://lucide.dev/icons
  keywords: [],

  routes: [{ path: '', name: 'home', component: () => import('./ui/TemplatePage.vue') }],

  quickActions: [],
  searchItems: templateSearchItems,
  sources: [],
})
