# Mission Control Center (`mcc`)

Skills that run a repo's work like a mission control room: each session hands over to the next, a debrief prunes what went stale, away mode keeps the mission flying while you are gone, and a sitrep brings you back up to speed. Session state lives in `.mcc/` at the repo root, gitignored.

- **[mcc-setup](mcc-setup/SKILL.md)**: one-time setup in a repo: session-start block, task tracker, notifications, and decision label, all in `AGENTS.md`.
- **[mcc-handover](mcc-handover/SKILL.md)**: end of session. Saves pending work to the task tracker, plus decisions, lessons, and history in `.mcc/`.
- **[mcc-debrief](mcc-debrief/SKILL.md)**: on-demand review. Prunes temporary lessons and closes stale tasks and decisions.
- **[mcc-coast](mcc-coast/SKILL.md)**: away mode. Records your instructions, routes decisions to issues, and logs outcomes for your return; phone notifications are optional.
- **[mcc-sitrep](mcc-sitrep/SKILL.md)**: situation report. Recaps what happened since a point in time and clears open decisions one at a time.

## Task tracker

Pending work lives in the tracker the repo picked during `mcc-setup`: the Pending list in `.mcc/HANDOFF.md` by default, or any tool whose List, Add, and Close commands are written in `docs/agents/task-tracker.md`. The skills run those commands and know nothing else about the tool, so switching tools means rewriting one file.

## Telegram channel

[telegram-plugin/](telegram-plugin/) is a fork of the official Telegram channel with one forum topic per repo, used by `mcc-coast` for two-way replies from the phone. Setup is in `mcc-setup` step 8.
