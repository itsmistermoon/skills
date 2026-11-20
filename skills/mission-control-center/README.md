# Mission Control Center (`mcc`)

The names come from a NASA control room. A handover passes the state to the next shift, a debrief reviews past flights, coast is flight without engines, and a sitrep is a situation report. Each skill applies that idea to agent sessions in a repo. Session state lives in `.mcc/` at the repo root, which git ignores.

- [`mcc-setup`](mcc-setup/SKILL.md) runs once per repo. It writes the session-start block and the `## Mission control` section in `AGENTS.md`, picks the task tracker, and sets up notifications and the decision label.
- [`mcc-handover`](mcc-handover/SKILL.md) runs at the end of a session. It sends pending work to the task tracker and saves decisions, lessons, and history in `.mcc/`.
- [`mcc-debrief`](mcc-debrief/SKILL.md) runs on demand. It deletes lessons older than 15 days and closes tasks and decisions that no longer apply.
- [`mcc-coast`](mcc-coast/SKILL.md) is away mode. It records your instructions, opens an issue for each decision, and logs outcomes until you return. Phone notifications are optional.
- [`mcc-sitrep`](mcc-sitrep/SKILL.md) reports what happened since a given time and presents open decisions one at a time.

## Task tracker

`mcc-setup` asks where pending work lives. The default is the Pending list in `.mcc/HANDOVER.md`. Any other tool works if `docs/agents/task-tracker.md` lists its List, Add, and Close commands. The skills run only those commands, so switching tools means rewriting that one file. [`mcc-setup/references/TASK-TRACKER.md`](mcc-setup/references/TASK-TRACKER.md) has the rules.

## Telegram channel

[`telegram-plugin/`](telegram-plugin/) is a fork of the official Telegram channel that gives each repo its own forum topic. `mcc-coast` uses it so you can reply from your phone. Setup steps are in [`mcc-setup/references/NOTIFICATIONS.md`](mcc-setup/references/NOTIFICATIONS.md).
