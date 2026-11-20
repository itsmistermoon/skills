// OpenCode plugin: registers the skills that .claude-plugin/plugin.json lists,
// so one manifest serves Claude Code, Codex, and OpenCode. The same file sits
// at the root of every plugin in this marketplace.
import { Plugin, Skill } from "@opencode/plugin"
import { readFileSync } from "node:fs"
import { basename, dirname, join, resolve } from "node:path"
import { fileURLToPath } from "node:url"

const root = dirname(fileURLToPath(import.meta.url))
const manifest = JSON.parse(readFileSync(join(root, ".claude-plugin/plugin.json"), "utf8"))

// Splits "---\nkey: value\n---\nbody" into flat string fields and the body.
function parse(text) {
  const match = text.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/)
  if (!match) return { fields: {}, body: text }
  const fields = {}
  for (const line of match[1].split("\n")) {
    const pair = line.match(/^([\w-]+):\s*(.*)$/)
    if (pair) fields[pair[1]] = pair[2].replace(/^"(.*)"$/, "$1").replace(/\\"/g, '"')
  }
  return { fields, body: match[2] }
}

function load(rel) {
  const path = resolve(root, rel, "SKILL.md")
  const { fields, body } = parse(readFileSync(path, "utf8"))
  const id = basename(resolve(root, rel))
  return {
    id: Skill.ID.make(id),
    name: Skill.Name.make(fields.name || id),
    description: fields.description,
    autoinvoke: fields["disable-model-invocation"] !== "true",
    path: Skill.Info.fields.path.make(path),
    content: body,
  }
}

export default Plugin.define({
  id: manifest.name,
  async setup(ctx) {
    const skills = manifest.skills.map(load)
    await ctx.skill.transform((editor) => {
      for (const skill of skills) {
        if (editor.get(skill.id)) editor.remove(skill.id)
        editor.add(skill)
      }
    })
  },
})
