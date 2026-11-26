# HANDOVER.md: format reference

File: `.mcc/HANDOVER.md` in the active repo root.
Gitignored: local agent artifact, not versioned content.

---

## Zone 1: Current state (MUTABLE)

Updated on every `/mcc-handover`. Hard limit: **max 3 active decisions**. **Tracker:** before writing Pending, read [TASK-TRACKER.md](../../mcc-setup/references/TASK-TRACKER.md) and use its representation for the resolved tracker.
When adding an item, evaluate whether an existing one is obsolete and remove it.

```markdown
---
agent: {agent-id}
updated: {YYYY-MM-DD}
---

# {project}: handover

## Current state

### Pending
{Pending representation from TASK-TRACKER.md}

### Active decisions
- {decision and rationale: to avoid re-litigating it}
```

`agent:` identifies who last wrote Current state. Update it on every invocation.

`### Pending`: only what requires action in a future session: if a next agent doesn't need to act on it, it belongs in History instead. If a specific skill would help resume, mention it inline in the relevant item rather than a dedicated section.

---

## Zone 2: History (APPEND-ONLY)

Preserve previous entries verbatim; append new entries at the end. `HISTORY.md` is never read automatically: consult it directly only when a session needs older history.

```markdown
## History

### {YYYY-MM-DD HH:MM UTC±N}: {Agent}
<!-- Exact timestamp with local offset. Example: 2026-06-08 14:30 -04. Never omit time or offset. -->

#### What was done
- {bullet per significant change: file or decision, not narrative} (considered {alternative}, discarded because {reason}: only if a discarded alternative is relevant to this specific bullet)

#### Attempted and failed
- {approach tried, why it failed, evidence: prevents retrying the same dead end}

#### Fragile context
- {exact numbers, commands, paths, URLs, conventions a new agent can't infer from code}

```

Include Attempted and failed and Fragile context only when they have content.

Reference existing ADRs, PRDs, issues, or commits by path or link.

In every section, omit unnecessary personal information, tokens, API keys, and credentials (patterns: `sk-*`, `Bearer *`, `ghp_*`, `?token=*`, flags `--password`/`-u user:pass`). If fragile context requires a credential to reproduce, replace it with `<REDACTED>` and note where to obtain it without reading credential files.
