import { beforeEach, describe, expect, it } from 'vitest'
import { addRecent, clearRecent, recent } from '@/modules/recent'

describe('recent history (logic + data)', () => {
  beforeEach(() => clearRecent())

  it('puts the newest first and removes duplicates', () => {
    addRecent('A', '/a')
    addRecent('B', '/b')
    addRecent('A again', '/a')
    expect(recent.value.map((r) => r.path)).toEqual(['/a', '/b'])
    expect(recent.value[0]!.title).toBe('A again')
  })

  it('keeps at most 8 entries and persists them on the device', () => {
    for (let i = 0; i < 12; i++) addRecent(`#${i}`, `/${i}`)
    expect(recent.value).toHaveLength(8)
    expect(JSON.parse(localStorage.getItem('townpass.recent.v1')!)).toHaveLength(8)
  })
})
