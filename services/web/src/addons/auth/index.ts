/**
 * ADD-ON: auth (optional, OFF by default). Public interface - import only from '@/addons/auth'.
 *
 * Signs the TownPass app user in to OUR backend: reads only `id` + `realName` from the app,
 * exchanges them for a token at POST /auth/login, then every api() call sends it.
 * The framework never imports this. Turn it on only after the team has written the test plan
 * and demo script for the feature that needs login. Guide: README.md in this folder.
 *
 * Enable (web):
 *   1. In the feature that needs login, logic layer:  `await requireUser()` before the protected action
 *   2. Optionally warm it up early, e.g. in that feature's page: `onMounted(() => ensureSession())`
 * Enable (backend): see services/backend/src/townpass_backend/addons/auth/__init__.py
 * Trust model: the TownPass id is NOT cryptographically verified - demo only.
 */
export const ADDON_CODE = 'AU'

export { ensureSession, profile, requireUser, signOut, user } from './logic'
export type { SessionUser, TownPassProfile } from './logic'
