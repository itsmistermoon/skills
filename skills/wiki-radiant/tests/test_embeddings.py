import importlib.util
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sqlite3
import threading

import pytest

SCRIPTS = Path(__file__).resolve().parents[1] / 'skills' / 'wiki-setup' / 'scripts'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_ollama_formats_and_normalizes_documents_and_query(monkeypatch):
    calls = []
    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            calls.append((self.path, json.loads(self.rfile.read(int(self.headers['Content-Length'])))))
            vectors = [[3.0, 4.0] + [0.0] * 1022 for _ in calls[-1][1]['input']]
            data = json.dumps({'embeddings': vectors}).encode()
            self.send_response(200)
            self.end_headers()
            self.wfile.write(data)
        def log_message(self, *args):
            pass
    server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    monkeypatch.setenv('OLLAMA_HOST', f'http://127.0.0.1:{server.server_port}')
    try:
        emb = load('test_emb', Path(os.environ.get('RADIANT_TEST_EMBEDDINGS', SCRIPTS / 'embeddings.py')))
        assert emb.embed_documents(['one', 'two'])[0][:2] == pytest.approx([0.6, 0.8])
        assert emb.embed_query('question')[:2] == pytest.approx([0.6, 0.8])
        assert calls == [('/api/embed', {'model': 'qwen3-embedding:0.6b', 'input': ['one', 'two']}),
                         ('/api/embed', {'model': 'qwen3-embedding:0.6b', 'input': [emb.QUERY_INSTRUCTION + 'question']})]
    finally:
        server.shutdown()
        server.server_close()


def test_old_index_is_rejected(tmp_path):
    path = tmp_path / 'vault.db'
    with sqlite3.connect(path) as conn:
        conn.execute('CREATE TABLE vec_documents (embedding BLOB)')
    index = load('test_index', SCRIPTS / 'index.py')
    with pytest.raises(SystemExit, match='reindex'):
        index.init_db(path)


def test_search_ranks_by_cosine_and_groups_pages(tmp_path):
    index = load('test_index_ranking', SCRIPTS / 'index.py')
    search = load('test_search', SCRIPTS.parent.parent / 'wiki-query' / 'scripts' / 'search.py')
    emb = load('test_vectors', SCRIPTS / 'embeddings.py')
    conn = index.init_db(tmp_path / 'vault.db')
    for path, vector in [('a.md', [0.8, 0.6]), ('b.md', [1.0, 0.0]), ('b.md', [0.9, 0.4358899])]:
        conn.execute('INSERT INTO documents (path, heading, chunk_index, content, file_hash, updated_at, embedding) VALUES (?, NULL, 0, ?, ?, ?, ?)',
                     (path, path, 'hash', 'now', emb.vec_to_bytes(vector + [0.0] * 1022)))
    results = search.search(conn, emb.vec_to_bytes([1.0] + [0.0] * 1023), 3, 1.0)
    assert [r['path'] for r in results] == ['b.md', 'a.md']
    assert [r['distance'] for r in results] == pytest.approx([0, 0.2])
