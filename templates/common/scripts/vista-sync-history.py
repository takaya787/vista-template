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


def _load_schema(version):
    """Load SQL from the versioned schema file next to this script."""
    sql_path = Path(__file__).parent / f"vista-sync-history-schema-v{version}.sql"
    return sql_path.read_text(encoding="utf-8")


def _migrate(conn, current_version):
    """Apply schema migrations from current_version up to SCHEMA_VERSION."""
    if current_version < 1:
        conn.executescript(_load_schema(1))

    # Add future migrations here:
    # if current_version < 2:
    #     conn.execute("ALTER TABLE ...")

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


def extract_session_meta(jsonl_path):
    """Scan all lines for customTitle and summary (present in type=summary entries).

    Returns (name, summary) tuple.
    """
    name = None
    summary = None
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
                if name is None:
                    name = obj.get("customTitle")
                if summary is None:
                    summary = obj.get("summary")
                if name and summary:
                    break
    except Exception:
        pass
    return name, summary


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
    name, summary = extract_session_meta(jsonl_path)
    stat = jsonl_path.stat()
    started_at = datetime.fromtimestamp(
        stat.st_birthtime if hasattr(stat, "st_birthtime") else stat.st_ctime,
        tz=timezone.utc,
    ).isoformat()

    conn = get_db()
    try:
        conn.execute("""
            INSERT INTO sessions (id, project_path, name, summary, started_at, last_synced_at)
            VALUES (?, ?, ?, ?, ?, ?)
            ON CONFLICT(id) DO UPDATE SET
                name           = excluded.name,
                summary        = excluded.summary,
                last_synced_at = excluded.last_synced_at
        """, (uuid, project_path, name, summary, started_at, datetime.now(timezone.utc).isoformat()))

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
