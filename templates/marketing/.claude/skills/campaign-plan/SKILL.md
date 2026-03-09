---
name: campaign-plan
description: Create a structured campaign plan with KPIs, budget allocation, and timeline. Use when the user says "/campaign-plan", "キャンペーン計画を作って", or "create campaign plan".
---

# Campaign Plan Generator

目標・予算・期間からチャネル配分・週次タイムライン・KPI設定を含むキャンペーン計画を生成する。

## Why This Skill Is Needed

キャンペーン計画はゼロから作ると抜け漏れが出やすい。必要情報を構造的に収集し、チャネル設定と紐付けて計画を生成することで、承認用ドキュメントとして即使える品質を担保する。

## Data Sources

- **ブリーフ** — ユーザーからのインプット
- **チャネル設定** — `rules/config/channels.md`（利用可能チャネルの参照）
- **過去レポート** — `reports/weekly/` または `reports/monthly/` （KPIの実績値参照）

## Steps

### Step 1: ブリーフ収集

以下を確認する。未定の項目はユーザーに質問する:

- キャンペーンゴール（Awareness / Lead / Conversion）
- 総予算（または予算感）
- 期間（開始日・終了日）
- ターゲットオーディエンス

### Step 2: チャネルミックス提案

`rules/config/channels.md` のアクティブチャネルを参照し、ゴールに合った配分を提案。

### Step 3: 計画生成

以下の構造でレポートを生成する:

- Overview（ゴール・期間・総予算）
- チャネル別予算配分テーブル
- 週次タイムライン（Gantt形式のMarkdownテーブル）
- 成功KPIと目標値

### Step 4: 保存・確認

`reports/analysis/campaign_{name}_{YYYY-MM-DD}.md` に保存し、ユーザーに確認を促す。
