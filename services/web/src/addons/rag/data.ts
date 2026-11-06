/**
 * DATA LAYER - add-on rag: storage for vectors and pre-built document collections.
 * Vectors live in the Origin Private File System: each is about 3 KB as JSON, so a few thousand
 * chunks would overflow localStorage's usual 5 MB limit. Without OPFS they stay in memory.
 */
const __DIR = 'townpass-rag'

export async function loadVectors(key: string): Promise<Record<string, number[]>> {
  try {
    const dir = await (await navigator.storage.getDirectory()).getDirectoryHandle(__DIR, { create: true })
    const file = await (await dir.getFileHandle(__fileName(key))).getFile()
    return JSON.parse(await file.text()) as Record<string, number[]>
  } catch {
    return {} // first run, or no OPFS
  }
}

export async function saveVectors(key: string, vectors: Record<string, number[]>): Promise<void> {
  try {
    const dir = await (await navigator.storage.getDirectory()).getDirectoryHandle(__DIR, { create: true })
    const writable = await (await dir.getFileHandle(__fileName(key), { create: true })).createWritable()
    await writable.write(JSON.stringify(vectors))
    await writable.close()
  } catch {
    /* no OPFS: vectors are recalculated on the next run */
  }
}

/** A collection built by `pnpm rag:build`, served from the site's own files. */
export async function fetchCollection<T>(url: string): Promise<T> {
  const response = await fetch(url)
  if (!response.ok) throw new Error(`cannot load ${url}: HTTP ${response.status}`)
  return (await response.json()) as T
}

function __fileName(key: string): string {
  return `${key.replace(/[^a-zA-Z0-9._-]+/g, '~')}.json`
}
