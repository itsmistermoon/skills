#!/usr/bin/env python3
"""
radiant-search: Semantic search over the vault index.
Usage: python search.py "query" [--top-k N] [--vault PATH]
"""
import argparse
import json
import sqlite3
import struct
import sys
from pathlib import Path


def _resolve_embeddings_dir() -> Path:
    """Find the directory containing embeddings.py: always a sibling of this
    script (co-located with the skill or in ~/.config/radiant/bin/)."""
    here = Path(__file__).parent
    if (here / "embeddings.py").exists():
        return here
    print("ERROR: Cannot locate embeddings.py (expected as a sibling of this script).", file=sys.stderr)
    sys.exit(1)


sys.path.insert(0, str(_resolve_embeddings_dir()))
import embeddings as emb  # noqa: E402

DEFAULT_TOP_K = 5
DEFAULT_THRESHOLD = 0.5


def find_db(vault: Path | None) -> Path:
    start = vault if vault is not None else Path.cwd()
    candidates = [start] if vault is not None else [start, *start.parents]
    for candidate in candidates:
        old_dir = candidate / ".hot" / "db"
        if (old_dir / "vault.db").exists() or (old_dir / "config.json").exists():
            sys.exit("ERROR: Move the existing semantic index via /wiki-setup embeddings first.")
        db_path = candidate / ".wiki" / "db" / "vault.db"
        if db_path.exists():
            return db_path
    sys.exit("ERROR: vault.db not found. Run radiant-index first.")


def load_threshold(db_dir: Path) -> float:
    config_path = db_dir / "config.json"
    if config_path.exists():
        cfg = json.loads(config_path.read_text())
        return cfg.get("distance_threshold", DEFAULT_THRESHOLD)
    return DEFAULT_THRESHOLD


def open_db(db_path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(f"{db_path.as_uri()}?mode=ro", uri=True)
    if conn.execute("SELECT 1 FROM sqlite_master WHERE name = 'vec_documents'").fetchone():
        conn.close()
        sys.exit("ERROR: Old semantic index detected. Delete .wiki/db/vault.db and reindex via /wiki-setup embeddings.")
    return conn


def search(conn: sqlite3.Connection, query_vec_bytes: bytes, top_k: int, threshold: float) -> list[dict]:
    query = struct.unpack(f"<{emb.DIMENSIONS}f", query_vec_bytes)
    best = {}
    for path, heading, chunk_index, content, blob in conn.execute(
        "SELECT path, heading, chunk_index, content, embedding FROM documents"
    ):
        vector = struct.unpack(f"<{emb.DIMENSIONS}f", blob)
        distance = 1.0 - sum(map(lambda pair: pair[0] * pair[1], zip(query, vector)))
        if distance < threshold and (path not in best or distance < best[path]["distance"]):
            best[path] = {"path": path, "heading": heading, "chunk_index": chunk_index,
                          "content": content, "distance": distance}
    results = sorted(best.values(), key=lambda result: result["distance"])[:top_k]
    for result in results:
        result["distance"] = round(result["distance"], 4)
    return results


def main():
    parser = argparse.ArgumentParser(description="Semantic search over Radiant vault")
    parser.add_argument("query", help="Search query")
    parser.add_argument("--top-k", type=int, default=DEFAULT_TOP_K)
    parser.add_argument("--vault", type=str, default=None)
    parser.add_argument("--json", action="store_true", help="Output JSON")
    parser.add_argument("--threshold", type=float, default=None,
                        help="Distance threshold override (default: from config.json)")
    args = parser.parse_args()

    db_path = find_db(Path(args.vault).resolve() if args.vault else None)
    threshold = args.threshold if args.threshold is not None else load_threshold(db_path.parent)

    conn = open_db(db_path)
    try:
        query_vec = emb.embed_query(args.query)
    except emb.EmbeddingBackendError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)
    query_bytes = emb.vec_to_bytes(query_vec)

    results = search(conn, query_bytes, args.top_k, threshold)
    conn.close()

    if args.json:
        print(json.dumps(results, indent=2, ensure_ascii=False))
        return

    if not results:
        print(f"No results above similarity threshold ({threshold}).")
        return

    for r in results:
        loc = f"{r['path']}"
        if r["heading"]:
            loc += f" § {r['heading']}"
        sim = round(1.0 - r["distance"], 3)
        print(f"[{sim:.3f}] {loc}")
        snippet = r["content"][:200].replace("\n", " ")
        print(f"  {snippet}...")
        print()


if __name__ == "__main__":
    main()
