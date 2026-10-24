# Radiant

Agent skills for personal knowledge vaults. Turn sources into linked, cited wiki pages, answer questions from that knowledge, and carry working context between sessions.

## Install

This group lives in [itsmistermoon/skills](../../README.md). Install an individual skill with `--skill wiki-query` or `--skill hot-handoff`:

```bash
npx skills add itsmistermoon/skills --skill wiki-query
```

The skill names below are unchanged.

Claude Code also supports the plugin distribution:

```text
/plugin marketplace add itsmistermoon/skills
/plugin install radiant@radiant
```

The flat install exposes `/wiki-ingest`, `/wiki-query`, and the other names below. The plugin exposes `/radiant:wiki-ingest`, `/radiant:wiki-query`, and so on. Use one installation method per agent.

## Start with a vault

Create a Git repository for your knowledge and run `/wiki-setup` inside it. Setup creates the wiki structure, installs the shared reference documents in `~/.config/radiant/references/`, registers the vault, and asks for its content language. Semantic search and post-commit hooks are optional.

Then ingest a source with `/wiki-ingest <url-or-file>` and ask a question with `/wiki-query <question>`. Answers cite the wiki pages used. Missing knowledge is reported explicitly.

Session memory also works in an ordinary project repository: run `/hot-handoff` to save context locally. It needs no registered vault. Shared handoff references are bundled with the skill; `/hot-triage` maintains that state later.

## Skills

| Skill | Purpose |
|---|---|
| `wiki-ingest` | Preserve a source, synthesize or update pages, and update the index |
| `wiki-query` | Search and answer from wiki evidence with page citations |
| `wiki-imprint` | Save a useful session analysis or decision as permanent knowledge |
| `wiki-lint` | Check structure, provenance, duplication, contradictions, and source drift |
| `wiki-setup` | Register vaults, synchronize templates, and configure optional search and hooks |
| `hot-handoff` | Save pending work, decisions, history, and operational lessons in the active repo |
| `hot-triage` | Prune temporary lessons and review session state for stale or recurring items |

## Knowledge and session state

`wiki/` contains permanent knowledge. Its four page types are concepts, entities, sources, and projects. Templates define the schema; [the format reference](docs/vault-format.md) defines links, citations, and the append-only operation log. `.raw/` preserves source artifacts outside the wiki.

`.hot/` contains local, gitignored session state. `HANDOFF.md` has at most five pending items and three active decisions, followed by session history. History older than 15 days moves to `HISTORY.md`. `PLAYBOOK.md` stores permanent conventions and dated working observations. Agents read the handoff and playbook at session start; older history is consulted on demand.

## Multiple vaults

`~/.config/radiant/config.yml` stores registered vaults:

```yaml
vaults:
  personal:
    path: /absolute/path/to/personal-vault
    locale: en
  work:
    path: /absolute/path/to/work-vault
    locale: es
default: personal
```

Wiki skills use an explicit vault name first, then a registered vault containing the current directory, then the default. For example, `/wiki-query work deployment decisions`. Handoff always writes session state in the active repository; an explicit vault argument can additionally target its project page.

## Dependencies

The core skills are Markdown instructions executed by your coding agent. Text search uses `rg`. Ingestion's sanitization check uses `bash`, `rg`, and `jq`. Structural lint uses Bash, Python 3.10+, `jq`, and PyYAML. Install its Python requirement with `python3 -m pip install -r skills/wiki-lint/scripts/requirements.txt` in your chosen Python environment. Installation uses Node.js through `npx`.

Semantic indexing is optional. Setup detects the available backend before offering it: Ollama, MLX embeddings, or sentence-transformers, with sqlite-vec for retrieval. A vault can ingest, query text, and maintain knowledge without these packages.

Repository tools include `bin/radiant-embed.sh` for indexing, `bin/setup-vault.sh /path/to/vault-repo` for optional Obsidian scaffolding in an existing Git repository, and `bin/tags-audit.py` for tag audits. Run them by path from a checkout. The Obsidian helper refuses to modify Radiant itself or overwrite existing Obsidian settings.

## Development

This directory is the source of truth for the radiant skills, templates, and their scripts. It contains no personal vault content. From this directory, run `bash scripts/check-skill-sync.sh` and the Python tests before submitting changes. The CI workflow that runs both lives at the repository root (`.github/workflows/skill-sync.yml`) because GitHub reads workflows only from there. See [AGENTS.md](AGENTS.md) for contribution rules.

MIT licensed.
