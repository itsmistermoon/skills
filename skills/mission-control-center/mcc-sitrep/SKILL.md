---
name: mcc-sitrep
description: "Give a situation report and clear decisions when the user asks for a sitrep or catch-up, or returns from mcc-coast away mode, and as the first skill of a fresh session: a map of the whole fleet to choose what to work on."
argument-hint: "{since: date, time, or event}"
---

Reply in the user's language.

## 1. Window

The window starts at the first that applies:

1. A start the user gave as argument.
2. `since:` in `.mcc/COAST.md`, when it exists (return from away mode).
3. The user's previous message in this session.
4. 24 hours ago.

## 2. Facts

Gather what happened in the window, each item checked at its source. Fetch every independent source in one parallel script:

- PRs opened, merged, or with failing checks: `gh search prs --owner <owner> --updated ">=<date>"` for each owner in the `## Mission control` section of `AGENTS.md` (or the owners of repos this session touched, when that section is absent).
- Commits on the branches of the repos this home repo points to, and any batch-run logs those repos keep.
- `.mcc/HANDOVER.md` Current state, and the open tasks from the task tracker (resolve it with `../mcc-setup/references/TASK-TRACKER.md`).
- When Fleet is configured, map every owner's open work with the commands the backend document declares, whether or not you are returning from coast: tracker tasks across all channels grouped by owner (ready for the user, ready for an agent, blocked, waiting, expired claims); open PRs and failing checks; unmerged branches, leased worktrees and uncommitted changes in their repos; the Pending section of each owner's `.mcc/HANDOVER.md`; and which agent sessions are live against the fleet manifest. Read only: each owner writes only its own `.mcc/`. Returning from coast, also collect each owner's results through `mcc-fleet` and consolidate them with links.
- When `.mcc/COAST.md` exists: every line of its `## Log`, and what was done under its instructions.
- On return from coast, read the Telegram daily logs in `${TELEGRAM_STATE_DIR:-${CLAUDE_CONFIG_DIR:-~/.claude}/channels/telegram}/log/` for the window and summarize the messages in the report.

**Done when** every event has its source checked. Write it as outcomes for the user: what finished, what failed, what is still running, what is still pending, with the full URL of every PR. Present the fleet map as one short block per owner (open, half-done, blocked), each item with its URL, path or task number.

## 3. Open decisions

`gh search issues --owner <owner> label:decision state:open --json title,url,repository,body,updatedAt`, once per owner.

Before presenting a decision, check it is still live against the PR, branch, or fact that raised it. One the facts already settled gets closed with a comment citing that evidence.

## 4. Clearing

Present only the highest-impact open decision, and say the ordering is your pick: what is decided, why it matters, the options, your recommendation. When the user answers:

1. Comment their words verbatim on the issue and close it.
2. Carry out what the answer authorizes.
3. Present the next one.

**Done when** no open decision remains or the user stops.

## 5. Choosing the session's work

Without `.mcc/COAST.md`, end with three candidates for this session, ranked by impact and urgency, your pick first, each with a one-line reason and its link. Prefer half-done work and what blocks others. When the user chooses, claim the task in the task tracker (create it with its Add if it does not exist) and start.

**Done when** the user has chosen or declined.

## 6. Closing a return

When `.mcc/COAST.md` exists, delete it after the report: the user is back. **Done when:** the report is delivered and the file is absent.
