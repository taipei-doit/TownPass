/** LOGIC LAYER - runtime environment facts that presentation may need. */
import { ref } from 'vue'
import { isInApp, request, send } from '@/platform/bridge'
import { isUnmetered, registerOfflineWorker } from '@/platform/offline'

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

export type VoiceStatus = 'offline-ready' | 'needs-download' | 'unavailable'

/** Whether reading aloud works with no network. Null outside the app, or in an older app version. */
export async function voiceStatus(): Promise<VoiceStatus | null> {
  if (!inApp) return null
  const status = await request<{ available?: boolean; installed?: boolean }>('tts_status', null, 3000).catch(() => null)
  if (!status) return null
  if (status.installed) return 'offline-ready'
  return status.available ? 'needs-download' : 'unavailable'
}

/**
 * Keeps the site, its images, the offline map and the Chinese voice usable with no network.
 * The worker runs in production builds only; the voice download waits for an unmetered connection.
 */
export function enableOfflineUse(): void {
  if (import.meta.env.PROD) void registerOfflineWorker(import.meta.env.BASE_URL)
  if (inApp && isUnmetered()) send('tts_prepare')
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
