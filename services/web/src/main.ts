import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './app/router'
import { enableOfflineUse } from './modules/env'
import './style.css'

createApp(App).use(createPinia()).use(router).mount('#app')
enableOfflineUse()
