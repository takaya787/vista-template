#!/usr/bin/env python3
"""
vista-sync-history
Syncs the latest Claude Code JSONL session to ~/.vista/history/conversations.db.
Triggered by Claude Code Stop hook.

UUID discovery mirrors claude:registerSession in main.cjs:
  - Read direct children of ~/.claude/projects/{encoded-cwd}/ (non-recursive)
  - Filter *.jsonl files only (subagents live in {uuid}/subagents/ and are excluded)
  - Sort by mtime descending, pick the first (most recently modified)

Environment variables used:
  CLAUDE_PROJECT_DIR  - project working directory (falls back to cwd)
"""
import json
import os
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

DB_PATH = Path.home() / ".vista" / "history" / "conversations.db"

# Increment when the schema changes. Each version adds a migration in _migrate().
SCHEMA_VERSION = 1


def _migrate(conn, current_version):
    """Apply schema migrations from current_version up to SCHEMA_VERSION."""
    if current_version < 1:
        conn.executescript("""
            CREATE TABLE IF NOT EXISTS sessions (
                id              TEXT PRIMARY KEY,
                project_path    TEXT NOT NULL,
                title           TEXT,
                started_at      TEXT NOT NULL,
                last_synced_at  TEXT
            );
            CREATE INDEX IF NOT EXISTS idx_sessions_project ON sessions(project_path);

            CREATE TABLE IF NOT EXISTS messages (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id  TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
                role        TEXT NOT NULL CHECK(role IN ('user','assistant')),
                content     TEXT NOT NULL,
                created_at  TEXT NOT NULL,
                embedding   BLOB
            );
            CREATE INDEX IF NOT EXISTS idx_messages_session ON messages(session_id);
            CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at);

            CREATE VIRTUAL TABLE IF NOT EXISTS messages_fts USING fts5(
                content,
                role        UNINDEXED,
                session_id  UNINDEXED,
                content=messages,
                content_rowid=id,
                tokenize="trigram"
            );

            CREATE TRIGGER IF NOT EXISTS messages_fts_ai AFTER INSERT ON messages BEGIN
                INSERT INTO messages_fts(rowid, content, role, session_id)
                VALUES (new.id, new.content, new.role, new.session_id);
            END;
            CREATE TRIGGER IF NOT EXISTS messages_fts_ad AFTER DELETE ON messages BEGIN
                INSERT INTO messages_fts(messages_fts, rowid, content, role, session_id)
                VALUES ('delete', old.id, old.content, old.role, old.session_id);
            END;
        """)

    # Add future migrations here:
    # if current_version < 2:
    #     conn.execute("ALTER TABLE messages ADD COLUMN tokens INTEGER")

    conn.execute(f"PRAGMA user_version = {SCHEMA_VERSION}")
    conn.commit()
    if current_version < SCHEMA_VERSION:
        print(f"[vista-sync-history] schema migrated v{current_version} → v{SCHEMA_VERSION}")


def get_db():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH))
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    current_version = conn.execute("PRAGMA user_version").fetchone()[0]
    if current_version < SCHEMA_VERSION:
        _migrate(conn, current_version)
    return conn


def encode_path(p):
    return p.replace("/", "-").replace(".", "-").replace("_", "-")


def find_jsonl(project_dir):
    """Return the most recently modified root-level JSONL file.

    Uses the same logic as claude:registerSession in main.cjs:
      fs.readdirSync(projectDir).filter(f => f.endsWith('.jsonl'))
    iterdir() lists direct children only, so subagent files in
    {uuid}/subagents/ are never included.
    """
    files = [
        f for f in project_dir.iterdir()
        if f.is_file() and f.suffix == ".jsonl"
    ]
    files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
    return files[0] if files else None


def extract_title(jsonl_path):
    """Scan all lines for customTitle (present in type=summary entries)."""
    try:
        with open(jsonl_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                title = obj.get("customTitle")
                if title:
                    return title
    except Exception:
        pass
    return None


def is_real_message(text, role):
    if not text:
        return False
    if role == "user":
        if text.startswith("<local-command"):
            return False
        if text.startswith("<command-"):
            return False
        if "<command-name>" in text:
            return False
        if text.startswith("# /"):
            return False
        if text.startswith("Base directory for this skill:"):
            return False
        if text.startswith("Caveat: The messages below"):
            return False
    return True


def parse_messages(jsonl_path):
    messages = []
    try:
        with open(jsonl_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                if entry.get("type") == "summary":
                    continue
                if entry.get("isSidechain"):
                    continue

                msg = entry.get("message")
                if not msg:
                    continue
                role = msg.get("role")
                if role not in ("user", "assistant"):
                    continue

                content = msg.get("content", "")
                if isinstance(content, list):
                    text = "\n".join(
                        b.get("text", "") for b in content
                        if isinstance(b, dict) and b.get("type") == "text" and b.get("text")
                    )
                elif isinstance(content, str):
                    text = content
                else:
                    continue

                text = text.strip()
                if not text or not is_real_message(text, role):
                    continue

                ts = entry.get("timestamp") or datetime.now(timezone.utc).isoformat()
                messages.append({"role": role, "content": text, "created_at": ts})
    except Exception as e:
        print(f"[vista-sync-history] parse error: {e}", file=sys.stderr)
    return messages


def sync():
    # trigram tokenizer requires SQLite 3.34.0+
    if sqlite3.sqlite_version_info < (3, 34, 0):
        print(
            f"[vista-sync-history] SQLite {sqlite3.sqlite_version} is too old "
            f"(need >= 3.34.0 for trigram FTS). Skipping sync.",
            file=sys.stderr,
        )
        return

    project_path = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    encoded = encode_path(project_path)
    project_dir = Path.home() / ".claude" / "projects" / encoded

    jsonl_path = find_jsonl(project_dir)
    if not jsonl_path:
        return

    uuid = jsonl_path.stem
    title = extract_title(jsonl_path)
    stat = jsonl_path.stat()
    started_at = datetime.fromtimestamp(
        stat.st_birthtime if hasattr(stat, "st_birthtime") else stat.st_ctime,
        tz=timezone.utc,
    ).isoformat()

    conn = get_db()
    try:
        conn.execute("""
            INSERT INTO sessions (id, project_path, title, started_at, last_synced_at)
            VALUES (?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                title          = excluded.title,
                last_synced_at = excluded.last_synced_at
        """, (uuid, project_path, title, started_at, datetime.now(timezone.utc).isoformat()))

        (existing_count,) = conn.execute(
            "SELECT COUNT(*) FROM messages WHERE session_id = ?", (uuid,)
        ).fetchone()

        messages = parse_messages(jsonl_path)
        new_messages = messages[existing_count:]

        for msg in new_messages:
            conn.execute(
                "INSERT INTO messages (session_id, role, content, created_at) VALUES (?, ?, ?, ?)",
                (uuid, msg["role"], msg["content"], msg["created_at"])
            )

        conn.commit()
        if new_messages:
            print(f"[vista-sync-history] synced {len(new_messages)} new messages for {uuid[:8]}...")
    except Exception as e:
        conn.rollback()
        print(f"[vista-sync-history] db error: {e}", file=sys.stderr)
    finally:
        conn.close()


if __name__ == "__main__":
    sync()
