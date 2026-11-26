# PLAYBOOK.md format

File: `.mcc/PLAYBOOK.md`.
Gitignored: local agent artifact, not versioned content.

---

## Zone 1: Permanent

Structural conventions, architecture invariants, and confirmed technical workarounds. An entry stays until the convention it describes no longer applies.

Write here when the user stated it explicitly as a standing rule, or it already appears once in `## Working context` from a prior session and has now held true again: promote it by moving the entry and its evidence to Permanent.

```markdown
---
schema_version: "0.1"
updated: YYYY-MM-DD
---

# PLAYBOOK: {vault-name}

## Permanent

- **{convention}**: {concise description of why it exists and what breaks if violated}
- **{workaround}**: {unexpected behavior, cause, fix applied, confirmed: YYYY-MM-DD, YYYY-MM-DD}
```

---

## Zone 2: Working context (15-DAY TTL)

Active context with a date. Pruned by `/mcc-debrief` when older than 15 days.

Write here for a single-session observation not yet confirmed: an untested workaround, a first-seen failure pattern, an inferred convention. If genuinely ambiguous whether it belongs in Permanent instead, ask once: "This looks like it might be a standing convention: write it to Permanent, or keep it as working context for now?" Default here unless the user approves Permanent.

```markdown
## Working context

### YYYY-MM-DD
- {active context entry: removed when older than 15 days}
```

---

## Rules

- **`## Permanent`**: can be removed if the convention no longer applies; whoever deletes, explains.
- **`## Working context`**: pruning is automatic, the agent does not ask.
- **Evidence**: an entry accumulates evidence in either zone. When a later session confirms it, append that session's date, plus a link or commit when one exists.
- **Learning**: PLAYBOOK captures lessons that outlast the session; record session events in HANDOVER History.
