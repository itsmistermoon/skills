# Semantic search setup

Semantic search uses Ollama and the `qwen3-embedding:0.6b` model. Python 3.10+ uses only its standard library for indexing and search. Ollama defaults to `http://127.0.0.1:11434`; set `OLLAMA_HOST` to use another host.

Check the service and model:

```bash
host=${OLLAMA_HOST-http://127.0.0.1:11434}
while [[ $host == */ ]]; do host=${host%/}; done
if [[ $host != *://* ]]; then host="http://$host"; fi
curl -fsS "$host/api/tags" | python3 -c 'import json, sys; print("\n".join(m["name"] for m in json.load(sys.stdin)["models"]))'
```

If Ollama is not responding, run `brew services start ollama`. If the list does not contain `qwen3-embedding:0.6b`, run `ollama pull qwen3-embedding:0.6b`, then repeat the check.

An existing index built with the old schema or another model cannot be reused. Ask before removing `.wiki/db/vault.db`, then rebuild the entire index and recalibrate. Never mix vectors from different models.

Before creating or rebuilding an index, ensure `git check-ignore -q -- .wiki/` succeeds and `git ls-files -- .wiki/` has empty output. For a local-only rule, add `/.wiki/` to the file returned by `git rev-parse --git-path info/exclude`. The database stores excerpts from wiki pages, including pages Git may not track yet.
