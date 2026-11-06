/**
 * LOGIC LAYER - session lifecycle.
 * - profile: who the app says the user is (works offline / without backend)
 * - user:    the backend account, available once /auth/login succeeded
 * ADD-ON auth: a feature calls `requireUser()` before a protected action.
 */
import { ref } from 'vue'
import { fetchMe, loadToken, loginOnBackend, readAppProfile, storeToken, type SessionUser, type TownPassProfile } from './data'

export type { SessionUser, TownPassProfile }

export const profile = ref<TownPassProfile | null>(null)
export const user = ref<SessionUser | null>(null)

let __pending: Promise<SessionUser | null> | null = null

/** Idempotent: safe to call from anywhere, runs the login flow at most once at a time. */
export function ensureSession(): Promise<SessionUser | null> {
  __pending ??= __login().finally(() => (__pending = null))
  return __pending
}

/** For protected actions: resolves to the user or throws a readable error. */
export async function requireUser(): Promise<SessionUser> {
  const u = user.value ?? (await ensureSession())
  if (!u) throw new Error('需要登入台北通才能使用這個功能')
  return u
}

export function signOut(): void {
  storeToken(null)
  user.value = null
}

async function __login(): Promise<SessionUser | null> {
  profile.value ??= await readAppProfile()
  if (await __resumeStoredToken()) return user.value
  if (!profile.value) return null
  try {
    const res = await loginOnBackend(profile.value)
    storeToken(res.token)
    user.value = res.user
  } catch {
    user.value = null // backend unreachable: app still works with profile + mock data
  }
  return user.value
}

async function __resumeStoredToken(): Promise<boolean> {
  const token = loadToken()
  if (!token) return false
  storeToken(token)
  try {
    const me = await fetchMe()
    // token belongs to a different TownPass account (e.g. account switched in the app)
    if (profile.value && me.townpass_id !== profile.value.townpass_id) throw new Error('account changed')
    user.value = me
    return true
  } catch {
    storeToken(null)
    return false
  }
}
