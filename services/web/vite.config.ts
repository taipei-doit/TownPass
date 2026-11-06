import { readdirSync } from 'node:fs'
import { join, relative } from 'node:path'
import { fileURLToPath, URL } from 'node:url'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'vitest/config'
import type { Plugin } from 'vite'

/** Files in public/ that the service worker must not pre-store (itself, and the large basemap it handles separately). */
const NOT_PRECACHED = /^(sw\.js$|maps\/)/

/** Lists every built and public file so the service worker (public/sw.js) can store them for offline use. */
const precacheManifest = (): Plugin => ({
  name: 'precache-manifest',
  apply: 'build',
  generateBundle(_options, bundle) {
    const publicDir = fileURLToPath(new URL('./public', import.meta.url))
    const publicFiles = readdirSync(publicDir, { recursive: true, withFileTypes: true })
      .filter((entry) => entry.isFile())
      .map((entry) => relative(publicDir, join(entry.parentPath, entry.name)).replaceAll('\\', '/'))
      .filter((file) => !NOT_PRECACHED.test(file))
    this.emitFile({
      type: 'asset',
      fileName: 'precache-manifest.json',
      source: JSON.stringify([...Object.keys(bundle).filter((f) => !f.endsWith('.map')), ...publicFiles]),
    })
  },
})

export default defineConfig({
  // GitHub Pages serves the site under /<repo>/ ; CI sets VITE_BASE, local dev uses /
  base: process.env.VITE_BASE ?? '/',
  plugins: [vue(), tailwindcss(), precacheManifest()],
  resolve: {
    alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
  },
  // host: true lets phones on the same network reach the dev server. On the emulator use
  // `adb reverse tcp:5173 tcp:5173` and http://localhost:5173: 10.0.2.2 isn't a secure context
  server: { host: true, port: 5173 },
  // Unit tests for the logic + data layers (pages are checked on the emulator, see docs/system/07-testing.md)
  test: { environment: 'happy-dom', include: ['tests/**/*.test.ts'] },
})
