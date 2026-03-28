import sqlite3, json, sys
db, project = sys.argv[1], sys.argv[2]
conn = sqlite3.connect(db)
conn.row_factory = sqlite3.Row
rows = conn.execute('SELECT id, name, summary, started_at, last_synced_at FROM sessions WHERE project_path = ? ORDER BY started_at DESC LIMIT 50', (project,)).fetchall()
print(json.dumps([dict(r) for r in rows]))
conn.close()
