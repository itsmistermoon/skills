#!/bin/bash
# notify "text": sends text to the user on Telegram, prefixed with its origin.
# Origin: $NOTIFY_ORIGIN, else the current git repo's name, else "home".
# Reads TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID from .env at the repo root (one level above this script).
# The token reaches curl on stdin, never in argv.
set -euo pipefail
[[ $# -ge 1 ]] || { echo 'usage: notify "text"' >&2; exit 2; }
root="$(cd "$(dirname "$0")/.." && pwd)"
origin="${NOTIFY_ORIGIN:-$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo home)")}"
. "$root/.env"
printf 'url = "https://api.telegram.org/bot%s/sendMessage"\ndata-urlencode = "chat_id=%s"\n' \
  "$TELEGRAM_BOT_TOKEN" "$TELEGRAM_CHAT_ID" \
  | curl -fsS -m 20 -K - --data-urlencode "text=[$origin] $*" -o /dev/null
