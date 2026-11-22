# Telegram

Connect a Telegram bot to your Claude Code with an MCP server.

The MCP server logs into Telegram as a bot and provides tools to Claude to reply, react, or edit messages. When you message the bot, the server forwards the message to your Claude Code session.

## Prerequisites

- [Bun](https://bun.sh) — the MCP server runs on Bun. Install with `curl -fsSL https://bun.sh/install | bash`.

## Quick Setup
> Default pairing flow for a single-user DM bot. See [ACCESS.md](./ACCESS.md) for groups and multi-user setups.

**1. Create a bot with BotFather.**

Open a chat with [@BotFather](https://t.me/BotFather) on Telegram and send `/newbot`. BotFather asks for two things:

- **Name** — the display name shown in chat headers (anything, can contain spaces)
- **Username** — a unique handle ending in `bot` (e.g. `my_assistant_bot`). This becomes your bot's link: `t.me/my_assistant_bot`.

BotFather replies with a token that looks like `123456789:AAHfiqksKZ8...` — that's the whole token, copy it including the leading number and colon.

**2. Install the plugin.**

These are Claude Code commands — run `claude` to start a session first.

Install the plugin:
```
/plugin install telegram@claude-plugins-official
```

**3. Give the server the token.**

```
/telegram:configure 123456789:AAHfiqksKZ8...
```

Writes `TELEGRAM_BOT_TOKEN=...` to `~/.claude/channels/telegram/.env`. You can also write that file by hand, or set the variable in your shell environment — shell takes precedence.

> To run multiple bots on one machine (different tokens, separate allowlists), point `TELEGRAM_STATE_DIR` at a different directory per instance.

Each session receiving the channel creates `${TELEGRAM_STATE_DIR:-${CLAUDE_CONFIG_DIR:-~/.claude}/channels/telegram}/claims/<repo-key>/<server-pid>`. A Claude hook can identify its own channel by finding a live claim whose server process shares the hook's Claude ancestor. A duplicate session has no claim and receives a warning on stderr and in the MCP instructions.

Accepted messages and successful sends and edits are recorded in `log/YYYY-MM-DD.md` under the state directory, with local time, direction, topic and text. The bot token, recognizable credential assignments and pairing codes are redacted; treat the logs as private conversation data.

Each repo home's `bin/notify` sends notifications through the same bot using a separate token path.

**4. Relaunch with the channel flag.**

The server won't connect without this — exit your session and start a new one:

```sh
claude --channels plugin:telegram@claude-plugins-official
```

**5. Pair.**

With Claude Code running from the previous step, DM your bot on Telegram — it replies with a 6-character pairing code. If the bot doesn't respond, make sure your session is running with `--channels`. In your Claude Code session:

```
/telegram:access pair <code>
```

Your next DM reaches the assistant.

> Unlike Discord, there's no server invite step — Telegram bots accept DMs immediately. Pairing handles the user-ID lookup so you never touch numeric IDs.

**6. Lock it down.**

Pairing is for capturing IDs. Once you're in, switch to `allowlist` so strangers don't get pairing-code replies. Ask Claude to do it, or `/telegram:access policy allowlist` directly.

## Access control

See **[ACCESS.md](./ACCESS.md)** for DM policies, groups, mention detection, delivery config, skill commands, and the `access.json` schema.

Quick reference: IDs are **numeric user IDs** (get yours from [@userinfobot](https://t.me/userinfobot)). Default policy is `pairing`. `ackReaction` only accepts Telegram's fixed emoji whitelist.

## Tools exposed to the assistant

| Tool | Purpose |
| --- | --- |
| `reply` | Send to a chat. Takes `chat_id` + `text`, optionally `reply_to` (message ID) for native threading and `files` (absolute paths) for attachments. Images (`.jpg`/`.png`/`.gif`/`.webp`) send as photos with inline preview; other types send as documents. Max 50MB each. Auto-chunks text; files send as separate messages after the text. Returns the sent message ID(s). |
| `react` | Add an emoji reaction to a message by ID. **Only Telegram's fixed whitelist** is accepted (👍 👎 ❤ 🔥 👀 etc). |
| `edit_message` | Edit a message the bot previously sent. Useful for "working…" → result progress updates. Only works on the bot's own messages. |

Inbound messages trigger a typing indicator automatically — Telegram shows
"botname is typing…" while the assistant works on a response.

## Photos

Inbound photos are downloaded to `~/.claude/channels/telegram/inbox/` and the
local path is included in the `<channel>` notification so the assistant can
`Read` it. Telegram compresses photos — if you need the original file, send it
as a document instead (long-press → Send as File).

## Local history

Telegram's Bot API exposes **neither** message history nor search. The bot
only sees messages as they arrive — no `fetch_messages` tool exists. The local
daily logs contain messages seen while the channel was running.

This also means there's no `download_attachment` tool for historical messages
— photos are downloaded eagerly on arrival since there's no way to fetch them
later.
