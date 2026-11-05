/**
 * Auto-discovers every src/features/<id>/index.ts (folders starting with "_" are ignored,
 * e.g. _template). Add a folder -> the feature exists. Delete it -> it's gone.
 */
import type { RouteRecordRaw } from 'vue-router'
import type { Feature } from './feature'

const modules = import.meta.glob<{ default: Feature }>(['../features/*/index.ts', '!../features/_*/index.ts'], {
  eager: true,
})

export const allFeatures: Feature[] = Object.entries(modules)
  .map(([path, mod]) => {
    const folder = path.split('/').at(-2)!
    const f = mod.default
    if (f.id !== folder) console.warn(`[features] id "${f.id}" should match its folder "${folder}"`)
    return f
  })
  .sort((a, b) => (a.order ?? 100) - (b.order ?? 100) || a.title.localeCompare(b.title))

/** Features shown on the home screen and in search */
export const features = allFeatures.filter((f) => !f.hidden)

export const getFeature = (id: string) => allFeatures.find((f) => f.id === id)

function prefixRoute(featureId: string, r: RouteRecordRaw): RouteRecordRaw {
  return {
    ...r,
    path: r.path.startsWith('/') ? r.path : `/f/${featureId}/${r.path}`.replace(/\/$/, ''),
    name: r.name ? `${featureId}.${String(r.name)}` : undefined,
    meta: { ...r.meta, featureId },
  } as RouteRecordRaw
}

export const featureRoutes: RouteRecordRaw[] = allFeatures.flatMap((f) => f.routes.map((r) => prefixRoute(f.id, r)))

/** Entry path of a feature (its first route) */
export const featureEntry = (f: Feature) => `/f/${f.id}/${f.routes[0]?.path ?? ''}`.replace(/\/$/, '')
