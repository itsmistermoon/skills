import { randomBytes } from 'crypto'
import { mkdirSync, readFileSync, readdirSync, renameSync, rmSync, writeFileSync } from 'fs'
import { join } from 'path'

export function createRouter<T>(stateDir: string, home: string) {
  const root = join(stateDir, 'spool')
  function spool(key: string, payload: T): void {
    const dir = join(root, key)
    mkdirSync(dir, { recursive: true, mode: 0o700 })
    const name = `${Date.now()}-${randomBytes(4).toString('hex')}.json`
    writeFileSync(join(dir, `.${name}`), JSON.stringify(payload), { mode: 0o600 })
    renameSync(join(dir, `.${name}`), join(dir, name))
  }
  function route(topic: string | undefined, payload: T, live: Set<string>): void {
    spool(topic && live.has(topic) ? topic : home, payload)
  }
  function drain(key: string, live: Set<string>): T[] {
    const out: T[] = []
    const keys = [key]
    if (key === home) {
      try { for (const k of readdirSync(root)) if (k !== key && !live.has(k)) keys.push(k) } catch {}
    }
    for (const k of keys) {
      const dir = join(root, k)
      let files: string[] = []
      try { files = readdirSync(dir).filter(n => n.endsWith('.json') && !n.startsWith('.')).sort() } catch { continue }
      for (const n of files) {
        const path = join(dir, n)
        try { const payload = JSON.parse(readFileSync(path, 'utf8')) as T; rmSync(path); out.push(payload) } catch {}
      }
    }
    return out
  }
  return { spool, route, drain }
}
