# AGENTS.md: {vault-name}

This repo is a knowledge vault running the [Radiant suite](https://github.com/itsmistermoon/skills). Curated knowledge lives in `wiki/`. Session memory comes from the Mission Control Center suite (`/mcc-setup`).

<!-- radiant:vault-rules -->
## Working with the vault

- Radiant skills are user-invoked: run them yourself by name when the task calls for it (`/wiki-query`, `/wiki-ingest`, `/wiki-imprint`, `/wiki-lint`, `/wiki-setup`). Close every work session with `/mcc-handover`.
- New wiki pages follow the templates in `templates/` (concept, entity, source, project) and live under the matching `wiki/` subdirectory; `wiki/index.md` is the master index.
- Cross-reference pages with bundle-relative absolute markdown links (`[title](/wiki/entities/x.md)`), never `[[wikilinks]]`.
- Tag rules and registry: `meta/tags.md`.
<!-- /radiant:vault-rules -->

## Vault identity

<!-- Fill in: owner, purpose, domain-specific vocabulary if this vault has any (e.g. project-specific terms). Optional: delete this section if not needed. Locale lives in ~/.config/radiant/config.yml (set by /wiki-setup), not here. -->
