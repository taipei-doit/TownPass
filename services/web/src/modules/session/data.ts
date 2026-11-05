/**
 * DATA LAYER - session: who the user is (from the TownPass app) and our backend token.
 *
 * Privacy: the app's account object contains the national ID number, phone and address.
 * We read ONLY `id` and `realName` and never send anything else to our backend.
 */
import { request } from '@/platform/bridge'
import { api, setAuthToken } from '@/platform/http'
import { readJson, writeJson } from '@/platform/storage'

export interface SessionUser {
  id: number
  townpass_id: string
  name: string
}
export interface TownPassProfile {
  townpass_id: string
  name: string
}

const __KEY = 'session.v1'

/** Minimal profile from the app (or the browser mock). Null when the app gives nothing. */
export async function readAppProfile(): Promise<TownPassProfile | null> {
  const acc = await request<{ id?: string; realName?: string } | []>('userinfo').catch(() => null)
  if (!acc || Array.isArray(acc) || !acc.id) return null
  return { townpass_id: acc.id, name: acc.realName ?? '' }
}

export async function loginOnBackend(profile: TownPassProfile): Promise<{ token: string; user: SessionUser }> {
  return api('/auth/login', { method: 'POST', body: JSON.stringify(profile) })
}

export async function fetchMe(): Promise<SessionUser> {
  return api('/auth/me')
}

export function loadToken(): string | null {
  return readJson<string | null>(__KEY, null)
}

export function storeToken(token: string | null): void {
  writeJson(__KEY, token)
  setAuthToken(token)
}
