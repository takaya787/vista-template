---
name: financial-summary
description: Generate a financial summary table (PL/BS/CF) from CSV or pasted data. Use when the user says "/financial-summary", "財務サマリーを作って", "PLをまとめて", "BSの比較表を作って", "財務数値を整理して", or "financial summary". Proactively trigger when CSV files appear in data/raw/ with names containing pl, bs, cf, or financial.
---

# Financial Summary Generator

CSVまたは貼り付けデータからPL/BS/CFの比較表を生成し、前期比・予算比・KPIサマリーを構造化して出力する。

## Why This Skill Is Needed

財務数値は出所・期間・通貨単位の誤りが即座に信頼失墜につながる。AIが数値を補完・推測するリスクを排除しながら、CSVを比較表・増減率・ハイライトに変換するボイラープレート作業を自動化する。

## Input Requirements

| 項目 | 形式 | 必須 |
|------|------|------|
| 財務データ | `data/raw/*.csv` または直接貼り付け | 必須 |
| 比較期間の指定 | テキスト（例: 「2024Q4 vs 2023Q4」） | 必須 |
| 通貨・単位 | テキスト（例: 「百万円、小数点なし」） | 必須 |
| レポート種別 | PL / BS / CF のいずれか（複数可） | 必須 |

## Data Sources

- **財務CSV** — `data/raw/` 配下のファイル（命名規則: `{pl|bs|cf}_{YYYY-QN or YYYY-MM}.csv`）
- **前期レポート** — `docs/reports/` 配下の直前期ファイル（YoY diff用）
- **報告基準** — `rules/convention/reporting-standards.md`（開示粒度・表記ルール）

## Steps

### Step 1: データ確認

`data/raw/` に対象ファイルが存在するか確認。

| 状態 | 対応 |
|------|------|
| ファイルあり | ファイルパスと期間範囲をユーザーに確認して続行 |
| ファイルなし・貼り付けあり | 「貼り付けデータとして処理します」と明示して続行 |
| どちらもなし | `[DATA GAP: 財務データがありません。data/raw/にCSVを配置するか、数値を直接貼り付けてください]` を出力して停止 |

### Step 2: 比較軸の設定

- 当期 vs 前期（YoY）の列を作成
- ユーザーが予算比較を指定した場合、予算数値をユーザーから受け取る（AIは予算値を推測・生成しない）
- 予算データが未提供の場合: `[DATA GAP: 予算データが未提供です。予算比較列は [BUDGET REQUIRED] を表示します]`

### Step 3: 表の構造化

`rules/convention/reporting-standards.md` の表記規則を適用して比較表を生成。

- 数値は出所データのまま使用する（四捨五入・補完は行わない）
- 欠損セルは `[DATA GAP]` で明示する（空欄・ゼロ埋め禁止）
- 増減率は「当期/前期 - 1」で算出。前期がゼロまたは欠損の場合は `[CALC ERROR: 前期ゼロ]` を表示

### Step 4: ハイライト生成

以下の閾値で自動ラベリング（閾値は `reporting-standards.md` が定義する場合はそちらを優先）:

| ラベル | 条件 |
|--------|------|
| `[POSITIVE]` | YoY +10%超の改善 |
| `[WATCH]` | YoY -10%超の悪化 |
| `[MATERIAL]` | 前期比±20%超かつ絶対額が大きい項目 |

### Step 5: 保存・確認

`[INTERNAL]` タグを冒頭に付与し、`docs/reports/financial-summary_{period}.md` に保存。
ユーザーに内容確認と追記（注記・経営コメント）を促す。

## Output Format

```markdown
[INTERNAL] このドキュメントは社内資料です。外部配布前に必ずリーガルレビューを受けてください。

---
date: YYYY-MM-DD
type: financial-summary
period: YYYY-QN (当期) vs YYYY-QN (前期)
sources:
  - data/raw/{filename}.csv
unit: 百万円
---

## TL;DR

- （最重要な数値変化 — 1行）
- （主要なポジティブ / ネガティブ要因 — 1行）
- （次の開示に向けた注目点 — 1行）

## 損益計算書（PL）

| 項目 | 当期 | 前期 | 増減 | 増減率 |
|------|------|------|------|--------|
| 売上高 | ¥XXX | ¥XXX | +¥XX | +X.X% [POSITIVE] |
| 売上原価 | ¥XXX | ¥XXX | +¥XX | +X.X% |
| 売上総利益 | ¥XXX | ¥XXX | +¥XX | +X.X% |
| ...  | ... | ... | ... | ... |
| 当期純利益 | ¥XXX | ¥XXX | -¥XX | -X.X% [WATCH] |

> Source: data/raw/{filename}.csv

## 貸借対照表（BS）  <!-- 指定時のみ -->

...（同様の構成）

## キャッシュフロー計算書（CF）  <!-- 指定時のみ -->

...（同様の構成）

## ハイライト

- [POSITIVE] ...
- [WATCH] ...
- [MATERIAL] ...
```