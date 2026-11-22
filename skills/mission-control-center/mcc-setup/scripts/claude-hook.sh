#!/bin/bash
# Claude Code hook for mcc-coast. Install at .claude/hooks/mcc-coast.sh; see the mcc-setup skill.
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
notify="$root/bin/notify"
input="$(cat)"
event="$(jq -r '.hook_event_name // empty' <<<"$input")"
claude_ancestor() {
  local pid="$1" parent command
  while [[ "$pid" =~ ^[0-9]+$ ]] && ((pid > 1)); do
    read -r parent command < <(ps -p "$pid" -o ppid= -o comm= 2>/dev/null) || return 1
    if [[ "${command##*/}" == claude ]]; then printf '%s' "$pid"; return 0; fi
    [[ "$parent" != "$pid" ]] || return 1
    pid="$parent"
  done
  return 1
}
telegram_active() {
  local common key state owner claim pid
  common="$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" && key="$(basename "$(dirname "$common")")" || key="$(basename "$root")"
  state="${TELEGRAM_STATE_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/channels/telegram}"
  owner="$(claude_ancestor "$PPID")" || return 1
  for claim in "$state/claims/$key/"*; do
    pid="${claim##*/}"
    [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null || continue
    [[ "$(claude_ancestor "$pid")" == "$owner" ]] && return 0
  done
  return 1
}
[[ "$event" == Notification || "$event" == Stop ]] && [[ ! -x "$notify" ]] && exit 0
case "$event" in
  Notification)
    [[ -f "$root/.mcc/COAST.md" ]] || exit 0
    msg="$(jq -r '.message // "The session is waiting for you."' <<<"$input")"
    NOTIFY_ORIGIN="$(basename "$root")" "$notify" "$msg" >/dev/null 2>&1 || true ;;
  Stop)
    [[ -f "$root/.mcc/COAST.md" ]] || exit 0
    telegram_active && exit 0
    last="$(jq -rj '.last_assistant_message // ""' <<<"$input"; printf '.')"
    last="${last%.}"
    message="Turn finished.${last:+ $last}"
    while ((${#message} > 4096)); do
      window="${message:0:4096}"
      cut=4096
      if [[ "$window" == *$'\n\n'* ]]; then
        before="${window%$'\n\n'*}"
        ((${#before} > 2048)) && cut=$((${#before} + 2))
      fi
      NOTIFY_ORIGIN="$(basename "$root")" "$notify" "${message:0:cut}" >/dev/null 2>&1 || true
      message="${message:cut}"
    done
    NOTIFY_ORIGIN="$(basename "$root")" "$notify" "$message" >/dev/null 2>&1 || true ;;
  UserPromptSubmit)
    [[ -f "$root/.mcc/COAST.md" ]] || exit 0
    prompt="$(jq -r '.prompt // empty' <<<"$input")"
    [[ "$prompt" == *'<channel source='* || "$prompt" == '[from '* || "$prompt" == *'<task-notification>'* ]] && exit 0
    echo "Away mode is on (.mcc/COAST.md exists) and the user just typed in the terminal: they are back. Run the mcc-sitrep skill before anything else." ;;
esac
exit 0
