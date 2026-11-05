import { createRouter, createWebHashHistory } from 'vue-router'
import { featureRoutes, getFeature } from '@/core/registry'
import { addRecent } from '@/core/recent'
import HomeView from '@/views/HomeView.vue'

// Hash history: works on GitHub Pages and inside the app WebView without server rewrites.
const router = createRouter({
  history: createWebHashHistory(),
  scrollBehavior: () => ({ top: 0 }),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/sources', name: 'sources', component: () => import('@/views/SourcesView.vue') },
    { path: '/dev/ui', name: 'ui-gallery', component: () => import('@/views/UiGallery.vue') },
    ...featureRoutes,
    { path: '/:pathMatch(.*)*', redirect: '/' },
  ],
})

// Every page visited inside a feature goes into 近期使用.
// A page can set a nicer label with route meta { recentTitle: (route) => string }.
router.afterEach((to) => {
  const featureId = to.meta.featureId as string | undefined
  if (!featureId) return
  const f = getFeature(featureId)
  const custom = to.meta.recentTitle as ((r: typeof to) => string) | undefined
  addRecent(custom ? custom(to) : (f?.title ?? to.fullPath), to.fullPath)
})

export default router
