---
name: weekly-report
description: Generate a weekly marketing KPI report from CSV data in data/raw/. Use when the user says "/weekly-report", "週次レポートを作成して", "今週の結果まとめて", or "create weekly report". Proactively trigger at end-of-week or start-of-week reporting times.
---

# Weekly Report Generator

CSVデータから週次KPIレポートを生成し、前週diff・アクション提案・共有フォーマットを含むレポートを出力する。

## Why This Skill Is Needed

週次レポートはチームと経営層への定期コミュニケーションツール。データ読み込みからdiff計算・共有フォーマット変換まで自動化することで、毎週の作業時間を削減し品質を安定させる。

## Data Sources

- **CSVファイル** — `data/raw/` 内の対象週のファイル（`data-sources.md` 参照）
- **前回レポート** — `reports/weekly/` 内の最新ファイル（diff計算用）
- **チャネル設定** — `rules/config/channels.md`
- **共有先設定** — `rules/config/integrations.md`

## Steps

### Step 1: データ確認

`data/raw/` に今週分のCSVが存在するか確認。存在しない場合はユーザーにファイルを要求して停止。

### Step 2: 前回レポート読み込み

`reports/weekly/` の最新ファイルを読み込み、主要KPI（CVR / CPA / ROAS / CTR）の前週値を取得。

### Step 3: KPI集計

CSVを読み込み、`rules/config/channels.md` のアクティブチャネル別に集計。前週比（%）を計算。

### Step 4: レポート生成

`report-output.md` の構造規約に従い生成する:
TL;DR → チャネル別パフォーマンス（前週diff付き）→ Highlights → 来週のアクション（優先度付き、最大3件）

### Step 5: 共有フォーマット追記

`integrations.md` の Primary 設定に応じてNotion用またはTSV形式を末尾に追記。

### Step 6: 保存・確認

`reports/weekly/{YYYY-MM-DD}.md` に保存し、ユーザーに内容確認と追記を促す。

## Output Format

```markdown
---
date: YYYY-MM-DD
type: weekly
sources:
  - data/raw/{files_used}
---

## TL;DR

- （最重要な数値変化 — 1行）
- （最大のポジティブ要因 — 1行）
- （最優先のアクション — 1行）

## チャネル別パフォーマンス

| チャネル | Impressions | Clicks | CTR | CV | CVR | CPA | ROAS | 前週比(CV) |
|---------|------------|--------|-----|----|----|-----|------|-----------|
| Google Search | ... | ... | ...% | ... | ...% | ¥... | ...% | +X% / -X% |
| Meta | ... | ... | ...% | ... | ...% | ¥... | ...% | +X% / -X% |

> Source: data/raw/{file_name}

## Highlights

- [GOOD] ...
- [WATCH] ...
- [ACTION] ...

## 来週のアクション

1. [HIGH] ...
2. [MID] ...
3. [LOW] ...

<!-- 共有フォーマット（integrations.md の Primary 設定に応じて追記） -->
```
