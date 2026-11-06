/** LOGIC LAYER - runtime environment facts that presentation may need. */
import { ref } from 'vue'
import { isInApp, request, send } from '@/platform/bridge'
import { registerOfflineWorker } from '@/platform/offline'

/** True when running inside the TownPass app WebView (false in a normal browser). */
export const inApp: boolean = isInApp()

/**
 * Display name of the TownPass app user, for greetings only. No login involved.
 * Privacy: only `realName` is read from the app's account object (it also carries
 * the national ID number, phone and address - never read those).
 */
export const appUserName = ref<string>('')

export async function loadAppUserName(): Promise<void> {
  if (appUserName.value) return
  const acc = await request<{ realName?: string } | []>('userinfo').catch(() => null)
  appUserName.value = acc && !Array.isArray(acc) ? (acc.realName ?? '') : ''
}

/** Ask the app to open the phone's map app at a point. No-op in a browser. */
export function openMap(lat: number, lng: number, label: string): void {
  send('launch_map', `geo:${lat},${lng}?q=${encodeURIComponent(label)}`)
}

/** Android WebView has no speechSynthesis, so inside the app speech goes through the bridge. */
export const canSpeak: boolean = inApp || (typeof window !== 'undefined' && 'speechSynthesis' in window)

/** Read text aloud with the phone's own voice; works offline when a zh-TW voice is installed. */
export function speak(text: string): void {
  if (inApp) {
    send('tts_speak', { text, lang: 'zh-TW' })
  } else if (canSpeak) {
    speechSynthesis.cancel()
    const utterance = new SpeechSynthesisUtterance(text)
    utterance.lang = 'zh-TW'
    speechSynthesis.speak(utterance)
  }
}

export function stopSpeaking(): void {
  if (inApp) send('tts_stop')
  else if (canSpeak) speechSynthesis.cancel()
}

/** Keeps the site, its images and the offline map usable with no network. Production builds only. */
export function enableOfflineUse(): void {
  if (import.meta.env.PROD) void registerOfflineWorker(import.meta.env.BASE_URL)
}

/** Native share sheet when available, otherwise copy the link. Returns what happened. */
export async function shareLink(title: string, text: string, url = location.href): Promise<'shared' | 'copied' | 'cancelled'> {
  try {
    if (navigator.share) {
      await navigator.share({ title, text, url })
      return 'shared'
    }
    await navigator.clipboard.writeText(url)
    return 'copied'
  } catch {
    return 'cancelled'
  }
}
