#!/bin/bash
set -euo pipefail
hook="$(cd "$(dirname "$0")/.." && pwd)/scripts/claude-hook.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/.mcc"
touch "$tmp/.mcc/COAST.md"
export CLAUDE_PROJECT_DIR="$tmp" OUT="$tmp/out"
printf '%s\n' '#!/bin/bash' 'printf "%s\0" "$1" >> "$OUT"' > "$tmp/bin/notify"
chmod +x "$tmp/bin/notify"

text="$(printf '%05000d' 0)"
jq -n --arg text "$text" '{hook_event_name:"Stop",last_assistant_message:$text}' | bash "$hook"
python3 -c 'import os; p=open(os.environ["OUT"],"rb").read().split(b"\0")[:-1]; assert len(p)==2 and all(len(x)<=4096 for x in p) and b"".join(p)==b"Turn finished. "+b"0"*5000'
echo 'OK: Stop envía el mensaje completo en partes'
rm "$OUT"
text="$(printf '%03000d' 0)"$'\n\n'"$(printf '%02000d' 1)"
jq -n --arg text "$text" '{hook_event_name:"Stop",last_assistant_message:$text}' | bash "$hook"
python3 -c 'import os; p=open(os.environ["OUT"],"rb").read().split(b"\0")[:-1]; assert p==[b"Turn finished. "+b"0"*3000+b"\n\n", b"0"*1999+b"1"]'
echo 'OK: Stop prefiere cortar en un párrafo sin perder texto'

rm "$OUT"
export TELEGRAM_STATE_DIR="$tmp/telegram" PATH="$tmp/bin:$PATH"
mkdir -p "$TELEGRAM_STATE_DIR/claims/$(basename "$tmp")"
sleep 60 &
claim_pid=$!
trap 'kill "$claim_pid" 2>/dev/null || true; rm -rf "$tmp"' EXIT
touch "$TELEGRAM_STATE_DIR/claims/$(basename "$tmp")/$claim_pid"
export CLAIM_PID="$claim_pid"
printf '%s\n' '#!/bin/bash' 'if [[ "$2" == 4242 ]]; then echo "1 claude"; else echo "4242 bash"; fi' > "$tmp/bin/ps"
chmod +x "$tmp/bin/ps"
printf '%s' '{"hook_event_name":"Stop","session_id":"session-1","last_assistant_message":"respuesta"}' | bash "$hook"
[[ ! -e "$OUT" ]]
echo 'OK: Stop omite la sesión de Telegram'
printf '%s\n' '#!/bin/bash' 'if [[ "$2" == "$CLAIM_PID" ]]; then echo "4343 bun"; elif [[ "$2" == 4343 || "$2" == 4242 ]]; then echo "1 claude"; else echo "4242 bash"; fi' > "$tmp/bin/ps"
printf '%s' '{"hook_event_name":"Stop","last_assistant_message":"otra sesión"}' | bash "$hook"
python3 -c 'import os; assert open(os.environ["OUT"],"rb").read()=="Turn finished. otra sesión\0".encode()'
echo 'OK: Stop conserva avisos de otra sesión del mismo repo'
rm "$OUT"
kill "$claim_pid"
wait "$claim_pid" 2>/dev/null || true
printf '%s' '{"hook_event_name":"Stop","last_assistant_message":"claim vencido"}' | bash "$hook"
python3 -c 'import os; assert open(os.environ["OUT"],"rb").read()==b"Turn finished. claim vencido\0"'
echo 'OK: Stop ignora claims de procesos terminados'

for prompt in '[from agent] hello' 'aviso <task-notification>terminó</task-notification>' '<channel source="telegram">hola'; do
  result="$(jq -n --arg prompt "$prompt" '{hook_event_name:"UserPromptSubmit",prompt:$prompt}' | bash "$hook")"
  [[ -z "$result" ]]
done
result="$(printf '%s' '{"hook_event_name":"UserPromptSubmit","prompt":"volví"}' | bash "$hook")"
[[ "$result" == *mcc-sitrep* ]]
echo 'OK: solo un prompt de terminal indica el regreso'
