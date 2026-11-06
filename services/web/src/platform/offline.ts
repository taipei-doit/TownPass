/**
 * DATA LAYER - platform adapter: registers the service worker (public/sw.js) and asks it to store
 * this deploy's files. The basemap is large, so it is only fetched ahead of time on a connection
 * that isn't metered.
 */
type __Connection = { saveData?: boolean; type?: string }

/** Large downloads wait for a connection that isn't metered. Unknown connections count as fine. */
export function isUnmetered(): boolean {
  const connection = (navigator as Navigator & { connection?: __Connection }).connection
  return !connection?.saveData && connection?.type !== 'cellular'
}

export async function registerOfflineWorker(base: string): Promise<void> {
  if (!('serviceWorker' in navigator)) return
  try {
    const registration = await navigator.serviceWorker.register(`${base}sw.js`, { scope: base })
    const worker = registration.active ?? (await navigator.serviceWorker.ready).active
    worker?.postMessage({ type: 'sync', basemap: isUnmetered() })
  } catch (err) {
    console.warn('[offline] service worker unavailable', err)
  }
}
