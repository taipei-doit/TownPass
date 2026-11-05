import { fileURLToPath, URL } from 'node:url'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  // GitHub Pages serves the site under /<repo>/ ; CI sets VITE_BASE, local dev uses /
  base: process.env.VITE_BASE ?? '/',
  plugins: [vue(), tailwindcss()],
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
  // host: true lets the Android emulator reach the dev server at http://10.0.2.2:5173
  server: { host: true, port: 5173 },
  // Unit tests for the logic + data layers (pages are checked on the emulator, see docs/system/07-testing.md)
  test: { environment: 'happy-dom', include: ['tests/**/*.test.ts'] },
})
