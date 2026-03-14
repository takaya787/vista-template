#!/usr/bin/env bash
# .ai/tasks/ を監視し、pending タスクを claude -p で自律実行する watcher
#
# 使い方:
#   bash .claude/skills/task-runner/scripts/watch.sh
#
# 環境変数:
#   TASKS_DIR   タスクディレクトリ (デフォルト: .ai/tasks)
#   INTERVAL    ポーリング間隔(秒) (デフォルト: 30)
#   ALLOWED_TOOLS  claude に渡すツール許可リスト

set -euo pipefail

TASKS_DIR="${TASKS_DIR:-.ai/tasks}"
INTERVAL="${INTERVAL:-30}"
ALLOWED_TOOLS="${ALLOWED_TOOLS:-"Read,Edit,Write,Bash,Glob,Grep,Agent"}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# プロジェクトルートへ移動（スクリプトの位置に関わらず）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

log "Task watcher started. Watching: $TASKS_DIR  interval: ${INTERVAL}s"

while true; do
  found=0

  for file in "$TASKS_DIR"/*.md; do
    [[ -f "$file" ]] || continue

    # 最初の [ ] エントリを探す
    slug=$(grep -m1 "^## \[ \]" "$file" 2>/dev/null | sed 's/^## \[ \] //' || true)

    if [[ -n "$slug" ]]; then
      log "Pending task found: [$slug] in $file"

      # claude -p でタスクを自律実行
      claude -p \
        --allowedTools "$ALLOWED_TOOLS" \
        "task-runner スキルを使い、${file} の「${slug}」タスクを実行してください"

      log "Task finished: [$slug]"
      found=1
      break  # 1タスク処理後は先頭から再スキャン
    fi
  done

  if [[ $found -eq 0 ]]; then
    sleep "$INTERVAL"
  fi
done
