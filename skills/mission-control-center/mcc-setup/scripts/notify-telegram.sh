#!/bin/bash
# notify "text": sends text to the user on Telegram, prefixed with its origin.
# Origin: $NOTIFY_ORIGIN, else the name of the current main git repo (worktrees included), else "home".
# Sender: $NOTIFY_FROM (the agent role, e.g. xo), shown after the origin when set.
# Reads TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID from .env at the repo root (one level above this script).
# With TELEGRAM_GROUP_ID (a forum supergroup where the bot can manage topics), each origin
# gets its own topic, created on first use and cached in .telegram-topics ("origin<TAB>thread_id").
# With NOTIFY_FILE=<path>, sends that file as a document with the text as its caption (max 1024 chars).
# The token reaches curl on stdin, never in argv.
set -euo pipefail
[[ $# -ge 1 ]] || { echo 'usage: notify "text"' >&2; exit 2; }
root="$(cd "$(dirname "$0")/.." && pwd)"
# Main repo of the current directory: worktrees resolve to the repo they belong to.
repo_root() { local c; c="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || return 1; dirname "$c"; }
origin="${NOTIFY_ORIGIN:-$(basename "$(repo_root || echo home)")}"
prefix="[$origin]${NOTIFY_FROM:+[$NOTIFY_FROM]}"
. "$root/.env"

api() { # api <method> [curl args...]: calls the Bot API, prints the JSON result
  local method="$1"; shift
  printf 'url = "https://api.telegram.org/bot%s/%s"\n' "$TELEGRAM_BOT_TOKEN" "$method" \
    | curl -fsS -m 20 -K - "$@"
}

send() { # send <chat_id> [thread_id]: the text, or NOTIFY_FILE with the text as caption
  if [[ -n "${NOTIFY_FILE:-}" ]]; then
    api sendDocument --form-string "chat_id=$1" ${2:+--form-string "message_thread_id=$2"} \
      --form-string "caption=$prefix $text" -F "document=@$NOTIFY_FILE" -o /dev/null
  else
    api sendMessage --data-urlencode "chat_id=$1" ${2:+--data-urlencode "message_thread_id=$2"} \
      --data-urlencode "text=$prefix $text" -o /dev/null
  fi
  echo "notify: entregado a Telegram como $prefix"
}
text="$*"

if [[ -n "${TELEGRAM_GROUP_ID:-}" ]]; then
  cache="${TELEGRAM_TOPICS_FILE:-$root/.telegram-topics}"; touch "$cache"
  thread="$(awk -F'\t' -v o="$origin" '$1==o{print $2; exit}' "$cache")"
  if [[ -z "$thread" ]]; then
    thread="$(api createForumTopic --data-urlencode "chat_id=$TELEGRAM_GROUP_ID" --data-urlencode "name=$origin" \
      | sed -n 's/.*"message_thread_id":\([0-9]*\).*/\1/p')"
    [[ -n "$thread" ]] && printf '%s\t%s\n' "$origin" "$thread" >> "$cache" && new_topic=1
  fi
  send "$TELEGRAM_GROUP_ID" ${thread:+"$thread"}
  # Telegram pins the first message of a new topic; keep topics unpinned.
  [[ -n "${new_topic:-}" ]] && api unpinAllForumTopicMessages --data-urlencode "chat_id=$TELEGRAM_GROUP_ID" \
    --data-urlencode "message_thread_id=$thread" -o /dev/null || true
else
  send "$TELEGRAM_CHAT_ID"
fi
