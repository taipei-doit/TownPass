/**
 * Bridge between this web microservice and the TownPass Flutter app.
 *
 * Inside the app, the page runs in a WebView that injects `flutterObject`
 * (see lib/util/web_message_handler/ in the app). Messages are JSON strings:
 *   web -> app : { name, data }
 *   app -> web : { name, data }   (reply uses the same name)
 *
 * Outside the app (plain browser during development) `flutterObject` doesn't exist,
 * so `request` falls back to the mocks below. Keep those mocks realistic.
 *
 * Message names the app understands today:
 *   userinfo, location, deviceinfo, launch_map, phone_call, 1999agree, open_link, notify, qr_code_scan
 * Adding a new one = add a TPWebMessageHandler in the app AND list it in docs/bridge.md.
 */

type FlutterObject = {
  postMessage: (msg: string) => void
  addEventListener: (type: 'message', cb: (e: { data: string }) => void) => void
  removeEventListener: (type: 'message', cb: (e: { data: string }) => void) => void
}

declare global {
  interface Window {
    flutterObject?: FlutterObject
  }
}

export const isInApp = (): boolean => typeof window !== 'undefined' && !!window.flutterObject

const mocks: Record<string, unknown> = {
  userinfo: {
    id: 'mock-user',
    realName: '王小明',
    email: 'demo@example.com',
  },
  location: { latitude: 25.0375, longitude: 121.5637 }, // Taipei City Hall
  deviceinfo: { platform: 'browser' },
}

/** Fire-and-forget message to the app. No-op in a plain browser. */
export function send(name: string, data: unknown = null): void {
  window.flutterObject?.postMessage(JSON.stringify({ name, data }))
}

/** Send a message and wait for the app's reply with the same name. */
export function request<T = unknown>(name: string, data: unknown = null, timeoutMs = 10_000): Promise<T> {
  const fo = window.flutterObject
  if (!fo) {
    if (name in mocks) return Promise.resolve(mocks[name] as T)
    return Promise.reject(new Error(`[bridge] not in app and no mock for "${name}"`))
  }

  return new Promise<T>((resolve, reject) => {
    const onMessage = (e: { data: string }) => {
      let msg: { name?: string; data?: unknown }
      try {
        msg = JSON.parse(e.data)
      } catch {
        return
      }
      if (msg.name !== name) return
      cleanup()
      resolve(msg.data as T)
    }
    const timer = setTimeout(() => {
      cleanup()
      reject(new Error(`[bridge] "${name}" timed out after ${timeoutMs}ms`))
    }, timeoutMs)
    const cleanup = () => {
      clearTimeout(timer)
      fo.removeEventListener('message', onMessage)
    }

    fo.addEventListener('message', onMessage)
    fo.postMessage(JSON.stringify({ name, data }))
  })
}
