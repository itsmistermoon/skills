#!/bin/bash
# Claude Code hook for coast. Install at .claude/hooks/coast.sh; see setup.md.
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
notify="$root/bin/notify"
input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"$input")"
[[ "$event" == Notification || "$event" == Stop ]] && [[ ! -x "$notify" ]] && exit 0
case "$event" in
  Notification)
    msg="$(jq -r '.message // "The session is waiting for you."' <<<"$input")"
    NOTIFY_ORIGIN="$(basename "$root")" "$notify" "$msg" >/dev/null 2>&1 || true ;;
  Stop)
    [[ -f "$root/.coast.md" ]] || exit 0
    last="$(jq -r '.last_assistant_message // empty' <<<"$input" | head -c 600)"
    NOTIFY_ORIGIN="$(basename "$root")" "$notify" "Turn finished.${last:+ $last}" >/dev/null 2>&1 || true ;;
  UserPromptSubmit)
    [[ -f "$root/.coast.md" ]] || exit 0
    jq -r '.prompt // empty' <<<"$input" | grep -q '<channel source=' && exit 0
    echo "Away mode is on (.coast.md exists) and the user just typed in the terminal: they are back. Run the sitrep skill before anything else." ;;
esac
exit 0
