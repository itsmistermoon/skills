# Mission Control Center (`mcc`)

The names come from a NASA control room. Each skill applies that idea to agent sessions in a repo. Session state lives in `.mcc/` at the repo root, which git ignores.

- [`mcc-setup`](mcc-setup/SKILL.md) runs once per repo. It writes the session-start block and the `## Mission control` section in `AGENTS.md`, picks the task tracker, and sets up notifications and the decision label.
- [`mcc-handover`](mcc-handover/SKILL.md) runs at the end of a session. It sends pending work to the task tracker and saves decisions, lessons, and history in `.mcc/`.
- [`mcc-debrief`](mcc-debrief/SKILL.md) runs on demand. It deletes lessons older than 15 days and closes tasks and decisions that no longer apply.
- [`mcc-coast`](mcc-coast/SKILL.md) is away mode. It records your instructions, opens an issue for each decision, and logs outcomes until you return. Phone notifications are optional.
- [`mcc-sitrep`](mcc-sitrep/SKILL.md) reports what happened since a given time and presents open decisions one at a time.

## Install

In Claude Code:

```text
/plugin install mission-control-center --marketplace itsmistermoon/skills
```

Codex reads the same marketplace: `codex plugin marketplace add itsmistermoon/skills`, then `codex plugin add mission-control-center@itsmistermoon-skills`.

In OpenCode, add the plugin to `plugins` in `~/.config/opencode/opencode.jsonc`, as `github:itsmistermoon/skills#main::path:skills/mission-control-center` or a local clone's path.

The Claude Code plugin exposes the skills as `/mission-control-center:mcc-handover` and so on. For other agents, or for the short `/mcc-handover` names, install the skills directly with `npx skills add itsmistermoon/skills --skill mcc-handover`. Use one installation method per agent.

## Task tracker

`mcc-setup` asks where pending work lives. The default is the Pending list in `.mcc/HANDOVER.md`. Any other tool works if `docs/agents/task-tracker.md` lists its List, Add, and Close commands. The skills run only those commands, so switching tools means rewriting that one file. [`mcc-setup/references/TASK-TRACKER.md`](mcc-setup/references/TASK-TRACKER.md) has the rules.

## Telegram channel

[`telegram-plugin/`](telegram-plugin/) is an optional fork of the official Telegram channel that gives each repo its own forum topic. With it, you can answer `mcc-coast` from your phone. Without it, `mcc-coast` still logs everything and can still send notifications through `bin/notify`. Setup steps are in [`mcc-setup/references/NOTIFICATIONS.md`](mcc-setup/references/NOTIFICATIONS.md).
