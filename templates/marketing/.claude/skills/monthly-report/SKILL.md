---
name: monthly-report
description: Generate a monthly marketing performance report aggregating all weekly reports for the target month. Use when the user says "/monthly-report", "月次レポートを作成して", "先月の結果まとめて", "monthly summary", or "月次レポート". Proactively trigger at month-end or during the first week of a new month.
---

# Monthly Report Generator

当月の週次レポートを集約し、前月比（MoM）・KPI達成率・予算消化率・翌月推奨施策を含む月次レポートを生成する。

## Why This Skill Is Needed

週次レポートは運用担当者向けの即時フィードバックツールだが、月次レポートは経営層・事業責任者向けの意思決定ツール。集計粒度・KPI範囲・受け手が異なるため、weekly-reportを流用することはできない。月次で初めて可視化できる「予算消化率」「チャネル獲得シェア推移」「目標達成率」を構造化して提供する。

## weekly-report との責務分担

| 観点 | weekly-report | monthly-report |
|------|--------------|----------------|
| diff軸 | 前週比（WoW） | 前月比（MoM）＋前年同月比（YoY、データがある場合） |
| 参照ファイル | 直前1週のレポート | `reports/weekly/` 当月分ファイル全件 |
| KPI範囲 | CVR / CPA / ROAS / CTR | 上記＋予算消化率・チャネル別獲得シェア・目標達成率 |
| 主な受け手 | 運用チーム | 経営層・事業責任者 |
| アクション粒度 | 来週の入札・クリエイティブ調整 | 翌月の予算再配分・チャネル戦略変更 |
| 保存先 | `reports/weekly/{YYYY-MM-DD}.md` | `reports/monthly/{YYYY-MM}.md` |

## Data Sources

- **当月週次レポート** — `reports/weekly/{YYYY-MM-}*.md`（対象月の全ファイル）
- **前月レポート** — `reports/monthly/` の直前月ファイル（MoM diff用）
- **チャネル設定** — `rules/config/channels.md`（有効チャネル・KPI目標値・ベンチマーク参照）
- **KPIポリシー** — `rules/convention/kpi-policy.md`（目標値の根拠ルール）
- **共有先設定** — `rules/config/integrations.md`

## Steps

### Step 1: 対象月の特定とデータ確認

対象月を確認する（引数があれば使用、なければユーザーに確認またはシステム日付の前月を使用）。

`reports/weekly/` から `{YYYY-MM-}` プレフィックスに一致するファイルを全件取得。

| 週次ファイル数 | 対応 |
|--------------|------|
| 4〜5件 | 正常。全件読み込んで集計 |
| 1〜3件 | `[DATA WARNING] {N}/4週分のレポートのみ存在。集計が不完全になる可能性あり。` を出力して続行 |
| 0件 | `[REQUIRES INPUT]` — 「`reports/weekly/` に対象月のレポートが存在しません。週次レポートを先に作成するか、`data/raw/` のCSVから直接集計しますか？」と案内して停止 |

### Step 2: 前月レポートの読み込み

`reports/monthly/` から直前月のファイルを読み込む。存在しない場合は MoM diff 列を `[前月データなし]` として続行（集計は止めない）。

### Step 3: KPIの月次集計

`rules/config/channels.md` のアクティブチャネル別に当月分週次ファイルを集計：

- **合算値**: Impressions / Clicks / CV数 / 広告費
- **月次算出値**: CTR / CVR / CPA / ROAS（合算値から算出）
- **前月比（MoM）**: 各KPIの変化率（%）
- **目標達成率**: `channels.md` の `kpi_targets` が定義されている場合に算出

KPI目標値の参照は `rules/convention/kpi-policy.md` のルールに従う。

### Step 4: 予算消化サマリー

`channels.md` に予算設定が存在する場合：
- 月間消化額 / 計画予算 → 消化率（%）
- チャネル別消化額と配分比

予算設定がない場合は `[BUDGET PLAN REQUIRED: channels.mdに月間予算を設定してください]` を表示してこのセクションをスキップ。

### Step 5: レポート生成

`report-output.md` の構造規約に従い生成する：
TL;DR → チャネル別パフォーマンス（MoM diff付き） → 目標達成率サマリー → 予算消化サマリー → 月次ハイライト → 翌月推奨施策

### Step 6: 共有フォーマット追記

`integrations.md` の Primary 設定に応じてNotion用またはTSV形式を末尾に追記。

### Step 7: 保存・確認

`reports/monthly/{YYYY-MM}.md` に保存し、ユーザーに内容確認と追記を促す。

## Output Format

```markdown
---
date: YYYY-MM-DD
type: monthly
period: YYYY-MM
sources:
  - reports/weekly/{YYYY-MM-DD}.md（当月分 N件）
  - data/raw/{files_used}（直接参照した場合）
---

## TL;DR

- （最重要な数値変化 — 月次で初めて見えた構造的変化を1行）
- （最大のポジティブ / ネガティブ要因 — 1行）
- （翌月の最優先アクション — 1行）

## チャネル別パフォーマンス（月次）

| チャネル | Impressions | Clicks | CTR | CV | CVR | CPA | ROAS | 前月比(CV) | 目標達成率 |
|---------|------------|--------|-----|----|-----|-----|------|-----------|-----------|
| Google Search | ... | ... | ...% | ... | ...% | ¥... | ...% | +X% | [OVER_TARGET] / [UNDER_TARGET] / [NO_TARGET] |
| Meta | ... | ... | ...% | ... | ...% | ¥... | ...% | +X% | |

> Source: reports/weekly/{YYYY-MM-DD}.md ほか{N}件

## 目標達成率サマリー

| チャネル | KPI | 目標 | 実績 | 達成率 |
|---------|-----|------|------|--------|
| Google Search | CPA | ¥X,XXX | ¥X,XXX | XX% [OVER_TARGET] |

## 予算消化サマリー

| チャネル | 計画予算 | 実績消化 | 消化率 |
|---------|---------|---------|--------|
| Google Search | ¥XXX,XXX | ¥XXX,XXX | XX% |
| 合計 | ¥X,XXX,XXX | ¥X,XXX,XXX | XX% |

## 月次ハイライト

- [GOOD] ...（月次で初めて確認できたポジティブな傾向）
- [WATCH] ...（週次では見えなかった構造的な課題）
- [ACTION] ...

## 翌月推奨施策

1. [HIGH] ...（予算再配分・チャネル戦略変更など意思決定が必要なもの）
2. [MID] ...
3. [LOW] ...

<!-- 共有フォーマット（integrations.md の Primary 設定に応じて追記） -->
```
