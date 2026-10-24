#!/usr/bin/env bash
# Bootstrap the optional semantic index from this installed checkout.
set -euo pipefail

if [[ $# -gt 1 || "${1:-}" == "--help" ]]; then
  echo "Usage: radiant-embed.sh [vault-name|vault-path]"
  [[ $# -le 1 ]] && exit 0 || exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEXER="$SCRIPT_DIR/../skills/wiki-setup/scripts/index.py"
[[ -f "$INDEXER" ]] || { echo "ERROR: wiki-setup scripts are missing beside bin/." >&2; exit 2; }

if [[ $# -eq 1 && -d "$1" ]]; then
  VAULT_PATH="$(cd "$1" && pwd)"
else
  VAULT_PATH=$(python3 - "$HOME/.config/radiant/config.yml" "${1:-}" <<'PY'
import sys
from pathlib import Path
try:
    import yaml
    config = yaml.safe_load(Path(sys.argv[1]).read_text()) or {}
    name = sys.argv[2] or config.get("default")
    path = config.get("vaults", {}).get(name, {}).get("path")
    if not path:
        raise ValueError("No matching vault. Pass its path or run /wiki-setup.")
    print(Path(path).expanduser().resolve())
except (ImportError, OSError, ValueError, AttributeError) as error:
    sys.exit(f"Cannot resolve vault: {error}")
PY
  )
fi

[[ -d "$VAULT_PATH/wiki" ]] || { echo "ERROR: No wiki/ in $VAULT_PATH" >&2; exit 2; }
exec python3 -B "$INDEXER" "$VAULT_PATH"
