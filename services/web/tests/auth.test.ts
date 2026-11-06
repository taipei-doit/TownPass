import { afterEach, describe, expect, it, vi } from 'vitest'

// Fresh module state per test (session keeps the user in module-level refs)
async function freshSession() {
  vi.resetModules()
  localStorage.clear()
  return import('@/addons/auth')
}

const okJson = (body: unknown) => new Response(JSON.stringify(body), { status: 200, headers: { 'Content-Type': 'application/json' } })

describe('session (login flow + privacy)', () => {
  afterEach(() => vi.unstubAllGlobals())

  it('sends ONLY townpass_id and name to the backend - never ID number, phone or address', async () => {
    const fetchMock = vi.fn().mockResolvedValue(okJson({ token: 't.x', user: { id: 1, townpass_id: 'mock-user', name: '王小明' } }))
    vi.stubGlobal('fetch', fetchMock)
    // the app's account object carries sensitive fields - simulate it
    window.flutterObject = {
      postMessage: (raw: string) => {
        const { name } = JSON.parse(raw)
        queueMicrotask(() => __listener?.({ data: JSON.stringify({ name, data: { id: 'tp-1', realName: '王小明', idNo: 'A123456789', phoneNo: '0912345678' } }) }))
      },
      addEventListener: (_t, cb) => (__listener = cb),
      removeEventListener: () => (__listener = undefined),
    }
    const s = await freshSession()
    await s.ensureSession()

    const [url, init] = fetchMock.mock.calls[0]!
    expect(String(url)).toMatch(/\/auth\/login$/)
    expect(JSON.parse(init.body)).toEqual({ townpass_id: 'tp-1', name: '王小明' })
    expect(s.user.value?.id).toBe(1)
    delete window.flutterObject
  })

  it('keeps working without a backend (user stays null, no throw)', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('offline')))
    const s = await freshSession()
    await expect(s.ensureSession()).resolves.toBeNull()
    expect(s.profile.value?.name).toBe('王小明') // browser mock profile still available
    await expect(s.requireUser()).rejects.toThrow('需要登入')
  })

  it('drops a stored token that the backend rejects', async () => {
    localStorage.setItem('townpass.session.v1', JSON.stringify('expired.token'))
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(new Response('{}', { status: 401 })) // /auth/me with old token
      .mockResolvedValueOnce(okJson({ token: 'new.token', user: { id: 2, townpass_id: 'mock-user', name: '王小明' } }))
    vi.stubGlobal('fetch', fetchMock)
    vi.resetModules()
    const s = await import('@/addons/auth')
    await s.ensureSession()
    expect(JSON.parse(localStorage.getItem('townpass.session.v1')!)).toBe('new.token')
  })
})

let __listener: ((e: { data: string }) => void) | undefined
