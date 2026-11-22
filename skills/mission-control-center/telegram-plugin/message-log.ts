import { appendFileSync, mkdirSync } from 'fs'
import { join } from 'path'

export function logMessage(stateDir: string, direction: 'entra' | 'sale', topic: string, text: string, date = new Date(), secrets: string[] = []): void {
  const pad = (n: number) => String(n).padStart(2, '0')
  const day = `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`
  const time = `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  const clean = (value: string) => secrets.filter(Boolean).reduce((s, secret) => s.split(secret).join('[redactado]'), value)
    .replace(/\b(token|password|secret|api[_-]?key|authorization)["']?\s*[:=]\s*(?:"[^"]*"|'[^']*'|[^\s,;}]*)/gi, '$1=[redactado]')
    .replace(/\b\d{6,}:[A-Za-z0-9_-]{20,}\b/g, '[redactado]')
    .replace(/(\/telegram:access pair\s+)\S+/gi, '$1[redactado]')
    .replace(/\r?\n/g, '\\n').replace(/\|/g, '\\|')
  const dir = join(stateDir, 'log')
  mkdirSync(dir, { recursive: true, mode: 0o700 })
  appendFileSync(join(dir, `${day}.md`), `- ${time} | ${direction} | ${clean(topic)} | ${clean(text)}\n`, { mode: 0o600 })
}
