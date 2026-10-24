---
name: hot-handoff
license: MIT
description: "Save pending work, decisions, operational lessons, and session history in the active repository."
disable-model-invocation: true
argument-hint: "[vault-name] [project-name] [next: <focus>]"
---

Start with `Handing off session...` in the user's language. Use that language for confirmations. Save session state in the nearest Git repository, including worktrees; no registered vault or machine-global reference files are required.

## Steps

1. **Resolve context.** Find the repository root from CWD; ask for a repository if none exists. Identify the invoking agent and model when known, otherwise use `Unknown agent`. Use the registered locale if this repo is inside a vault listed in `~/.radiant/config.yml`; otherwise use the conversation language. If the config is absent, continue locally. Parse `next: <focus>` separately from any vault/project arguments. **Done when:** the local target, language, agent, and next focus are known.

2. **Prepare state.** Read `references/HANDOFF-FORMAT.md` beside this skill and the existing `.hot/HANDOFF.md`, if present. Validate existing state against that format before editing; if it is unreadable or malformed, leave it intact and report the problem. Create `.hot/` when needed and add it to `.gitignore`. Remember whether `.hot/` existed before this run. Rotate History entries older than 15 days: append each verbatim, oldest-first, to `.hot/HISTORY.md`, then remove the successfully archived entries from HANDOFF. Create HISTORY with a `# {repo-name}: history` header if needed. Preserve the order of all remaining entries. **Done when:** no History entry older than 15 days remains in HANDOFF, or a write failure has been reported with the original state preserved.

3. **Capture operational lessons.** Read `references/PLAYBOOK-FORMAT.md` beside this skill and `.hot/PLAYBOOK.md` if present. Review this session for reusable workarounds, user preferences, conventions, and recurring failure patterns. Update matching entries instead of duplicating them. Point to authoritative documents when they already contain the lesson. Leave retrospective pruning to `/hot-triage`. **Done when:** each candidate is recorded, already documented, rejected as transient, or reported as uncaptured.

4. **Write the snapshot.** Update Current state and append a History entry using the format from step 2. Reconcile duplicates and resolved or superseded items in Current state; preserve previous History entries. Keep at most five pending items and three active decisions. Tailor Pending to `next:` when supplied. Identify any actionable item that cannot fit in the final confirmation.

   - **Local vault health:** if `{repo}/meta/vault-report.json` exists, read `health.dead_links`, `health.raw_without_source_page`, `health.missing_confidence`, `health.orphan_pages`, `health.missing_raw`, `health.unindexed_pages`, and `health.duplicate_sources`. Maintain one dated Pending item with the finding count and report path. A nonempty report takes priority over the least-recent pending item; report any displaced action. Remove the health item when the report is empty. Mention unresolved findings explicitly in the confirmation.
   - **Maintenance nudge:** if the oldest Working-context date in PLAYBOOK is over 30 days old, add a single Pending suggestion to run `/hot-triage` for overdue pruning. On the first handoff only, if AGENTS.md lacks `<!-- radiant:session-start -->` or an equivalent instruction, suggest `/wiki-setup` for a vault or `/hot-triage` for an ordinary repo. This skill does not edit AGENTS.md.

   **Done when:** the snapshot is saved, history preserved, sensitive content omitted, and any uncaptured action identified.

5. **Optional project update.** Only if the user supplied a vault argument, requested a project-page update, or this session consulted a vault for the active project, follow `references/PROJECT-UPDATE.md`. Complete the local handoff first. A missing vault or unavailable project page does not undo or block the local snapshot.

## Confirmation

Report changes to Pending, a one-line History summary, and any project page updated. State either `Safe to end: everything durable from this session is captured` or `Not fully captured: {what is missing and why}`. Give a resume pointer starting with `.hot/HANDOFF.md` Current state, adding PLAYBOOK only when relevant. Older history is read only when needed.
