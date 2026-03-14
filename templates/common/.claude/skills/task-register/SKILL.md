---
name: task-register
description: Register a task into a .ai/tasks/ queue file for autonomous AI execution by a watcher process. Use when the user says "/task-register", "このタスクを登録して", "後でAIにやらせたい", "自律タスクとして残しておいて", "バックグラウンドで進めておいて", "タスクキューに追加", or any phrase indicating they want to defer work to the AI. Also trigger when the user describes a feature, fix, or refactor and says they're not ready to execute it yet — proactively suggest registering it.
---

# Task Register

AI watcher プロセスが読み取り・実行するタスクキューファイル (`.ai/tasks/*.md`) にタスクエントリを追記するスキル。

## CRITICAL: セッション境界ルール

このスキルが動作するセッションは **登録専用セッション** である。このセッションは `/task-register` を呼び出した後も、会話が続く限り登録専用の振る舞いを維持する。

```
┌─────────────────────────────┐     ┌──────────────────────────────┐
│  インタラクティブセッション   │     │  watcher セッション           │
│  (このスキルが動くセッション) │     │  (claude -p / watch.sh)       │
│                             │     │                               │
│  ✅ タスクの登録のみ          │────▶│  ✅ タスクの実行               │
│  ❌ 実装・コード変更          │     │  ✅ ステータス更新              │
│  ❌ Agent 起動               │     │  ✅ 完了マーク                 │
└─────────────────────────────┘     └──────────────────────────────┘
```

**このセッションで絶対に行ってはいけないこと:**

- 実装・コード変更・調査・分析
- ファイルの読み込み（タスクファイルへの書き込み以外）
- Agent / サブエージェントの起動
- 登録後の「実装しましょうか？」などの提案
- キューに `[ ]` タスクが存在しても、それを実行しようとすること

登録されたタスクは watcher プロセスが別セッションで実行する。このセッションの役割はそこで終わり。

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

### Step 1: ファイルを特定する（読み込み不要）

会話の文脈・ユーザーの説明のみからトピックを判断し、追記先ファイルを決める。

- コードベースの探索・ファイルの読み込みは不要
- 不明なときのみユーザーに確認する

### Step 2: タスクエントリを生成する

以下の方針で簡潔に書く:

- **slug**: 動詞-目的語の kebab-case（例: `add-dark-mode`, `fix-auth-bug`）
- **説明**: 1〜2行。ユーザーの説明をそのまま整理して記載
- **完了基準**: watcher が「終わった」と判断できる1行の基準

### Step 3: ファイルに追記する

Write / Edit ツールのみ使用して対象ファイルの末尾にエントリを追記する。
ファイルが存在しない場合は以下のヘッダー付きで新規作成:

```markdown
# Tasks: {topic}
```

### Step 4: 完了を報告して終了する

```
登録完了: .ai/tasks/{file}.md に追加
タスク: {slug}
```

**ここで終了。実装・調査・提案は一切行わない。**
