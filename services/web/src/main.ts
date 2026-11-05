import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './app/router'
import { ensureSession } from './modules/session'
import './style.css'

createApp(App).use(createPinia()).use(router).mount('#app')

// Log in to our backend with the TownPass identity in the background.
// The UI never waits for it: without a backend the app keeps working on mock data.
void ensureSession()
