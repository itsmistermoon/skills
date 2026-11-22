import { test, expect } from 'bun:test'
import { mkdtempSync, readdirSync, rmSync } from 'fs'
import { tmpdir } from 'os'
import { join } from 'path'

test('una segunda sesión informa la clave duplicada y no reclama el canal', async () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-session-'))
  const env = { ...process.env, TELEGRAM_STATE_DIR: dir, TELEGRAM_BOT_TOKEN: '123:fake', CLAUDE_PROJECT_DIR: dir }
  const start = () => Bun.spawn(['bun', 'server.ts'], { cwd: import.meta.dir, env, stdin: 'pipe', stdout: 'pipe', stderr: 'pipe' })
  const first = start()
  let second: ReturnType<typeof start> | undefined
  try {
    const claims = join(dir, 'claims', dir.split('/').pop()!)
    for (let i = 0; i < 100; i++) {
      try { if (readdirSync(claims).length) break } catch {}
      await Bun.sleep(30)
    }
    expect(readdirSync(claims)).toEqual([String(first.pid)])
    second = start()
    second.stdin.write(JSON.stringify({ jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2025-03-26', capabilities: {}, clientInfo: { name: 'test', version: '1' } } }) + '\n')
    await second.stdin.flush()
    const output = await second.stdout.getReader().read()
    const response = JSON.parse(new TextDecoder().decode(output.value))
    const warning = `otra sesión ya atiende ${dir.split('/').pop()}; esta no recibirá mensajes`
    expect(response.result.instructions).toContain(warning)
    const stderr = await second.stderr.getReader().read()
    expect(new TextDecoder().decode(stderr.value)).toContain(warning)
    expect(readdirSync(claims)).toEqual([String(first.pid)])
  } finally {
    first.kill()
    second?.kill()
    await first.exited
    if (second) await second.exited
    rmSync(dir, { recursive: true, force: true })
  }
})
