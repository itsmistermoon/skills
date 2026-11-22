import { test, expect } from 'bun:test'
import { mkdtempSync, readFileSync, rmSync } from 'fs'
import { tmpdir } from 'os'
import { join } from 'path'
import { logMessage } from './message-log'

test('registra mensajes entrantes y salientes con fecha y hora local', () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-log-'))
  try {
    const date = new Date(2026, 10, 22, 1, 2, 3)
    logMessage(dir, 'entra', 'skills', 'hola\nmundo', date)
    logMessage(dir, 'sale', 'General', 'respuesta', date)
    expect(readFileSync(join(dir, 'log', '2026-11-22.md'), 'utf8')).toBe(
      '- 01:02:03 | entra | skills | hola\\nmundo\n- 01:02:03 | sale | General | respuesta\n',
    )
  } finally { rmSync(dir, { recursive: true, force: true }) }
})

test('oculta el token configurado y credenciales etiquetadas', () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-log-'))
  try {
    logMessage(dir, 'entra', 'General', 'token=abc123 clave 123:botsecret {"password": "example-password"}', new Date(2026, 10, 22), ['123:botsecret'])
    const log = readFileSync(join(dir, 'log', '2026-11-22.md'), 'utf8')
    expect(log).not.toContain('abc123')
    expect(log).not.toContain('123:botsecret')
    expect(log).not.toContain('example-password')
  } finally { rmSync(dir, { recursive: true, force: true }) }
})
