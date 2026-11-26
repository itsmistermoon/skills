#!/bin/bash
# save-token.sh: guarda el token del bot de Telegram sin que pase por el chat.
# Córrelo en tu propia terminal: lee el token oculto y lo escribe en <state-dir>/.env con permisos 600.
set -euo pipefail
dir="${TELEGRAM_STATE_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/channels/telegram}"
mkdir -p "$dir"
read -rsp "Token de BotFather (no se muestra): " token; echo
[[ "$token" =~ ^[0-9]+:[A-Za-z0-9_-]{30,}$ ]] || { echo "save-token: no parece un token de BotFather; no guardé nada" >&2; exit 1; }
env="$dir/.env"; tmp="$env.tmp"
umask 077
{ [[ -f "$env" ]] && grep -v '^TELEGRAM_BOT_TOKEN=' "$env" || true; printf 'TELEGRAM_BOT_TOKEN=%s\n' "$token"; } > "$tmp"
mv "$tmp" "$env"; chmod 600 "$env"; unset token
echo "save-token: token guardado en $env (600). Reinicia la sesión o corre /reload-plugins."
