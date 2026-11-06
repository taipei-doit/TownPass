/**
 * DATA LAYER - platform adapter: HTTP to our backend.
 * Base URL from VITE_API_BASE. Sends a bearer token when one is set (only the optional auth add-on sets it).
 */
const __BASE = (import.meta.env.VITE_API_BASE ?? 'http://localhost:8000').replace(/\/$/, '')
let __token: string | null = null

export class HttpError extends Error {
  status: number
  constructor(status: number, message: string) {
    super(message)
    this.status = status
  }
}

/** Called by the session module only. */
export function setAuthToken(token: string | null): void {
  __token = token
}

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${__BASE}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(__token ? { Authorization: `Bearer ${__token}` } : {}),
      ...init?.headers,
    },
  })
  if (!res.ok) throw new HttpError(res.status, `${init?.method ?? 'GET'} ${path} -> ${res.status}`)
  return (res.status === 204 ? undefined : await res.json()) as T
}
