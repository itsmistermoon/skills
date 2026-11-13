#!/bin/bash
# notify "text": sends text to the user on Telegram, prefixed with its origin.
# Origin: $NOTIFY_ORIGIN, else the current git repo's name, else "home".
# Reads TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID from .env at the repo root (one level above this script).
# With TELEGRAM_GROUP_ID (a forum supergroup where the bot can manage topics), each origin
# gets its own topic, created on first use and cached in .telegram-topics ("origin<TAB>thread_id").
# The token reaches curl on stdin, never in argv.
set -euo pipefail
[[ $# -ge 1 ]] || { echo 'usage: notify "text"' >&2; exit 2; }
root="$(cd "$(dirname "$0")/.." && pwd)"
origin="${NOTIFY_ORIGIN:-$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo home)")}"
. "$root/.env"

api() { # api <method> [curl args...]: calls the Bot API, prints the JSON result
  local method="$1"; shift
  printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$TELEGRAM_BOT_TOKEN" "$method" \
    | curl -fsS -m 20 -K - "$@"
}

if [[ -n "${TELEGRAM_GROUP_ID:-}" ]]; then
  cache="$root/.telegram-topics"; touch "$cache"
  thread="$(awk -F'\t' -v o="$origin" '$1==o{print $2; exit}' "$cache")"
  if [[ -z "$thread" ]]; then
    thread="$(api createForumTopic --data-urlencode "chat_id=$TELEGRAM_GROUP_ID" --data-urlencode "name=$origin" \
      | sed -n 's/.*"message_thread_id":\([0-9]*\).*/\1/p')"
    [[ -n "$thread" ]] && printf '%s\t%s\n' "$origin" "$thread" >> "$cache"
  fi
  api sendMessage --data-urlencode "chat_id=$TELEGRAM_GROUP_ID" ${thread:+--data-urlencode "message_thread_id=$thread"} \
    --data-urlencode "text=[$origin] $*" -o /dev/null
else
  api sendMessage --data-urlencode "chat_id=$TELEGRAM_CHAT_ID" --data-urlencode "text=[$origin] $*" -o /dev/null
fi
