# Embedding dependency check

Disclosed reference for `wiki-setup`. Reached from step 5 (new-vault wizard), maintenance menu option 5, and step 5a's reindex-hook fallback.

**Core rule: check before asking.** Never ask a generic "enable semantic search?": detect what's already available first, then tailor the question to that. A user who already has Ollama running gets a one-line confirm, not a menu. A user with nothing gets the full menu with every option's tradeoffs spelled out. This mirrors `embeddings.py`'s own runtime backend priority: Ollama → mlx-embeddings (Apple Silicon) → sentence-transformers.

## Storage dependency

Before evaluating an embedding backend, check sqlite-vec in the same Python environment used for indexing:

```bash
python3 -c 'import sqlite3, sqlite_vec; c=sqlite3.connect(":memory:"); c.enable_load_extension(True); sqlite_vec.load(c); c.enable_load_extension(False); c.close()'
```

If this fails, report the failure and include sqlite-vec setup in the offer. On authorization, run `python3 -m pip install sqlite-vec` in the chosen Python environment, then rerun the load check. A SQLite build that disallows extensions needs a different Python/SQLite installation; explain that requirement and leave semantic search disabled until it is met. An embedding backend alone is not ready-to-go.

## Backend detection (run in this order, stop at the first success)

1. **Ollama.** Is the server responding?
   ```bash
   curl -s --max-time 2 http://localhost:11434/api/tags >/dev/null 2>&1 && echo running || echo not-running
   ```
   - **`running`** → check if the embedding model is already pulled:
     ```bash
     ollama list 2>/dev/null | grep -q nomic-embed-text && echo pulled || echo not-pulled
     ```
     - **`pulled`** → backend ready. Use "Ready-to-go" only if the storage dependency also passed; otherwise include that missing dependency in the offer.
     - **`not-pulled`** → one step away. Use "One step away" wording below.
   - **`not-running`** → check if the binary is installed at all:
     ```bash
     command -v ollama >/dev/null 2>&1 && echo installed || echo not-installed
     ```
     - **`installed`** → Ollama is present but not running. Use "Installed but not running" wording below: do not jump to install instructions.
     - **`not-installed`** → continue to step 2.

2. **Platform + Python libraries.** Detect platform: `uname -m` → `arm64` = Apple Silicon, anything else = generic. Then:
   ```bash
   if python3 -c "import mlx_embeddings" 2>/dev/null; then echo mlx; elif python3 -c "import sentence_transformers" 2>/dev/null; then echo st; else echo none; fi
   ```
   - **`mlx` or `st`** → backend importable. Use "Ready-to-go" only if the storage dependency passed; model download or loading may still occur during indexing.
   - **`none`** → nothing is available. Use "Full menu" wording.

## Offer wording, by detection outcome

**Ready-to-go** (storage check passed and Ollama+model pulled, or a Python library importable):
```
✓ {backend} ready: no setup needed.
Initialize semantic search now? [Y/n]
```

**One step away** (Ollama running, model not pulled):
```
✓ Ollama detected and running.
Semantic search needs the "nomic-embed-text" model (~274 MB, downloaded once).

Download it and initialize semantic search now? [Y/n]
```
If yes: `ollama pull nomic-embed-text`, show progress, then proceed to indexing.

**Installed but not running** (Ollama binary present, server not responding):
```
Ollama is installed but not running. Start it (`ollama serve`, or launch the Ollama app), then try again.
```
Re-run the detection above once the user confirms it's running.

**Full menu** (nothing detected):
```
Semantic search needs one of these to generate embeddings locally. Choose:

  [1] Ollama (recommended): installs Ollama, downloads nomic-embed-text
      (~274 MB, once). Runs as a local service. No network calls at query time.
  [2] mlx-embeddings: Apple Silicon only, using MLX.
                                                         (omit if not arm64)
  [3] sentence-transformers: works on any platform, runs on CPU (slower),
      ~270 MB of model weights.
  [4] Not now: use wiki-query's textual search across page names and content;
      enable semantic search later with /wiki-setup

Choose [1-4]:
```

## Installation, by choice

- **Ollama, not yet installed**: point the user to https://ollama.com/download (installing Ollama itself is a system-level action this skill does not perform automatically: ask the user to confirm it's installed and running before proceeding). Once running, `ollama pull nomic-embed-text`.
- **mlx-embeddings**: `pip install mlx-embeddings`. If it fails, fall back to `pip install sentence-transformers` and note the fallback.
- **sentence-transformers**: `pip install sentence-transformers`.
- After any install, re-run the relevant detection snippet to confirm before proceeding to indexing. If still failing, report the error and skip indexing: do not proceed blindly.
- **"Not now" / declined**: skip indexing, note in the final summary that semantic search is not active and how to enable it later (`/wiki-setup`, maintenance menu option 5).
