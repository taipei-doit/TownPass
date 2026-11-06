import { beforeEach, describe, expect, it, vi } from 'vitest'

const bridge = vi.hoisted(() => ({ inApp: true, reply: null as unknown, sent: [] as string[] }))
const network = vi.hoisted(() => ({ unmetered: true }))

vi.mock('@/platform/bridge', () => ({
  isInApp: () => bridge.inApp,
  send: (name: string) => bridge.sent.push(name),
  request: async () => {
    if (bridge.reply === null) throw new Error('timeout')
    return bridge.reply
  },
}))
vi.mock('@/platform/offline', () => ({
  isUnmetered: () => network.unmetered,
  registerOfflineWorker: async () => {},
}))

async function env() {
  vi.resetModules()
  return import('@/modules/env')
}

describe('Chinese voice for reading aloud', () => {
  beforeEach(() => {
    bridge.inApp = true
    bridge.reply = null
    bridge.sent = []
    network.unmetered = true
  })

  it.each([
    ['on the phone', { available: true, installed: true }, 'offline-ready'],
    ['can be fetched', { available: true, installed: false }, 'needs-download'],
    ['not supported', { available: false, installed: false }, 'unavailable'],
  ])('status: %s', async (_n, reply, expected) => {
    bridge.reply = reply
    expect(await (await env()).voiceStatus()).toBe(expected)
  })

  it('an older app that never answers reports nothing instead of failing', async () => {
    expect(await (await env()).voiceStatus()).toBeNull()
  })

  it('outside the app there is nothing to report', async () => {
    bridge.inApp = false
    bridge.reply = { available: true, installed: true }
    expect(await (await env()).voiceStatus()).toBeNull()
  })

  it('startup asks the app to fetch the voice on an unmetered connection', async () => {
    ;(await env()).enableOfflineUse()
    expect(bridge.sent).toEqual(['tts_prepare'])
  })

  it('startup does not spend mobile data on the voice', async () => {
    network.unmetered = false
    ;(await env()).enableOfflineUse()
    expect(bridge.sent).toEqual([])
  })

  it('outside the app startup sends nothing', async () => {
    bridge.inApp = false
    ;(await env()).enableOfflineUse()
    expect(bridge.sent).toEqual([])
  })
})
