---
name: sitrep
description: "Situation report and decision clearing. Use when the user asks for a sitrep, a recap or catch-up (\"where were we?\"), or returns from coast away mode."
argument-hint: "{since: date, time, or event}"
---

Reply in the user's language.

## 1. Window

The window starts at the first that applies:

1. A start the user gave as argument.
2. `since:` in `.coast.md`, when it exists (return from away mode).
3. The user's previous message in this session.
4. 24 hours ago.

## 2. Facts

Gather what happened in the window, each item checked at its source:

- PRs opened, merged, or with failing checks: `gh search prs --owner <owner> --updated ">=<date>"` for each owner in the `## Coast` section of `AGENTS.md` (or the owners of repos this session touched, when that section is absent).
- Commits on the branches of the repos this home repo points to, and any batch-run logs those repos keep.
- When `.coast.md` exists: what was done under its instructions.

**Done when** every event has its source checked. Write it as outcomes for the user: what finished, what failed, what is still running, with the full URL of every PR.

## 3. Open decisions

`gh search issues --owner <owner> label:decision state:open --json title,url,repository,body,updatedAt`, once per owner.

Before presenting a decision, check it is still live against the PR, branch, or fact that raised it. One the facts already settled gets closed with a comment citing that evidence.

## 4. Clearing

Present only the highest-impact open decision, and say the ordering is your pick: what is decided, why it matters, the options, your recommendation. When the user answers:

1. Comment their words verbatim on the issue and close it.
2. Carry out what the answer authorizes.
3. Present the next one.

**Done when** no open decision remains or the user stops.

## 5. Closing a return

When `.coast.md` exists, delete it after the report: the user is back.
