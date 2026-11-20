---
name: mcc-handover
license: MIT
description: "Hand over the session to the next shift: pending work to the task tracker, plus decisions, lessons, and history in `.mcc/`. Use at the end of a work session."
disable-model-invocation: true
argument-hint: "[vault-name] [project-name] [repo: <path>] [next: <focus>]"
---

A handover is the shift change in a mission control room: the incoming shift gets everything it needs to fly on without the outgoing one. Start with `Handing over session...` in the user's language. Use that language for confirmations. Save session state in the nearest Git repository, including worktrees, or in the repository named by `repo:`; no registered vault or machine-global reference files are required.

## Steps

1. **Resolve context.** With `repo: <path>`, the target is the Git root of that path (a leading `@` is ignored); if the path is not inside a Git repository, stop and ask. Record only that repository's work, decisions, and lessons; the rest of the session counts as uncaptured. Without `repo:`, find the repository root from CWD; ask for a repository if none exists. Identify the invoking agent and model when known, otherwise use `Unknown agent`. Use the registered locale if this repo is inside a vault listed in `~/.config/radiant/config.yml`; otherwise use the conversation language. If the config is absent, continue locally. Resolve the task tracker with `../mcc-setup/references/TASK-TRACKER.md`. Parse `repo:` and `next: <focus>` separately from any vault/project arguments. **Done when:** the local target, language, agent, next focus, and task tracker are known.

2. **Prepare state.** Read `references/HANDOVER-FORMAT.md` beside this skill and the existing `.mcc/HANDOVER.md`, if present. Validate existing state against that format before editing; if it is unreadable or malformed, leave it intact and report the problem. Create `.mcc/` when needed and add it to `.gitignore`. Remember whether `.mcc/` existed before this run. Rotate History entries older than 15 days: append each verbatim, oldest-first, to `.mcc/HISTORY.md`, then remove the successfully archived entries from HANDOVER. Create HISTORY with a `# {repo-name}: history` header if needed. Preserve the order of all remaining entries. **Done when:** no History entry older than 15 days remains in HANDOVER, or a write failure has been reported with the original state preserved.

3. **Capture operational lessons.** Read `references/PLAYBOOK-FORMAT.md` beside this skill and `.mcc/PLAYBOOK.md` if present. Review this session for reusable workarounds, user preferences, conventions, and recurring failure patterns. Update matching entries instead of duplicating them. Point to authoritative documents when they already contain the lesson. Leave retrospective pruning to `/mcc-debrief`. **Done when:** each candidate is recorded, already documented, rejected as transient, or reported as uncaptured.

4. **Write the snapshot.** Update Current state and append a History entry using the format from step 2. Reconcile duplicates and resolved or superseded items in Current state; preserve previous History entries. Keep at most three active decisions. Tailor pending work to `next:` when supplied.

   - **Pending work:** List the tracker's open tasks, then Add each new one and Close each one this session finished or dropped.
   - **Local vault health:** if `{repo}/meta/vault-report.json` exists, read `health.dead_links`, `health.raw_without_source_page`, `health.missing_confidence`, `health.orphan_pages`, `health.missing_raw`, `health.unindexed_pages`, and `health.duplicate_sources`. Keep one dated pending task with the finding count and report path while the report is nonempty, and Close it when the report is empty. Mention unresolved findings explicitly in the confirmation.
   - **Maintenance nudge:** if the oldest Working-context date in PLAYBOOK is over 30 days old, add a single pending task to run `/mcc-debrief` for overdue pruning. On the first handover only, if AGENTS.md lacks `<!-- mcc:session-start -->` or the `## Mission control` section, suggest `/mcc-setup`. This skill does not edit AGENTS.md.

   **Done when:** the snapshot is saved, history preserved, sensitive content omitted, and any uncaptured action identified.

5. **Optional project update.** Only if the user supplied a vault argument, requested a project-page update, or this session consulted a vault for the active project, follow `references/PROJECT-UPDATE.md`. Complete the local handover first. A missing vault or unavailable project page does not undo or block the local snapshot.

## Confirmation

Start with the absolute path of the `.mcc/HANDOVER.md` written. Report changes to pending work (with task IDs or URLs when the tracker gives them), a one-line History summary, and any project page updated. State either `Safe to end: everything durable from this session is captured` or `Not fully captured: {what is missing and why}`. Give a resume pointer starting with `.mcc/HANDOVER.md` Current state, adding PLAYBOOK only when relevant. Older history is read only when needed.
