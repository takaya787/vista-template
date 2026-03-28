#!/usr/bin/env python3
"""
Query conversation history from ~/.vista/history/conversations.db.

Usage:
  python3 query_history.py --project-path <path> [--query <keyword>] [--limit <n>] [--mode summary|detail]

Modes:
  summary  - Session list with message counts (default)
  detail   - Full messages from matched sessions

Search:
  --query uses FTS5 full-text search on message content.
  Without --query, returns the most recent sessions.
"""

import argparse
import json
import os
import sqlite3
import sys
from pathlib import Path

DB_PATH = Path.home() / ".vista" / "history" / "conversations.db"


def get_connection():
    if not DB_PATH.exists():
        print(json.dumps({"error": "conversations.db not found"}))
        sys.exit(1)
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn


def search_sessions_by_keyword(conn, project_path: str, query: str, limit: int):
    """FTS keyword search across messages, scoped to project."""
    sql = """
        SELECT DISTINCT s.id, s.name, s.summary, s.started_at, s.last_synced_at,
               snippet(messages_fts, 0, '>>>', '<<<', '...', 40) AS snippet
        FROM messages_fts
        JOIN messages m ON m.id = messages_fts.rowid
        JOIN sessions s ON s.id = m.session_id
        WHERE messages_fts MATCH ?
          AND s.project_path = ?
        ORDER BY rank
        LIMIT ?
    """
    return conn.execute(sql, (query, project_path, limit)).fetchall()


def get_recent_sessions(conn, project_path: str, limit: int):
    """Get most recent sessions for a project."""
    sql = """
        SELECT s.id, s.name, s.summary, s.started_at, s.last_synced_at,
               (SELECT COUNT(*) FROM messages m WHERE m.session_id = s.id) AS msg_count
        FROM sessions s
        WHERE s.project_path = ?
        ORDER BY s.started_at DESC
        LIMIT ?
    """
    return conn.execute(sql, (project_path, limit)).fetchall()


def get_session_messages(conn, session_id: str):
    """Get all messages for a session."""
    sql = """
        SELECT role, content, created_at
        FROM messages
        WHERE session_id = ?
        ORDER BY created_at ASC
    """
    return conn.execute(sql, (session_id,)).fetchall()


def get_keyword_matched_messages(conn, project_path: str, query: str, limit: int):
    """Get messages matching keyword search with surrounding context."""
    sql = """
        SELECT m.session_id, s.name, s.summary, s.started_at,
               m.role, m.content, m.created_at,
               snippet(messages_fts, 0, '>>>', '<<<', '...', 60) AS snippet
        FROM messages_fts
        JOIN messages m ON m.id = messages_fts.rowid
        JOIN sessions s ON s.id = m.session_id
        WHERE messages_fts MATCH ?
          AND s.project_path = ?
        ORDER BY rank
        LIMIT ?
    """
    return conn.execute(sql, (query, project_path, limit)).fetchall()


def format_summary(sessions, query=None):
    """Format session list as structured context."""
    result = []
    for s in sessions:
        entry = {
            "session_id": s["id"],
            "title": s["name"] or "(unnamed)",
            "summary": s["summary"],
            "started_at": s["started_at"],
        }
        if query and "snippet" in s.keys():
            entry["matched_snippet"] = s["snippet"]
        else:
            entry["message_count"] = s["msg_count"]
        result.append(entry)
    return result


def format_detail_keyword(messages):
    """Format keyword-matched messages as context."""
    result = []
    for m in messages:
        result.append({
            "session": m["name"] or m["session_id"][:8],
            "session_summary": m["summary"],
            "session_started": m["started_at"],
            "role": m["role"],
            "content": m["content"][:1000],
            "snippet": m["snippet"],
            "timestamp": m["created_at"],
        })
    return result


def format_detail_recent(conn, sessions):
    """Format recent session messages as context."""
    result = []
    for s in sessions:
        msgs = get_session_messages(conn, s["id"])
        session_data = {
            "session": s["name"] or s["id"][:8],
            "summary": s["summary"],
            "started_at": s["started_at"],
            "messages": [],
        }
        for m in msgs:
            session_data["messages"].append({
                "role": m["role"],
                "content": m["content"][:1000],
                "timestamp": m["created_at"],
            })
        result.append(session_data)
    return result


def main():
    parser = argparse.ArgumentParser(description="Query conversation history")
    parser.add_argument("--project-path", required=True, help="Project working directory")
    parser.add_argument("--query", default=None, help="FTS keyword search query")
    parser.add_argument("--limit", type=int, default=5, help="Max results")
    parser.add_argument("--mode", choices=["summary", "detail"], default="summary")
    args = parser.parse_args()

    conn = get_connection()

    try:
        if args.query:
            if args.mode == "detail":
                messages = get_keyword_matched_messages(conn, args.project_path, args.query, args.limit)
                output = {
                    "type": "keyword_detail",
                    "query": args.query,
                    "project": args.project_path,
                    "results": format_detail_keyword(messages),
                }
            else:
                sessions = search_sessions_by_keyword(conn, args.project_path, args.query, args.limit)
                output = {
                    "type": "keyword_summary",
                    "query": args.query,
                    "project": args.project_path,
                    "results": format_summary(sessions, query=args.query),
                }
        else:
            sessions = get_recent_sessions(conn, args.project_path, args.limit)
            if args.mode == "detail":
                output = {
                    "type": "recent_detail",
                    "project": args.project_path,
                    "results": format_detail_recent(conn, sessions),
                }
            else:
                output = {
                    "type": "recent_summary",
                    "project": args.project_path,
                    "results": format_summary(sessions),
                }

        print(json.dumps(output, ensure_ascii=False, indent=2))

    finally:
        conn.close()


if __name__ == "__main__":
    main()
