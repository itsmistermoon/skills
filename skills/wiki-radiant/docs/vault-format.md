# Vault format

The canonical page schema lives in `templates/`. Radiant uses the Open Knowledge Format conventions for its `wiki/` bundle.

| Content | Location |
|---|---|
| Reusable knowledge | `wiki/concepts/` |
| People, organizations, tools, services | `wiki/entities/` |
| External artifacts | `wiki/sources/` |
| Active projects | `wiki/projects/` |
| Navigation | `wiki/index.md` |
| Append-only operation log | `wiki/log.md` |
| Preserved source artifacts | `.raw/` |
| Tag registry and local health report | `meta/` |

Pages use YAML frontmatter, a coherent synthesized body, and a chronological changelog. `created:` records page creation; `updated:` records its last edit. On Source pages, `timestamp:` is the original publication date, while `resource:` identifies the external artifact and `raw:` points to its preserved copy. Conversational analysis is captured through imprint, not classified as an external Source.

Cross-references use Markdown links such as `[Example](/wiki/concepts/example.md)`. Concepts, entities, and projects place supporting wiki links in a `# Citations` section, numbered as `[1] [Title](/wiki/sources/example.md)`. Source provenance uses `resource:` and `raw:` instead. Keep raw content outside the wiki bundle and immutable after saving.

The root index declares `okf_version: "0.1"`. Every content page must appear in the index; every index link must resolve. A page can be linked from several sections intentionally. Existing pages are updated in place rather than duplicated.

Log entries use `**[YYYY-MM-DD] operation** | detail`. Record ingests, imprints, actual lint corrections, and unanswered queries. Successful queries do not produce log noise. Page changelog entries use `- YYYY-MM-DD: description`.

Session state is a separate concern under `.hot/`, outside the knowledge bundle. Its format is defined by the references bundled with hot-handoff.
