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


def test_rebuilt_index_uses_default_threshold_when_calibration_is_skipped(tmp_path):
    index = load('test_index_rebuild', SCRIPTS / 'index.py')
    search = load('test_search_rebuild', SCRIPTS.parent.parent / 'wiki-query' / 'scripts' / 'search.py')
    config = tmp_path / 'config.json'
    config.write_text(json.dumps({'distance_threshold': 0.1, 'other': 'keep'}))
    conn = index.init_db(tmp_path / 'vault.db')
    index.calibrate(conn, tmp_path, config)
    conn.close()
    assert search.load_threshold(tmp_path) == 0.5
    assert json.loads(config.read_text())['other'] == 'keep'


def test_index_allows_concurrent_writes_while_waiting_for_ollama(tmp_path, monkeypatch):
    index = load('test_index_concurrency', SCRIPTS / 'index.py')
    vault = tmp_path / 'vault'
    vault.mkdir()
    page = vault / 'page.md'
    page.write_text('Content to index')
    db = tmp_path / 'vault.db'
    conn = index.init_db(db)
    def embed(texts):
        with sqlite3.connect(db, timeout=0.1) as other:
            other.execute("DELETE FROM documents WHERE path = 'another.md'")
        return [[1.0] + [0.0] * 1023 for _ in texts]
    monkeypatch.setattr(index.emb, 'embed_documents', embed)
    index.index_file(conn, vault, page)
    assert conn.execute('SELECT content FROM documents').fetchone() == ('Content to index',)
    conn.close()


def test_setup_check_accepts_ollama_host_without_scheme(tmp_path):
    import subprocess
    setup = (SCRIPTS.parent / 'references' / 'EMBEDDING-SETUP.md').read_text()
    command = setup.split('```bash\n', 1)[1].split('\n```', 1)[0]
    curl = tmp_path / 'curl'
    curl.write_text('#!/bin/sh\nprintf "%s" "$2" > "$CAPTURE"\nprintf \'{"models": [{"name": "qwen3-embedding:0.6b"}]}\'\n')
    curl.chmod(0o755)
    capture = tmp_path / 'url'
    env = {**os.environ, 'PATH': f'{tmp_path}:{os.environ["PATH"]}',
           'OLLAMA_HOST': 'localhost:11434', 'CAPTURE': str(capture)}
    subprocess.run(['bash', '-o', 'pipefail', '-c', command], env=env, check=True, capture_output=True)
    assert capture.read_text() == 'http://localhost:11434/api/tags'
