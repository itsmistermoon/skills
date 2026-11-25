# skills

Repository of Claude skills for the captain: the versioned source of truth, from which they are synced to the global install (`~/.agents/skills/`).

## Structure

- `skills/<group>/README.md`: lists the group's skills with links and short descriptions.
- `skills/<group>/<name>/SKILL.md`: each skill.
- Current groups: `branding` (Imaquinaria identity), `misc` (general use), `mission-control-center` (`mcc` session skills), and `wiki-radiant` (personal knowledge base).

## Conventions

- Each skill has a required `SKILL.md` (frontmatter `name` + `description`).
- The frontmatter `name` must match the folder name.
- Each group has its own `README.md`; when adding, moving, or removing a skill, update its group's README and the root README.
- Brand binary assets go in `assets/`; long reference documentation goes in `references/`, one file per topic.
- `wiki-radiant` keeps its repo structure (scripts, templates, tests): its skills depend on those files. Its contribution guide is `skills/wiki-radiant/AGENTS.md`.
- `.claude-plugin/` (root) contains `marketplace.json` and `plugin.json`; the `plugin.json` paths point to the skills of each group distributed as a plugin. When adding or removing a radiant skill, update that list. `.github/workflows/` (root) is the only place GitHub reads workflows from.
- OpenCode loads each plugin through a `package.json` and `opencode.js` beside its `.claude-plugin/plugin.json` (the repo root for `wiki-radiant`). `opencode.js` reads the skill list from that manifest, so the copies stay identical: edit one, copy it to the other.

## Pruebas

- El repo no usa GitHub Actions: no gasta minutos.
- Antes de cada push, corre `scripts/check` en local; con todo en verde, fusiona directo a `main`.
