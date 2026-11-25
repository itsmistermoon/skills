import { test, expect } from 'bun:test'
import { mkdtempSync, rmSync } from 'fs'
import { tmpdir } from 'os'
import { join } from 'path'
import { createRouter } from './routing'

test('a live topic receives its message', () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-routing-'))
  try {
    const router = createRouter(dir, 'home')
    router.route('repo', { text: 'hello' }, new Set(['repo']))
    expect(router.drain('repo', new Set(['repo']))).toEqual([{ text: 'hello' }])
  } finally { rmSync(dir, { recursive: true, force: true }) }
})

test('unknown and General topics go home', () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-routing-'))
  try {
    const router = createRouter(dir, 'home')
    router.route('absent', { text: 'unknown' }, new Set(['repo']))
    router.route(undefined, { text: 'general' }, new Set(['repo']))
    expect(router.drain('home', new Set(['repo'])).map((p: any) => p.text).sort()).toEqual(['general', 'unknown'])
  } finally { rmSync(dir, { recursive: true, force: true }) }
})

test('home drains abandoned spools but leaves live sessions alone', () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-routing-'))
  try {
    const router = createRouter(dir, 'home')
    router.spool('absent', { text: 'waiting' })
    router.spool('repo', { text: 'live' })
    expect(router.drain('home', new Set(['home', 'repo']))).toEqual([{ text: 'waiting' }])
    expect(router.drain('repo', new Set(['home', 'repo']))).toEqual([{ text: 'live' }])
  } finally { rmSync(dir, { recursive: true, force: true }) }
})

test('a spooled message is delivered only once', () => {
  const dir = mkdtempSync(join(tmpdir(), 'telegram-routing-'))
  try {
    const router = createRouter(dir, 'home')
    router.spool('repo', { text: 'once' })
    expect(router.drain('repo', new Set(['repo']))).toEqual([{ text: 'once' }])
    expect(router.drain('repo', new Set(['repo']))).toEqual([])
  } finally { rmSync(dir, { recursive: true, force: true }) }
})
