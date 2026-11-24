import importlib.util
import os
from pathlib import Path
import sqlite3
import sys
import types

import pytest


SCRIPTS = Path(__file__).resolve().parents[1] / "skills" / "wiki-setup" / "scripts"


def load_embeddings():
    path = Path(os.environ.get("RADIANT_TEST_EMBEDDINGS", SCRIPTS / "embeddings.py"))
    spec = importlib.util.spec_from_file_location("radiant_test_embeddings", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_document_and_query_use_qwen_retrieval_format(monkeypatch):
    calls = []

    class Vector:
        def tolist(self):
            return [0.0] * 1024

    class Model:
        def __init__(self, name, **kwargs):
            calls.append((name, kwargs))

        def encode(self, text, **kwargs):
            calls.append((text, kwargs))
            return Vector()

    monkeypatch.setitem(sys.modules, "sentence_transformers", types.SimpleNamespace(SentenceTransformer=Model))
    monkeypatch.setenv("RADIANT_EMBED_DEVICE", "cpu")
    emb = load_embeddings()
    assert len(emb.embed_document("document")) == 1024
    assert len(emb.embed_query("question")) == 1024
    assert calls == [
        ("Qwen/Qwen3-Embedding-0.6B", {"device": "cpu"}),
        ("document", {"normalize_embeddings": True}),
        ("Instruct: Given a web search query, retrieve relevant passages that answer the query\nQuery: question", {"normalize_embeddings": True}),
    ]


def test_default_device_is_mps(monkeypatch):
    calls = []
    monkeypatch.delenv("RADIANT_EMBED_DEVICE", raising=False)
    monkeypatch.setitem(sys.modules, "sentence_transformers", types.SimpleNamespace(
        SentenceTransformer=lambda name, **kwargs: calls.append((name, kwargs)) or object()
    ))
    load_embeddings().load_embedding_model()
    assert calls == [("Qwen/Qwen3-Embedding-0.6B", {"device": "mps"})]


def test_old_index_is_rejected_before_indexing(tmp_path, monkeypatch):
    path = tmp_path / "vault.db"
    conn = sqlite3.connect(path)
    conn.execute('CREATE TABLE vec_documents (embedding "float[768]")')
    conn.close()
    monkeypatch.setitem(sys.modules, "sqlite_vec", types.SimpleNamespace(load=lambda conn: None))
    monkeypatch.setitem(sys.modules, "embeddings", load_embeddings())
    index_path = Path(os.environ.get("RADIANT_TEST_INDEX", SCRIPTS / "index.py"))
    spec = importlib.util.spec_from_file_location("radiant_test_index", index_path)
    index = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(index)
    with pytest.raises(SystemExit, match="another embedding dimension"):
        index.init_db(path)
