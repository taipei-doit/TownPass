import { createRouter, createWebHashHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'

// Hash history: works on GitHub Pages and inside the app WebView without server rewrites.
export default createRouter({
  history: createWebHashHistory(),
  routes: [{ path: '/', name: 'home', component: HomeView }],
})
