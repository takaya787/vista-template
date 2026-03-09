---
name: report-output
description: Defines rules for report structure, save location, and external sharing format.
---

# Report Output Convention

## Save Location

| レポート種別     | 保存先              | ファイル名                          |
| ---------------- | ------------------- | ----------------------------------- |
| 週次レポート     | `reports/weekly/`   | `{YYYY-MM-DD}.md`（月曜日の日付）   |
| 月次レポート     | `reports/monthly/`  | `{YYYY-MM}.md`                      |
| 競合・市場分析   | `reports/analysis/` | `competitor_{name}_{YYYY-MM-DD}.md` |
| キャンペーン計画 | `reports/analysis/` | `campaign_{name}_{YYYY-MM-DD}.md`   |

## Required Header（全レポート共通）

すべてのレポートは以下のfrontmatterと冒頭ブロックを必ず含む:

```markdown
---
date: YYYY-MM-DD
type: weekly | monthly | analysis | campaign
sources:
  - data/raw/ga4_sessions_YYYY-MM.csv
  - data/raw/gads_campaign_YYYY-MM-DD.csv
---

## TL;DR

- （最重要な数値変化 — 1行）
- （最大のポジティブ要因 — 1行）
- （最優先のアクション — 1行）
```

## Diff Rule（週次・月次必須）

- 前回ファイル: `reports/weekly/` または `reports/monthly/` の最新ファイルを読み込む
- diff対象: 主要KPI（CVR / CPA / ROAS / CTR）の数値と増減率（%）

## External Sharing Format

`rules/config/integrations.md` の Primary 設定に応じてレポート末尾に追記する:

| Primary 設定    | 追記内容                                       |
| --------------- | ---------------------------------------------- |
| `notion`        | そのままMarkdownを貼れば表示される（追記不要） |
| `sheets`        | KPIテーブルをTSVコードブロックで追記する       |
| `markdown-only` | 追記なし                                       |

設定が未定義の場合はmarkdownのみ出力し、ユーザーに確認する。
