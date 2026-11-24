"""Qwen3 embeddings for semantic retrieval."""
import os
import struct
import sys

MODEL_NAME = "Qwen/Qwen3-Embedding-0.6B"
DIMENSIONS = 1024
QUERY_INSTRUCTION = "Instruct: Given a web search query, retrieve relevant passages that answer the query\nQuery: "
_st_model = None


class EmbeddingBackendError(RuntimeError):
    """An embedding call returned an invalid vector."""


def load_embedding_model() -> str:
    global _st_model
    if _st_model is None:
        try:
            from sentence_transformers import SentenceTransformer
            _st_model = SentenceTransformer(
                MODEL_NAME, device=os.environ.get("RADIANT_EMBED_DEVICE", "mps")
            )
        except Exception as exc:
            sys.exit(f"ERROR: Cannot load {MODEL_NAME} with sentence-transformers: {exc}")
    return "sentence-transformers"


def embed(text: str) -> list[float]:
    load_embedding_model()
    try:
        vec = _st_model.encode(text, normalize_embeddings=True).tolist()
    except Exception as exc:
        raise EmbeddingBackendError(f"Embedding failed: {exc}") from exc
    if len(vec) != DIMENSIONS:
        raise EmbeddingBackendError(f"Embedding has {len(vec)} dimensions, expected {DIMENSIONS}")
    return vec


def embed_document(text: str) -> list[float]:
    return embed(text)


def embed_query(text: str) -> list[float]:
    return embed(QUERY_INSTRUCTION + text)


def vec_to_bytes(vec: list[float]) -> bytes:
    return struct.pack(f"{len(vec)}f", *vec)
