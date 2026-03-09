---
name: competitor-analysis
description: Analyze competitor positioning from materials in inbox/ or pasted text. Use when the user says "/competitor-analysis", "競合分析して", "このLPを分析して", or "analyze competitor".
---

# Competitor Analysis

`inbox/` のファイルまたは貼り付けテキストをインプットに競合ポジショニングを構造化分析する。

## Why This Skill Is Needed

競合調査は属人化・形式バラバラになりやすい。インプット形式を統一し、Findingsを定型構造で出力することで複数競合の横断比較と蓄積を可能にする。

## Data Sources

- **インプット** — `inbox/` 内のファイル、またはユーザーの貼り付けテキスト（`analysis-workflow.md` の優先順位に従う）
- **過去分析** — `reports/analysis/` 内の既存競合レポート（差分把握用）

## Steps

### Step 1: インプット確認

`analysis-workflow.md` の Input Priority に従い形式を確認。インプットがない場合はガイドしてここで停止。

### Step 2: 仮説宣言

「何を明らかにしたいか」を1文で出力してユーザーの確認を取る。

### Step 3: 分析実行

テキスト・画像・PDFを読み込み以下の軸で構造化:
Value Proposition / ターゲット / 主要メッセージ / 価格・CTA / トーン

### Step 4: Findings出力

`analysis-workflow.md` の Findings Structure に従い記述。自社差別化余地は最大3点に絞る。

### Step 5: 保存

`reports/analysis/competitor_{company-name}_{YYYY-MM-DD}.md` に保存。
