"""Ollama Qwen3 embeddings for semantic retrieval."""
import json
import math
import os
import struct
import urllib.error
import urllib.request

MODEL_NAME = "qwen3-embedding:0.6b"
DIMENSIONS = 1024
QUERY_INSTRUCTION = "Instruct: Given a web search query, retrieve relevant passages that answer the query\nQuery: "


class EmbeddingBackendError(RuntimeError):
    """The embedding service failed or returned an invalid vector."""


def embed_documents(texts: list[str]) -> list[list[float]]:
    if not texts:
        return []
    host = os.environ.get("OLLAMA_HOST", "http://127.0.0.1:11434").rstrip("/")
    if "://" not in host:
        host = "http://" + host
    request = urllib.request.Request(host + "/api/embed", data=json.dumps({
        "model": MODEL_NAME, "input": texts,
    }).encode(), headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            vectors = json.load(response)["embeddings"]
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            raise EmbeddingBackendError(f"Ollama model missing. Run: ollama pull {MODEL_NAME}") from exc
        raise EmbeddingBackendError(f"Ollama request failed: {exc}") from exc
    except (urllib.error.URLError, TimeoutError, OSError) as exc:
        raise EmbeddingBackendError(f"Cannot connect to Ollama. Run: brew services start ollama ({exc})") from exc
    except (ValueError, KeyError, TypeError) as exc:
        raise EmbeddingBackendError(f"Invalid Ollama response: {exc}") from exc
    if not isinstance(vectors, list) or len(vectors) != len(texts):
        raise EmbeddingBackendError("Ollama returned an unexpected number of embeddings")
    normalized = []
    for vector in vectors:
        try:
            if len(vector) != DIMENSIONS:
                raise EmbeddingBackendError(f"Embedding has {len(vector)} dimensions, expected {DIMENSIONS}")
            norm = math.sqrt(sum(x * x for x in vector))
            if not math.isfinite(norm) or norm == 0:
                raise EmbeddingBackendError("Embedding has invalid norm")
            normalized.append([x / norm for x in vector])
        except (TypeError, ValueError) as exc:
            raise EmbeddingBackendError(f"Invalid embedding: {exc}") from exc
    return normalized


def embed_document(text: str) -> list[float]:
    return embed_documents([text])[0]


def embed_query(text: str) -> list[float]:
    return embed_documents([QUERY_INSTRUCTION + text])[0]


def vec_to_bytes(vec: list[float]) -> bytes:
    return struct.pack(f"<{len(vec)}f", *vec)
