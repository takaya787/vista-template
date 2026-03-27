#!/usr/bin/env python3
"""
Tests for templates/common/scripts/vista-sync-history.py

Usage:
    python3 scripts/test/test_vista_sync_history.py
"""

import importlib.util
import os
import sqlite3
import sys
import tempfile
from pathlib import Path

# ---------------------------------------------------------------------------
# Load module (filename has a hyphen, so importlib is required)
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).parent.parent.parent
SCRIPT = REPO_ROOT / "templates" / "common" / "scripts" / "vista-sync-history.py"
FIXTURES = Path(__file__).parent / "fixtures"

spec = importlib.util.spec_from_file_location("vista_sync_history", SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

FAILURES = []


def ok(name: str):
    print(f"  PASS  {name}")


def fail(name: str, msg: str):
    print(f"  FAIL  {name}: {msg}")
    FAILURES.append(name)


def make_db(path=":memory:"):
    """Return a connection with schema v1 applied."""
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    mod._migrate(conn, 0)
    return conn


# ---------------------------------------------------------------------------
# extract_session_meta
# ---------------------------------------------------------------------------

def test_extract_session_meta_found():
    name = "extract_session_meta: name and summary found"
    n, s = mod.extract_session_meta(FIXTURES / "session_with_title.jsonl")
    if n != "テストセッション":
        fail(name, f"expected name='テストセッション', got {n!r}")
        return
    if s != "A test conversation":
        fail(name, f"expected summary='A test conversation', got {s!r}")
        return
    ok(name)


def test_extract_session_meta_missing():
    name = "extract_session_meta: returns (None, None) when absent"
    n, s = mod.extract_session_meta(FIXTURES / "session_noise.jsonl")
    if n is not None:
        fail(name, f"expected name=None, got {n!r}")
        return
    if s is not None:
        fail(name, f"expected summary=None, got {s!r}")
        return
    ok(name)


# ---------------------------------------------------------------------------
# is_real_message
# ---------------------------------------------------------------------------

def test_is_real_message_noise():
    name = "is_real_message: noise patterns return False"
    cases = [
        ("", "user"),
        ("<local-command-caveat>x</local-command-caveat>", "user"),
        ("<command-name>clear</command-name>", "user"),
        ("# /clear", "user"),
        ("Base directory for this skill: /foo", "user"),
        ("Caveat: The messages below were generated", "user"),
    ]
    for text, role in cases:
        if mod.is_real_message(text, role):
            fail(name, f"expected False for {text!r}")
            return
    ok(name)


def test_is_real_message_real():
    name = "is_real_message: real messages return True"
    cases = [
        ("Hello world", "user"),
        ("日本語のメッセージ", "user"),
        ("Assistant response", "assistant"),
        ("<local-command-caveat>x</local-command-caveat>", "assistant"),  # only user is filtered
    ]
    for text, role in cases:
        if not mod.is_real_message(text, role):
            fail(name, f"expected True for role={role!r} text={text!r}")
            return
    ok(name)


# ---------------------------------------------------------------------------
# parse_messages
# ---------------------------------------------------------------------------

def test_parse_messages_basic():
    name = "parse_messages: parses user and assistant messages"
    msgs = mod.parse_messages(FIXTURES / "session_with_title.jsonl")
    if len(msgs) != 2:
        fail(name, f"expected 2 messages, got {len(msgs)}")
        return
    if msgs[0]["role"] != "user" or msgs[0]["content"] != "Hello":
        fail(name, f"unexpected first message: {msgs[0]}")
        return
    if msgs[1]["role"] != "assistant" or msgs[1]["content"] != "Hi!":
        fail(name, f"unexpected second message: {msgs[1]}")
        return
    ok(name)


def test_parse_messages_list_content():
    name = "parse_messages: list content concatenates text blocks"
    msgs = mod.parse_messages(FIXTURES / "session_list_content.jsonl")
    if len(msgs) != 2:
        fail(name, f"expected 2 messages, got {len(msgs)}")
        return
    expected = "リスト形式のコンテンツ\n続き"
    if msgs[0]["content"] != expected:
        fail(name, f"expected {expected!r}, got {msgs[0]['content']!r}")
        return
    ok(name)


def test_parse_messages_noise_filtered():
    name = "parse_messages: noise, sidechain, and summary entries are excluded"
    msgs = mod.parse_messages(FIXTURES / "session_noise.jsonl")
    # Only the 2 real messages should survive
    if len(msgs) != 2:
        fail(name, f"expected 2 messages, got {len(msgs)}: {msgs}")
        return
    if msgs[0]["content"] != "日本語で質問する":
        fail(name, f"unexpected first message: {msgs[0]}")
        return
    if msgs[1]["content"] != "日本語で回答します":
        fail(name, f"unexpected second message: {msgs[1]}")
        return
    ok(name)


# ---------------------------------------------------------------------------
# Schema / migration
# ---------------------------------------------------------------------------

def test_schema_migration():
    name = "schema: tables created, FTS uses trigram, user_version=1"
    conn = make_db()
    # user_version
    ver = conn.execute("PRAGMA user_version").fetchone()[0]
    if ver != mod.SCHEMA_VERSION:
        fail(name, f"user_version={ver}, expected {mod.SCHEMA_VERSION}")
        return
    # tables exist
    tables = {r[0] for r in conn.execute("SELECT name FROM sqlite_master WHERE type IN ('table','shadow')")}
    for t in ("sessions", "messages"):
        if t not in tables:
            fail(name, f"table {t!r} not found")
            return
    # FTS tokenizer is trigram
    fts_sql = conn.execute(
        "SELECT sql FROM sqlite_master WHERE name='messages_fts'"
    ).fetchone()
    if not fts_sql or "trigram" not in fts_sql[0].lower():
        fail(name, f"messages_fts does not use trigram: {fts_sql}")
        return
    ok(name)


# ---------------------------------------------------------------------------
# sync() integration
# ---------------------------------------------------------------------------

def _run_sync_with_fixture(fixture_path: Path, db_path: Path, session_uuid: str):
    """Patch mod state, run sync() with a given fixture JSONL, restore."""
    original_db = mod.DB_PATH
    original_find = mod.find_jsonl

    mod.DB_PATH = db_path
    mod.find_jsonl = lambda _dir: fixture_path

    # sync() reads CLAUDE_PROJECT_DIR from env
    env_backup = os.environ.get("CLAUDE_PROJECT_DIR")
    os.environ["CLAUDE_PROJECT_DIR"] = "/test/project"
    try:
        mod.sync()
    finally:
        mod.DB_PATH = original_db
        mod.find_jsonl = original_find
        if env_backup is None:
            os.environ.pop("CLAUDE_PROJECT_DIR", None)
        else:
            os.environ["CLAUDE_PROJECT_DIR"] = env_backup


def test_sync_integration():
    name = "sync: writes session and messages to DB"
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = Path(f.name)
    try:
        fixture = FIXTURES / "session_with_title.jsonl"
        uuid = fixture.stem  # "session_with_title"

        _run_sync_with_fixture(fixture, db_path, uuid)

        conn = sqlite3.connect(str(db_path))
        session = conn.execute("SELECT name, summary, project_path FROM sessions WHERE id=?", (uuid,)).fetchone()
        if session is None:
            fail(name, "session not inserted")
            return
        if session[0] != "テストセッション":
            fail(name, f"name={session[0]!r}, expected 'テストセッション'")
            return
        if session[1] != "A test conversation":
            fail(name, f"summary={session[1]!r}, expected 'A test conversation'")
            return
        if session[2] != "/test/project":
            fail(name, f"project_path={session[2]!r}")
            return
        count = conn.execute("SELECT COUNT(*) FROM messages WHERE session_id=?", (uuid,)).fetchone()[0]
        if count != 2:
            fail(name, f"expected 2 messages, got {count}")
            return
        conn.close()
        ok(name)
    finally:
        db_path.unlink(missing_ok=True)


def test_sync_incremental():
    name = "sync: second run adds only new messages"
    with tempfile.NamedTemporaryFile(suffix=".db", delete=False) as f:
        db_path = Path(f.name)
    try:
        fixture = FIXTURES / "session_with_title.jsonl"
        uuid = fixture.stem

        # First sync
        _run_sync_with_fixture(fixture, db_path, uuid)
        # Second sync (same fixture = no new messages)
        _run_sync_with_fixture(fixture, db_path, uuid)

        conn = sqlite3.connect(str(db_path))
        count = conn.execute("SELECT COUNT(*) FROM messages WHERE session_id=?", (uuid,)).fetchone()[0]
        conn.close()
        if count != 2:
            fail(name, f"expected 2 messages after 2 syncs, got {count}")
            return
        ok(name)
    finally:
        db_path.unlink(missing_ok=True)


# ---------------------------------------------------------------------------
# FTS Japanese search
# ---------------------------------------------------------------------------

def test_fts_japanese_search():
    name = "FTS: trigram finds Japanese text and ORDER BY rank returns high-relevance first"
    conn = make_db()
    sid = "test-session"
    ts = "2024-01-01T00:00:00Z"
    conn.execute(
        "INSERT INTO sessions (id, project_path, started_at) VALUES (?, ?, ?)",
        (sid, "/test", ts),
    )
    # low_rel: search term appears once
    # high_rel: search term appears three times → higher BM25 score
    low_rel  = "日本語で一度だけ言及する文章"
    high_rel = "日本語の日本語に関する日本語のドキュメント"
    conn.execute(
        "INSERT INTO messages (session_id, role, content, created_at) VALUES (?,?,?,?)",
        (sid, "user", low_rel, ts),
    )
    conn.execute(
        "INSERT INTO messages (session_id, role, content, created_at) VALUES (?,?,?,?)",
        (sid, "user", high_rel, ts),
    )
    conn.commit()

    rows = conn.execute(
        "SELECT content FROM messages_fts WHERE messages_fts MATCH ? ORDER BY rank",
        ("日本語",),
    ).fetchall()
    conn.close()

    if len(rows) != 2:
        fail(name, f"expected 2 hits, got {len(rows)}")
        return
    # ORDER BY rank: most relevant (high_rel) comes first
    if rows[0][0] != high_rel:
        fail(name, f"expected high-relevance message first, got: {rows[0][0]!r}")
        return
    ok(name)


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def main():
    print(f"Running tests for {SCRIPT.name}\n")
    tests = [
        test_extract_session_meta_found,
        test_extract_session_meta_missing,
        test_is_real_message_noise,
        test_is_real_message_real,
        test_parse_messages_basic,
        test_parse_messages_list_content,
        test_parse_messages_noise_filtered,
        test_schema_migration,
        test_sync_integration,
        test_sync_incremental,
        test_fts_japanese_search,
    ]
    for t in tests:
        try:
            t()
        except Exception as e:
            fail(t.__name__, f"raised {type(e).__name__}: {e}")

    print()
    if FAILURES:
        print(f"FAIL: {len(FAILURES)}/{len(tests)} tests failed")
        sys.exit(1)
    else:
        print(f"PASS: all {len(tests)} tests passed")


if __name__ == "__main__":
    main()
