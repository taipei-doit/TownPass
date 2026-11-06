/**
 * Service worker: makes the site work with no network (the competition may test with the network
 * off). Same-site requests only; backend calls and model downloads are never touched.
 *   sync       stores every file listed in precache-manifest.json. Runs on install and on every
 *              page load, because a new deploy doesn't change this file and so doesn't reinstall it
 *   /assets/   cache first: built files have hashed names and never change
 *   other      network first, cached copy when offline
 *   *.pmtiles  served from a stored full copy, honouring the Range requests the map library sends
 */
const APP_CACHE = 'townpass-app-v1'
const MAP_CACHE = 'townpass-map-v1'
const BASE = new URL('./', self.location).pathname
const BASEMAP = `${BASE}maps/taipei.pmtiles`
// Hosts send `Vary` headers (Origin, Accept-Encoding) that would make stored files look like misses
const MATCH = { ignoreVary: true }

self.addEventListener('install', (event) => {
  event.waitUntil(sync().finally(() => self.skipWaiting()))
})

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((names) =>
        Promise.all(names.filter((n) => n.startsWith('townpass-') && ![APP_CACHE, MAP_CACHE].includes(n)).map((n) => caches.delete(n))),
      )
      .then(() => self.clients.claim()),
  )
})

self.addEventListener('message', (event) => {
  if (event.data?.type !== 'sync') return
  event.waitUntil(Promise.allSettled([sync(), event.data.basemap ? cacheBasemap() : null]))
})

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url)
  if (event.request.method !== 'GET' || url.origin !== self.location.origin) return
  if (url.pathname.endsWith('.pmtiles')) event.respondWith(servePmtiles(event.request))
  else if (event.request.mode === 'navigate') event.respondWith(networkFirst(event.request, BASE))
  else if (url.pathname.startsWith(`${BASE}assets/`)) event.respondWith(cacheFirst(event.request))
  else event.respondWith(networkFirst(event.request, event.request))
})

/** Offline, the manifest can't be fetched: what is already stored stays as it is. */
async function sync() {
  const cache = await caches.open(APP_CACHE)
  const manifest = await fetch(`${BASE}precache-manifest.json`, { cache: 'no-cache' }).then((r) => r.json())
  const wanted = new Set(manifest.map((file) => new URL(BASE + file, self.location).href))
  for (const request of await cache.keys()) {
    if (new URL(request.url).pathname.startsWith(`${BASE}assets/`) && !wanted.has(request.url)) await cache.delete(request)
  }
  // one failed file must not stop the others
  await Promise.allSettled(
    [BASE, ...wanted].map(async (url) => {
      if (url === BASE || !(await cache.match(url, MATCH))) await cache.add(url)
    }),
  )
}

async function networkFirst(request, cacheKey) {
  const cache = await caches.open(APP_CACHE)
  try {
    const response = await fetch(request)
    if (response.ok) await cache.put(cacheKey, response.clone())
    return response
  } catch {
    return (await cache.match(cacheKey, MATCH)) ?? Response.error()
  }
}

async function cacheFirst(request) {
  const cache = await caches.open(APP_CACHE)
  const hit = await cache.match(request, MATCH)
  if (hit) return hit
  const response = await fetch(request)
  if (response.ok) await cache.put(request, response.clone())
  return response
}

async function cacheBasemap() {
  const cache = await caches.open(MAP_CACHE)
  if (await cache.match(BASEMAP)) return
  const response = await fetch(BASEMAP)
  if (response.ok) await cache.put(BASEMAP, response)
}

async function servePmtiles(request) {
  const stored = await (await caches.open(MAP_CACHE)).match(BASEMAP)
  if (!stored) return fetch(request)
  const range = /bytes=(\d+)-(\d*)/.exec(request.headers.get('range') ?? '')
  if (!range) return stored
  const file = await stored.blob()
  const start = Number(range[1])
  const end = range[2] ? Math.min(Number(range[2]), file.size - 1) : file.size - 1
  return new Response(file.slice(start, end + 1), {
    status: 206,
    headers: {
      'Content-Type': 'application/octet-stream',
      'Content-Range': `bytes ${start}-${end}/${file.size}`,
      'Content-Length': String(end - start + 1),
      'Accept-Ranges': 'bytes',
    },
  })
}
