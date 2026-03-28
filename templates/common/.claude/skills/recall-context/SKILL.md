---
name: recall-context
description: 過去の会話履歴をSQLiteから取得し、現在のタスクに関連するナレッジをClaudeの内部コンテキストとして活用する。タスク開始前に「過去のやりとりを確認」「前回何をしたか」「このプロジェクトの履歴」「以前の作業内容を踏まえて」「前のセッションの続き」などの文脈で使う。また、ユーザーが過去に議論した内容を前提としている様子があれば、明示的な指示がなくてもこのスキルを使って関連する過去のやりとりを取得すること。
argument-hint: "<検索キーワード（省略可）>"
---

# Recall Context — 過去のやりとりからナレッジを取得

過去のClaude Codeセッションの会話履歴を `~/.vista/history/conversations.db` から検索し、現在のタスクに関連する情報をClaudeの内部コンテキストとして取り込む。

ユーザーに生のメッセージを表示する必要はない。取得した情報はClaudeが作業の参考にするための背景知識として利用する。

## データソース

- DB: `~/.vista/history/conversations.db`
- テーブル: `sessions`（セッション管理）、`messages`（メッセージ本文）、`messages_fts`（全文検索）
- セッションは `project_path` でプロジェクト単位にスコープされている

## Instructions

### Step 1: 検索戦略を決定する

ユーザーの発言やタスク内容から、どのような過去情報が有用かを判断する。

- **明示的なキーワードがある場合**: FTS検索で関連メッセージを取得
- **キーワードが不明確な場合**: まず直近セッションの概要を取得し、関連しそうなセッションを特定してから詳細を取得
- **「前回の続き」のような文脈**: 直近1-2セッションの詳細メッセージを取得

### Step 2: クエリスクリプトを実行する

スクリプト: `~/.claude/skills/recall-context/scripts/query_history.py`

#### 直近セッション一覧を取得（概要）

```bash
python3 ~/.claude/skills/recall-context/scripts/query_history.py \
  --project-path "$(pwd)" \
  --limit 5 \
  --mode summary
```

#### キーワード検索（概要）

```bash
python3 ~/.claude/skills/recall-context/scripts/query_history.py \
  --project-path "$(pwd)" \
  --query "検索キーワード" \
  --limit 10 \
  --mode summary
```

#### 詳細メッセージ取得

```bash
python3 ~/.claude/skills/recall-context/scripts/query_history.py \
  --project-path "$(pwd)" \
  --query "検索キーワード" \
  --limit 10 \
  --mode detail
```

#### 直近セッションの全メッセージ取得

```bash
python3 ~/.claude/skills/recall-context/scripts/query_history.py \
  --project-path "$(pwd)" \
  --limit 2 \
  --mode detail
```

### Step 3: 取得結果をコンテキストとして内部保持する

取得した情報は以下のように活用する：

1. **要約を内部的に構築する** — 取得したメッセージから、現在のタスクに関連する事実・決定事項・議論のポイントを抽出する
2. **ユーザーへの表示は最小限** — 「過去のセッションから関連情報を取得しました」程度の一言で十分。生メッセージの羅列は不要
3. **タスク実行に反映する** — 取得したナレッジを踏まえて、より的確な提案やコード変更を行う

### Step 4（将来拡張）: ベクトル検索によるセマンティック検索

現在は `messages` テーブルに `embedding BLOB` カラムが存在するが未使用。将来的にembeddingが格納された場合、以下の流れでセマンティック検索を追加する：

1. 現在のタスク/クエリをembedding化
2. コサイン類似度でスコアリング
3. FTSスコアとベクトルスコアをハイブリッドで統合

この拡張はembeddingパイプラインが実装された後に行う。

## 注意事項

- 現在のプロジェクト（`project_path`）のセッションのみを検索対象とする
- メッセージ内容は1000文字で切り詰められる（コンテキスト効率のため）
- 大量のメッセージを取得するとコンテキストを圧迫するため、`--limit` で適切に制限する
- 取得した情報が古い場合は、現在のコードやファイル状態を優先する
