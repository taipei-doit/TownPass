/**
 * DATA LAYER - platform adapter: on-device key/value storage.
 * localStorage can be missing or throw (private mode, locked-down WebView), so every
 * access is guarded and callers always get a usable value.
 */
const __PREFIX = 'townpass.'

export function readJson<T>(key: string, fallback: T): T {
  try {
    const raw = localStorage.getItem(__PREFIX + key)
    return raw === null ? fallback : (JSON.parse(raw) as T)
  } catch {
    return fallback
  }
}

export function writeJson(key: string, value: unknown): void {
  try {
    if (value === undefined || value === null) localStorage.removeItem(__PREFIX + key)
    else localStorage.setItem(__PREFIX + key, JSON.stringify(value))
  } catch {
    /* storage unavailable - value lives in memory only */
  }
}
