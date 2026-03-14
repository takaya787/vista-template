---
name: task-register
description: Register a task into a .ai/tasks/ queue file for autonomous AI execution by a watcher process. Use when the user says "/task-register", "このタスクを登録して", "後でAIにやらせたい", "自律タスクとして残しておいて", "バックグラウンドで進めておいて", "タスクキューに追加", or any phrase indicating they want to defer work to the AI. Also trigger when the user describes a feature, fix, or refactor and says they're not ready to execute it yet — proactively suggest registering it.
---

# Task Register

AI watcher プロセスが読み取り・実行するタスクキューファイル (`.ai/tasks/*.md`) にタスクエントリを追記するスキル。

## ファイル構造

1ファイル = 1トピック（複数タスクを格納）。ファイルは領域ごとに分ける:

```
.ai/tasks/
├── ui.md        # フロントエンド・UI 関連
├── backend.md   # バックエンド・API 関連
├── infra.md     # ビルド・CI・インフラ関連
└── (任意の名前).md
```

## タスクエントリ形式

```markdown
## [ ] {task-slug}
{1〜2行の説明。何を・どこで・なぜ}
完了基準: {1行で書ける確認方法}
```

ステータスマーカー（watcher と Claude Code が更新する）:
- `[ ]` — Pending（登録済み・未着手）
- `[~]` — In Progress（実行中）
- `[x]` — Done（完了）、末尾に `完了: YYYY-MM-DD` を追加

---

## Steps

### Step 1: ファイルを特定する

会話の文脈からトピックを判断し、追記先ファイルを決める。
既存ファイルが適切なら使い、なければ作成する。不明なときのみユーザーに確認する。

### Step 2: タスクエントリを生成する

以下の方針で簡潔に書く:
- **slug**: 動詞-目的語の kebab-case（例: `add-dark-mode`, `fix-auth-bug`）
- **説明**: 1〜2行。ファイルパスや機能名を具体的に含める
- **完了基準**: watcher が「終わった」と判断できる1行の基準

### Step 3: ファイルに追記する

対象ファイルの末尾にエントリを追記する。
ファイルが存在しない場合は以下のヘッダー付きで新規作成:

```markdown
# Tasks: {topic}

```

### Step 4: 完了を報告する

```
登録完了: .ai/tasks/{file}.md に追加
タスク: {slug}
```
