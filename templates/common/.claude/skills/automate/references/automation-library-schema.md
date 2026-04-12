# automation-library.json — Schema Reference

**File location:** `~/.vista/automation-library.json`

This file is the single source of truth for all registered `com.vista.*` automations. It links LaunchAgents back to their source workspace, task-master tasks, and PRD.

---

## Top-level structure

```json
{
  "entries": [AutomationEntry]
}
```

---

## AutomationEntry schema

```json
{
  "label":         "com.vista.{slug}",
  "plist":         "~/Library/LaunchAgents/com.vista.{slug}.plist",
  "working_dir":   "/Users/{user}/private/{user}/{workspace}",
  "scripts":       ["scripts/{slug}/main.py"],
  "schedule":      "毎日 09:00",
  "cron":          "0 9 * * *",
  "status":        "active",
  "registered_at": "2026-04-10T09:00:00+09:00",
  "description":   "何をするエージェントか（日本語で具体的に）",
  "registered_by": "claude-code",
  "task_ids":      ["15", "16", "17"],
  "prd_path":      ".taskmaster/docs/2026-04-10-{slug}.md",
  "manifest_path": ".taskmaster/automations/{slug}/manifest.json"
}
```

---

## Field definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `label` | string | ✅ | LaunchAgent label。必ず `com.vista.` で始まる |
| `plist` | string | ✅ | plistの絶対パス（`~` 表記可） |
| `working_dir` | string | ✅ | スクリプトを実行するワークスペースの絶対パス |
| `scripts` | string[] | ✅ | 実行される全スクリプトの絶対パス |
| `schedule` | string | ✅ | 人間可読なスケジュール（例: `毎日 09:00`、`毎週月曜 08:30`） |
| `cron` | string | ✅ **必須** | 標準 cron 式 5フィールド（`分 時 日 月 曜日`）。例: `"0 9 * * *"`（毎日9時）、`"0 11 * * 4"`（毎週木曜11時） |
| `status` | string | ✅ | `active` / `disabled` / `error` のいずれか |
| `registered_at` | string | ✅ | ISO 8601 形式の登録日時 |
| `description` | string | ✅ | 何をするエージェントか。日本語で具体的に |
| `registered_by` | string | ✅ | 登録者（通常 `claude-code`） |
| `task_ids` | string[] | ✅ | 対応する task-master のタスクID一覧。不明な場合は `[]` |
| `prd_path` | string | ✅ | 元PRDファイルへの `working_dir` からの相対パス。不明な場合は `""` |
| `manifest_path` | string | ✅ | automateスキルのmanifestへの `working_dir` からの相対パス。不明な場合は `""` |

### `cron` フィールドの書き方

```
┌───── 分   (0-59)
│ ┌─── 時   (0-23)
│ │ ┌─ 日   (1-31)  * = 毎日
│ │ │ ┌ 月   (1-12)  * = 毎月
│ │ │ │ ┌ 曜日 (0=日, 1=月, 2=火, 3=水, 4=木, 5=金, 6=土)  * = 毎日
│ │ │ │ │
0 9 * * *    毎日 09:00
0 11 * * 4   毎週木曜日 11:00
30 8 * * 1   毎週月曜日 08:30
0 9 1 * *    毎月1日 09:00
```

---

## `scripts` フィールドの設計方針

- **絶対パス**を使う（1フィールドで自己完結し、参照時に `working_dir` との結合が不要）
- `scripts[0]` は常に `run_script.sh` の絶対パス（エントリポイントの統一規約）
- venv のパスは含めない（`run_script.sh` 内で `source tmp/venv/bin/activate` を処理する）
- 補助スクリプト（`main.py` 等）は `scripts[1+]` に列挙する

```json
// Good — scripts[0] は必ず run_script.sh
"scripts": [
  "/Users/takaya787/private/takaya787/vista-marketing-owner/scripts/slack-report/run_script.sh",
  "/Users/takaya787/private/takaya787/vista-marketing-owner/scripts/slack-report/main.py"
]

// Bad — run_script.sh を経由しない、venvパスを含む
"scripts": ["/Users/takaya787/.../tmp/venv/bin/python scripts/main.py"]
```

plist の `ProgramArguments` は `run_script.sh` を直接呼ぶだけでよい（venv activation は `run_script.sh` 内で完結）:

```xml
<array>
  <string>/bin/bash</string>
  <string>/path/to/working/dir/scripts/{slug}/run_script.sh</string>
</array>
```

`run_script.sh` のテンプレートは `script-conventions.md` を参照。

---

## `status` の遷移

```
active   ←→ disabled   (手動で停止・再開)
active    →  error      (launchctlのexit codeが非ゼロ、またはエラーログ検出時)
error     →  active     (スクリプト修正・再登録後)
```

---

## workspace パスの慣例

Vista プロジェクトのワークスペースは以下のパターンに従う:

```
/Users/{user}/private/{user}/{workspace-name}/
```

例:
- `/Users/takaya787/private/takaya787/vista-marketing-owner/`
- `/Users/takaya787/private/takaya787/test-template-exec/test-0-3-10/`

`working_dir` は必ずこのルール下の絶対パスを使うこと。

---

## 完全な例

```json
{
  "entries": [
    {
      "label": "com.vista.google-calendar-meeting-notify",
      "plist": "~/Library/LaunchAgents/com.vista.google-calendar-meeting-notify.plist",
      "working_dir": "/Users/takaya787/private/takaya787/test-template-exec/test-0-3-10",
      "scripts": ["/Users/takaya787/private/takaya787/test-template-exec/test-0-3-10/scripts/google-calendar-meeting-notify/main.py"],
      "schedule": "毎日 10:00",
      "cron": "0 10 * * *",
      "status": "active",
      "registered_at": "2026-04-10T00:00:00+09:00",
      "description": "Googleカレンダー（ICS URL）から当日の会議予定を取得し、Slackに通知する。毎日10時に実行。",
      "registered_by": "claude-code",
      "task_ids": [],
      "prd_path": "",
      "manifest_path": ""
    }
  ]
}
```
