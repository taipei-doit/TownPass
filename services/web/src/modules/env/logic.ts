/** LOGIC LAYER - runtime environment facts that presentation may need. */
import { isInApp, send } from '@/platform/bridge'

/** True when running inside the TownPass app WebView (false in a normal browser). */
export const inApp: boolean = isInApp()

/** Ask the app to open the phone's map app at a point. No-op in a browser. */
export function openMap(lat: number, lng: number, label: string): void {
  send('launch_map', `geo:${lat},${lng}?q=${encodeURIComponent(label)}`)
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
