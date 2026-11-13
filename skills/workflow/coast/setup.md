# coast setup

One-time setup for `coast` and `sitrep` in a home repo. Ask before each write to a file that already exists; preserve its other content.

## 1. Notify command

`coast` needs one shell command that sends a short text to the user's phone.

1. Ask which channel to use. Offer Telegram, using [scripts/notify-telegram.sh](scripts/notify-telegram.sh).
2. For Telegram: copy the script to `bin/notify` in the repo and make it executable. The user creates a bot with @BotFather and stores `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` in `.env` at the repo root. Have them write the token from the clipboard with a command you hand them, so it never appears in chat. The user must message the bot once before it can write to them.
3. Confirm `.env` and `.coast.md` are in `.gitignore`; add them if missing.
4. Run `bin/notify "coast setup test"`. **Done when** the user confirms the message arrived.

## 2. Decisions

1. Ask which GitHub owners (users or orgs) hold the repos where decisions can live.
2. The decision label is `decision`. For each repo that receives a decision, create the label on first use: `gh label create decision -R <owner>/<repo>`.

## 3. AGENTS.md

Add this section to the repo's `AGENTS.md`, filled in:

```markdown
## Coast

- Notify command: `bin/notify "<text>"` (prefix: `[<repo>]`; set `NOTIFY_ORIGIN=<role>` to override).
- Decision label: `decision`, in repos of: <owner>, <owner>.
- If `.coast.md` exists, the user is away: follow the `coast` skill from step 3. Their first message typed in the terminal is the return: run the `sitrep` skill.
```

The last line is what lets any session, and any harness that reads `AGENTS.md`, notice away mode.

## 4. Hooks (Claude Code, optional)

[scripts/claude-hook.sh](scripts/claude-hook.sh) adds three behaviours:

- `Notification`: notifies whenever the session waits for input or a permission.
- `Stop`: while `.coast.md` exists, notifies each finished turn with its last message.
- `UserPromptSubmit`: while `.coast.md` exists, a prompt typed in the terminal gets a reminder to run `sitrep` first. Prompts arriving from a channel (`<channel source=...>`) are skipped.

Copy it to `.claude/hooks/coast.sh`, make it executable, and register it in `.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [{ "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/coast.sh" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/coast.sh" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/coast.sh" }] }]
  }
}
```

Merge into existing `hooks` arrays rather than replacing them. Requires `jq`.

## 5. Two-way channel (Claude Code, optional)

To answer from the phone, run the session with the official Telegram channel plugin, on the same bot:

1. `claude plugin install telegram@claude-plugins-official --scope project` (run inside the repo).
2. Write the bot token to `<state dir>/.env` as `TELEGRAM_BOT_TOKEN=...`, with `TELEGRAM_STATE_DIR` pointing at a directory for this repo.
3. Start sessions with `TELEGRAM_STATE_DIR=<state dir> claude --channels plugin:telegram@claude-plugins-official`; a shell alias keeps it to one word.
4. Message the bot, then `/telegram:access pair <code>` and `/telegram:access policy allowlist`.

One bot serves one listening session at a time.

**Setup is complete when** the test notification arrived and the `## Coast` section is in `AGENTS.md`.
