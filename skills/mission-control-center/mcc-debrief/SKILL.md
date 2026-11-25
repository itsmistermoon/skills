---
name: mcc-debrief
license: MIT
description: "Debrief stale session state: prune expired lessons, review tasks and decisions, and surface recurring patterns."
disable-model-invocation: true
argument-hint: ""
---

A debrief reviews the flights so far and keeps only what the next one needs. Start with `Debriefing session state...` in the user's language. It reviews local session memory in the nearest Git repository, including worktrees.

## Steps

1. **Resolve context.** Find the repo root and read `.mcc/HANDOVER.md`, `.mcc/PLAYBOOK.md`, and `.mcc/HISTORY.md`, whichever exist. If none exist, report that and stop. Read the format documents in `../mcc-handover/references/` relative to this installed skill; if mcc-handover is missing, report the incomplete installation. Resolve the task tracker with `../mcc-setup/references/TASK-TRACKER.md` and List its open tasks. **Done when:** state and its format are available.

2. **Prune temporary lessons.** Remove Working-context subsections older than 15 days from PLAYBOOK, per its format. Preserve Permanent. This mechanical expiry is part of the requested debrief; no additional confirmation is needed. **Done when:** every expired Working-context entry has been removed, or no entries qualified.

3. **Review recurring lessons.** Inspect the full archived history for repeated workarounds, conventions, or failure patterns. Propose each durable lesson with supporting session dates, checking PLAYBOOK for an existing match. **Done when:** each recurring candidate found is proposed or rejected with a reason. Apply additions only when authorized.

4. **Check active state.** Check every pending task and Active decision against later history and current repo evidence. Propose closing resolved or stale tasks with the tracker's Close, and removing resolved or stale decisions. Preserve live actions and the three-decision limit. After approved changes, refresh `agent:` and `updated:`. **Done when:** every current item has been evaluated and approved edits are saved.

5. **Ensure session startup.** If AGENTS.md lacks `<!-- mcc:session-start -->` or the `## Mission control` section, propose running `/mcc-setup`. **Done when:** both exist or the user declined.

6. **Review archive duplication.** Look for archived blocks that repeat the same work. Propose a dated superseding note referencing those blocks. HISTORY is append-only: preserve existing entries. **Done when:** duplicate candidates are reported and any approved note has been appended.

7. **Report.** Summarize the pruning performed and group remaining proposals by step. Ask only about changes not already authorized. State any incomplete checks explicitly. **Done when:** every performed change, proposal, and incomplete check is reported.
