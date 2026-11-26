---
name: mcc-sitrep
description: "Sitrep: report fleet state and resolve decisions on a status request, return from mcc-coast, or fresh session start."
argument-hint: "{since: date, time, or event} {focus: an owner or domain}"
---

The user reads a **brief**, not your research: you hold every fact, they get only what changes what they do. Name each item by what it is, with its number or link as support, never a bare list of numbers.

## 1. Window and focus

The window starts at the first that applies:

1. A start the user gave as argument.
2. `since:` in `.mcc/COAST.md`, when it exists (return from away mode).
3. The user's previous message in this session.
4. 24 hours ago.

A focus the user names ("Imaquinaria", "my personal projects") maps to one owner of the fleet manifest. With a focus, the report covers that owner only, plus one line of anomalies that cost elsewhere.

**Done when:** the start and applicable owner filter are resolved.

## 2. Facts

Read `## Mission control` in AGENTS.md. **Fleet:** when configured, read its backend document before running its map or identifying owners. **Tracker:** when listing or changing pending work, read [TASK-TRACKER.md](../mcc-setup/references/TASK-TRACKER.md) and execute the destination’s contract. Gather independent facts in one parallel script:

- When Fleet is configured: the map command its backend document declares, in JSON (with the owner filter for a focus). It returns anomalies with their action, each owner's tasks with their WSJF, PRs, branches, worktrees, handover Pending and live sessions. Read only: each owner writes only its own `.mcc/`.
- Without Fleet: open PRs and failing checks for each owner in the `## Mission control` section of `AGENTS.md`, branches and uncommitted changes in the repos this home repo points to, and the tracker’s open tasks.
- This repo's `.mcc/HANDOVER.md` Current state, including its `### Decision queue`.
- Open decisions: `gh search issues --owner <owner> label:decision state:open --json title,url,repository,body,updatedAt`, once per owner.
- When `.mcc/COAST.md` exists: every line of its `## Log`, each owner's results through `mcc-fleet`, and the Telegram daily logs in `${TELEGRAM_STATE_DIR:-${CLAUDE_CONFIG_DIR:-~/.claude}/channels/telegram}/log/` for the window.

Check each decision against the PR, branch or fact that raised it. One the facts already settled gets closed with a comment citing that evidence.

**Done when** every applicable source above has been checked, each decision has been reconciled with its evidence, and unavailable sources are identified.

## 3. Push right

Before writing, do everything that needs no one: close what is already done, clean up merged leftovers inside your own domain, estimate cost of delay (`cod`) and `size` for tasks the map flags without them (1, 2, 3, 5, 8, 13, with a one-line reason as a reply). Actions outside your authority (remote deletes, other owners' repos, anything outward-facing) wait for one bundled go.

**Done when:** each actionable item is resolved within existing authority or listed with the authorization it needs.

## 4. Report

1. One sentence: what waits on the user, or that nothing does.
2. Anomalies that block or cost (quota, failed deploy, dead session), each with its action. Nominal state is not reported.
3. The fleet: one line per owner, counts and its one most important point (`vc: 9 open, 6 for you, 4 blocked until Dec 1`).
4. One line of what you already resolved, and one line of maintenance waiting for a go, when there is any.
5. Three priorities, ranked by WSJF (`cod ÷ size`; cheap items that clear a pending rise), your pick first. Each is a **decision of impact**: it unblocks work, sets scope or direction, or carries cost or risk outside. A trivial yes or no is not one: decide it yourself and report it. For each, about 30 words: the call, your pick, what it changes, the evidence, the risk. Include only decisions supported by the facts.

Write the chosen order into `### Decision queue` in Current state of `.mcc/HANDOVER.md`, so a later session resumes it. Recompute only when the facts changed.

**Done when** the report is delivered and the queue is written.

## 5. Burning decisions

Take one decision at a time, in queue order. When the user answers:

1. Record their words verbatim where the decision lives (issue comment, task reply) and close it.
2. Carry out what the answer authorizes.
3. When the answer opens a consequence, chain it: "with that yes, X follows; what do you decide on X? I suggest Y". Follow the branch until it closes or depends on something outside.
4. Strike the item in the queue with a one-line result, then present the next.

After three, present the next three by the same rule, without repeating the report. Keep going until no decision remains or the user stops. Then name in one line what is now ready for agents, and offer to launch them with one go.

**Done when** the queue is empty or the user stopped.

## 6. Closing a return

When `.mcc/COAST.md` exists, delete it after the report: the user is back. **Done when:** the report is delivered and the file is absent.
