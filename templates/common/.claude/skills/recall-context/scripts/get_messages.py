import sqlite3, json, sys
db, sid, limit = sys.argv[1], sys.argv[2], int(sys.argv[3])
conn = sqlite3.connect(db)
conn.row_factory = sqlite3.Row
rows = conn.execute('SELECT role, content FROM messages WHERE session_id = ? ORDER BY id ASC LIMIT ?', (sid, limit)).fetchall()
print(json.dumps([dict(r) for r in rows]))
conn.close()
