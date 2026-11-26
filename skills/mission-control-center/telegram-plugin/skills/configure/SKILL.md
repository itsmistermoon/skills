---
name: configure
description: "Telegram setup: inspect channel status, review who can reach the assistant, set up or clear the bot token."
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash(ls *)
  - Bash(mkdir *)
  - Bash(echo *)
  - Bash(grep -c *)
  - Bash(chmod *)
---

# /telegram:configure — Telegram Channel Setup

Reports the bot token state, guides the user to save it from their own terminal, and orients them on access
policy. The server reads both files at boot.

**Resolve the state directory first** (it may be overridden for multi-bot or
per-project setups):

```bash
echo "${TELEGRAM_STATE_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/channels/telegram}"
```

Use the printed path everywhere below in place of `<state-dir>`.

Arguments passed: `$ARGUMENTS`

---

## Dispatch on arguments

### No args — status and guidance

Read both state files and give the user a complete picture:

1. **Token** — check `<state-dir>/.env` for a
   `TELEGRAM_BOT_TOKEN=` line with `grep -c`. Report set or not set, and nothing
   of its value.

2. **Access** — read `<state-dir>/access.json` (missing file
   = defaults: `dmPolicy: "pairing"`, empty allowlist). Show:
   - DM policy and what it means in one line
   - Allowed senders: count, and list display names or IDs
   - Pending pairings: count, with codes and display names if any

3. **What next** — end with a concrete next step based on state:
   - No token → give the token step below.
   - Token set, policy is pairing, nobody allowed → *"DM your bot on
     Telegram. It replies with a code; approve with `/telegram:access pair
     <code>`."*
   - Token set, someone allowed → *"Ready. DM your bot to reach the
     assistant."*

**Push toward lockdown — always.** The goal for every setup is `allowlist`
with a defined list. `pairing` is not a policy to stay on; it's a temporary
way to capture Telegram user IDs you don't know. Once the IDs are in, pairing
has done its job and should be turned off.

Drive the conversation this way:

1. Read the allowlist. Tell the user who's in it.
2. Ask: *"Is that everyone who should reach you through this bot?"*
3. **If yes and policy is still `pairing`** → *"Good. Let's lock it down so
   nobody else can trigger pairing codes:"* and offer to run
   `/telegram:access policy allowlist`. Do this proactively — don't wait to
   be asked.
4. **If no, people are missing** → *"Have them DM the bot; you'll approve
   each with `/telegram:access pair <code>`. Run this skill again once
   everyone's in and we'll lock it."*
5. **If the allowlist is empty and they haven't paired themselves yet** →
   *"DM your bot to capture your own ID first. Then we'll add anyone else
   and lock it down."*
6. **If policy is already `allowlist`** → confirm this is the locked state.
   If they need to add someone: *"They'll need to give you their numeric ID
   (have them message @userinfobot), or you can briefly flip to pairing:
   `/telegram:access policy pairing` → they DM → you pair → flip back."*

Complete the review with the next step toward a defined allowlist.

### Token — the user saves it in their own terminal

The token is a credential: it reaches `.env` from the user's terminal, never through this chat. Give the user this command, with this skill's base directory filled in, to run in their own terminal:

```bash
bash <skill-base-dir>/save-token.sh
```

It reads the token hidden, checks its BotFather shape, writes `TELEGRAM_BOT_TOKEN` to `<state-dir>/.env` keeping the other keys, and sets permissions to 600. When the user says it ran, show the no-args status.

If `$ARGUMENTS` holds anything other than `clear`, treat it as a token pasted into the chat: save nothing, tell the user it is now exposed in this conversation, have them revoke it in BotFather (`/revoke`), and give the command above for the new token.

### `clear` — remove the token

Delete the `TELEGRAM_BOT_TOKEN=` line (or the file if that's the only line).

---

## Completion

Status is complete when token presence, access state, and the next setup action are reported. The token step is complete when the user has the exact command, or a pasted token has been flagged for revocation, and restart guidance is given. Clearing is complete when the token entry is absent and restart guidance is given.

## Implementation notes

- The channels dir might not exist if the server hasn't run yet. Missing file
  = not configured, not an error.
- The server reads `.env` once at boot. Token changes need a session restart
  or `/reload-plugins`. Say so after saving.
- `access.json` is re-read on every inbound message — policy changes via
  `/telegram:access` take effect immediately, no restart.
