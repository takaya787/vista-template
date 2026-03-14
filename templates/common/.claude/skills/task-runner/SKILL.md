---
name: task-runner
description: Execute a single pending task from a .ai/tasks/ queue file autonomously. Invoked by the watcher process (watch.sh) via `claude -p`. Reads the task description, marks it in-progress, executes the work, then marks it done. Do NOT trigger from interactive user sessions — this skill is designed for headless autonomous execution.
---

# Task Runner

watcher プロセスから `claude -p` 経由で呼び出される自律実行スキル。
`.ai/tasks/*.md` のキューから1タスクを取り出し、実行し、完了を記録する。

## Steps

### Step 1: タスクを特定する

呼び出しプロンプトからファイルパスとタスク slug を読み取る。
指定がない場合は `.ai/tasks/*.md` を走査し、最初の `[ ]` エントリを取得する。

タスクエントリの形式:
```
## [ ] {slug}
{説明}
完了基準: {基準}
```

### Step 2: In Progress にマークする

タスクファイルの該当行を更新する（他のプロセスが同じタスクを重複実行しないよう、実行前に即座に行う）:

```
## [ ] {slug}  →  ## [~] {slug}
```

### Step 3: タスクを実行する

説明と完了基準を読み、コードベースを必要に応じて探索して実装する。

**複雑さの判断 (task-triage.md に準拠):**
- Simple (0pt): そのまま実行
- PLAN (1pt+): 計画を立ててから実行。ユーザー確認は不要 — 自律実行のため自己承認で進める

**実行上の注意:**
- 完了基準を常に念頭に置く — それが「完了」の定義
- 変更はコミットしない（watcher 側の責務）
- 予期しないエラーや設計判断が必要な場合は後述の Step 4b へ

### Step 4a: 完了 → Done にマークする

実装が完了し完了基準を満たしたら、タスクファイルを更新:

```
## [~] {slug}  →  ## [x] {slug}
{説明}
完了基準: {基準}
完了: {YYYY-MM-DD}  ← 追記
```

### Step 4b: 失敗 → Blocked にマークする

実行できない理由がある場合（設計判断が必要・依存タスク未完了・情報不足等）:

```
## [~] {slug}  →  ## [!] {slug}
{説明}
完了基準: {基準}
ブロック理由: {理由を1行で}  ← 追記
```

ステータス一覧:
| マーカー | 意味 |
|---------|------|
| `[ ]` | Pending — 未実行 |
| `[~]` | In Progress — 実行中 |
| `[x]` | Done — 完了 |
| `[!]` | Blocked — 実行不能（理由を記載） |
