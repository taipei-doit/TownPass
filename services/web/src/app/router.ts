// Wiring: app routes + every feature's routes (auto-discovered).
import { createRouter, createWebHashHistory } from 'vue-router'
import { featureRoutes, getFeature } from '@/framework'
import { addRecent } from '@/modules/recent'
import HomePage from '@/pages/HomePage.vue'

// Hash history: works on GitHub Pages and inside the app WebView without server rewrites.
const router = createRouter({
  history: createWebHashHistory(),
  scrollBehavior: () => ({ top: 0 }),
  routes: [
    { path: '/', name: 'home', component: HomePage },
    { path: '/sources', name: 'sources', component: () => import('@/pages/SourcesPage.vue') },
    { path: '/dev/ui', name: 'ui-gallery', component: () => import('@/pages/UiGalleryPage.vue') },
    ...featureRoutes,
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

// Every page visited inside a feature goes into 近期使用.
// A route can set a nicer label with meta { recentTitle: (route) => string }.
router.afterEach((to) => {
  const featureId = to.meta.featureId as string | undefined
  if (!featureId) return
  const f = getFeature(featureId)
  const custom = to.meta.recentTitle as ((r: typeof to) => string) | undefined
  addRecent(custom ? custom(to) : (f?.title ?? to.fullPath), to.fullPath)
})

export default router
