# Semantic search setup

Semantic search uses `Qwen/Qwen3-Embedding-0.6B` through sentence-transformers on Apple Metal (MPS), with sqlite-vec for storage. It downloads the model on first use. Use the same Python environment for setup, indexing, queries, and the reindex hook.

Check the dependencies and MPS in that environment:

```bash
python3 -c 'import torch, sentence_transformers, sqlite3, sqlite_vec; c=sqlite3.connect(":memory:"); c.enable_load_extension(True); sqlite_vec.load(c); print("MPS available:", torch.backends.mps.is_available())'
```

If imports fail, offer to install `sentence-transformers`, `transformers`, `torch`, and `sqlite-vec` into that environment. If SQLite cannot load extensions, use a Python/SQLite build that can. If MPS is unavailable, report that semantic search cannot run on its default device; textual search remains available. On consent, install dependencies and repeat the check before indexing.

For tests only, `RADIANT_EMBED_DEVICE=cpu` forces CPU. Without this variable the device is explicitly `mps`; there is no automatic CPU fallback.

An existing index built with another model cannot be reused: its vectors have a different meaning and dimension. Ask before removing or replacing it, then rebuild the entire index and recalibrate. Never mix vectors from different models.

Before creating or rebuilding an index, ensure `git check-ignore -q -- .wiki/` succeeds and `git ls-files -- .wiki/` has empty output. For a local-only rule, add `/.wiki/` to the file returned by `git rev-parse --git-path info/exclude`. The database stores excerpts from wiki pages, including pages Git may not track yet.
