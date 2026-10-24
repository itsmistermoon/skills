# vault-report.json: schema reference

Reference for `wiki-lint` (step 5). Read when adding fields or checking what the Layer 1 script persists.

`{vault}/meta/vault-report.json` is the session-startup health signal read in `AGENTS.md`. Gitignored: a local artifact, not versioned content. Written by `scripts/lint.sh` on every Layer 1 run: the agent never writes it directly.

## Schema

```json
{
  "generated": "YYYY-MM-DD",
  "health": {
    "dead_links": [],
    "raw_without_source_page": [],
    "missing_confidence": [],
    "orphan_pages": [],
    "missing_raw": [],
    "unindexed_pages": [],
    "duplicate_sources": []
  }
}
```

## Field definitions

- `health.dead_links`: array of `{"from": "wiki/...", "broken_target": "/wiki/..."}` objects, from Layer 1.
- `health.raw_without_source_page`: array of `.raw/` file paths with no corresponding `wiki/sources/` page, from Layer 1.
- `health.missing_confidence`: array of page paths where `confidence:` is absent from frontmatter, from Layer 1.
- `health.orphan_pages`: array of page paths with no incoming markdown links from any other vault page, from Layer 1. Matched by full vault-relative path (e.g. `wiki/concepts/foo.md`) to avoid basename collisions.
- `health.missing_raw`: Source page paths with missing, unusable, or out-of-bounds raw artifacts.
- `health.unindexed_pages`: content page paths absent from `wiki/index.md`, independent of incoming links elsewhere.
- `health.duplicate_sources`: groups shaped as `{"raw": ".raw/file.md", "pages": ["wiki/sources/a.md", "wiki/sources/b.md"]}`. These are candidates for human review, not automatic merge instructions.

This schema is canonical: do not add fields that have no consumer in `AGENTS.md` or in this skill. Two of Layer 1's checks (no-frontmatter, no-tags) are real findings the script reports to console but does not persist here: by design, not an oversight.
