# Notifications and channel

Read from `mcc-setup` step 4. Each section is optional; run the ones the user chose.

## 1. Notify command

1. Offer Telegram, using [../scripts/notify-telegram.sh](../scripts/notify-telegram.sh).
2. For Telegram: copy the script to `bin/notify` in the repo and make it executable. The user creates a bot with @BotFather and stores `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` in `.env` at the repo root. Have them write the token from the clipboard with a command you hand them, so it never appears in chat. The user must message the bot once before it can write to them.
   - Optional, one topic per origin: the user creates a group, turns on **Topics**, and adds the bot as admin with **Manage topics**. Add `TELEGRAM_GROUP_ID=<-100...>` to `.env` (read it from the bot's `getUpdates` while no session is listening). Each origin then posts to its own topic, created on first use.
3. Run `bin/notify "mcc setup test"`. **Done when** the user confirms the message arrived, or declined notifications.

## 2. Hooks (Claude Code, optional)

The notification hooks act only when `bin/notify` exists; the return reminder works without it.

[../scripts/claude-hook.sh](../scripts/claude-hook.sh) adds three behaviours:

- `Notification`: while `.mcc/COAST.md` exists, notifies whenever the session waits for input or a permission.
- `Stop`: while `.mcc/COAST.md` exists, notifies each finished turn with its last message.
- `UserPromptSubmit`: while `.mcc/COAST.md` exists, a prompt typed in the terminal gets a reminder to run `mcc-sitrep` first. Prompts arriving from a channel (`<channel source=...>`) are skipped.

Copy it to `.claude/hooks/mcc-coast.sh`, make it executable, and register it in `.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [{ "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/mcc-coast.sh" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/mcc-coast.sh" }] }],
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/mcc-coast.sh" }] }]
  }
}
```

Merge into existing `hooks` arrays rather than replacing them. Requires `jq`.

## 3. Two-way channel (Claude Code, optional)

To answer from the phone. Two plugin choices, both on the same bot as `bin/notify`:

- **Official** `telegram@claude-plugins-official`: direct messages, or a group where every reply lands in General.
- **Topics fork** in [../../telegram-plugin/](../../telegram-plugin/) (`telegram@itsmistermoon-skills`): with the topics group, each repo's sessions read and answer in that repo's topic, and the home repo takes General plus topics with no open session. See [../../telegram-plugin/CHANGES.md](../../telegram-plugin/CHANGES.md).

Steps for the topics fork:

1. `claude plugin marketplace add itsmistermoon/skills`, then `claude plugin install telegram@itsmistermoon-skills --scope user`, and set `"telegram@itsmistermoon-skills": false` under `enabledPlugins` in `~/.claude/settings.json` so it loads only when asked.
2. Pick a state dir (e.g. `~/.claude/channels/telegram-home`). Write `TELEGRAM_BOT_TOKEN=...` to `<state dir>/.env` from the clipboard, never through chat. Point `notify` at the shared topic registry: add `TELEGRAM_TOPICS_FILE=<state dir>/topics.tsv` to the repo's `.env`.
3. Add a launcher to the user's shell config; it works in any repo:

   ```sh
   cct() { TELEGRAM_STATE_DIR="<state dir>" TELEGRAM_TOPICS_FILE="<state dir>/topics.tsv" TELEGRAM_HOME_KEY="<home repo name>" \
     claude --settings '{"enabledPlugins":{"telegram@itsmistermoon-skills":true}}' \
     --dangerously-load-development-channels plugin:telegram@itsmistermoon-skills "$@"; }
   ```

   Non-official channels need `--dangerously-load-development-channels`; Claude Code asks to confirm it.
4. Start `cct` in the home repo, message the bot, then `/telegram:access pair <code>` and `/telegram:access policy allowlist`.
5. Add the group to `<state dir>/access.json` under `groups` as `{"requireMention": false, "allowFrom": [<user id>]}`.

**Done when** a reply in a repo's topic reaches the `cct` session open in that repo, and its answer lands in the same topic.
