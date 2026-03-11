---
name: earnings-qa
description: Generate an internal Q&A preparation document for earnings calls or investor meetings. Use when the user says "/earnings-qa", "決算Q&A準備して", "IRミーティングのQ&A作って", "想定質問を整理して", "earnings call prep", or "Q&A prep". Proactively trigger when an earnings call date appears within 7 days in ir-calendar.md.
---

# Earnings Q&A Prep Generator

決算説明会・投資家ミーティング向けの想定Q&Aドキュメントを生成する。財務数値はすべて `[FIGURE REQUIRED]` プレースホルダーで管理し、AIによる数値の補完・推測を完全に排除する。

## Why This Skill Is Needed

決算説明会では事前準備の質が投資家の信頼度に直結する。一方、AIが財務数値を生成・推測した場合のリスクは甚大（虚偽開示の可能性）。このスキルは質問の網羅性とアンサー構造を自動化しながら、数値欄を `[FIGURE REQUIRED]` で強制的に空欄にすることで「AIが埋めてしまう事故」を構造的に防ぐ。

## Input Requirements

| 項目 | 形式 | 必須 |
|------|------|------|
| 決算期・イベント名 | テキスト（例: 「2024Q4決算説明会」） | 必須 |
| 財務サマリー | `docs/reports/financial-summary_*.md` | 必須 |
| 事業トピック | テキスト（M&A/新規事業/組織変更等の重大事項） | 推奨 |
| アナリストレポート | `inbox/` 配下のPDF/テキスト | 任意 |

## Data Sources

- **財務サマリー** — `docs/reports/financial-summary_*.md`（数値のソース。直接引用のみ）
- **アナリストレポート** — `inbox/` 配下のファイル（質問予測の参考）
- **過去Q&A** — `docs/reports/earnings-qa_*.md`（過去の質問傾向分析）
- **IR方針** — `rules/convention/disclosure-policy.md`（回答禁止事項）

## Steps

### Step 1: ソース確認

`docs/reports/` に `financial-summary_*.md` が存在するか確認。

- 存在しない場合: `[REQUIRES INPUT: 財務サマリーが必要です。先に /financial-summary を実行してください]` を出力して停止
- 存在する場合: ファイル一覧を表示しユーザーに選択させる

### Step 2: アナリストレポートの取り込み

`inbox/` にアナリストレポート・前回説明会の書き起こしが存在する場合、読み込んで質問傾向を抽出する。

存在しない場合は「アナリストレポートなし。一般的な質問カテゴリから生成します」と明示して続行（停止しない）。

### Step 3: 質問カテゴリの設定

以下のカテゴリを標準として使用（ユーザーが追加指定した場合はそれを追加）:

1. 財務パフォーマンス（売上・利益・マージン推移）
2. セグメント別業績
3. ガイダンス・見通し
4. 資本配分（配当・自社株買い・投資計画）
5. 競合・市場環境
6. リスク要因
7. 経営戦略・M&A

### Step 4: Q&A生成

各質問に対して以下の構造でアンサーフレームを生成:

- **数値が必要な箇所**: `[FIGURE REQUIRED: {項目名}]` を配置（AIが数値を生成してはいけない）
- **事実確認が必要な記述**: `[FACT CHECK REQUIRED]` タグを付与
- **開示禁止事項に触れる可能性**: `[DISCLOSURE RISK: {理由}]` タグを付与し、`disclosure-policy.md` の該当ルールを引用

### Step 5: 保存

`[INTERNAL]` タグを付与し、`docs/reports/earnings-qa_{period}_{YYYY-MM-DD}.md` に保存。
ユーザーに `[FIGURE REQUIRED]` 箇所の数値入力を促す。

## Output Format

```markdown
[INTERNAL] このドキュメントは社内資料です。外部配布禁止。

---
date: YYYY-MM-DD
type: earnings-qa
event: {決算説明会名}
period: YYYY-QN
sources:
  - docs/reports/financial-summary_{period}.md
  - inbox/{analyst-report}.pdf  <!-- 参照した場合 -->
status: DRAFT — [FIGURE REQUIRED] 箇所を埋めてから使用してください
---

## 使い方

1. `[FIGURE REQUIRED]` のプレースホルダーに実際の数値を入力する
2. `[FACT CHECK REQUIRED]` 箇所を担当部門に確認する
3. `[DISCLOSURE RISK]` 箇所を法務・IRチームに確認する
4. 完成後、このヘッダーセクションを削除する

---

## Q&A: 財務パフォーマンス

### Q1. 今期の売上高・営業利益の結果と、前期比をどう評価していますか？

**A（アンサーフレーム）:**

当期の売上高は `[FIGURE REQUIRED: 当期売上高]`、前期比 `[FIGURE REQUIRED: 売上高YoY%]` となりました。
営業利益は `[FIGURE REQUIRED: 当期営業利益]`（営業利益率 `[FIGURE REQUIRED: 営業利益率%]`）で、
前期比 `[FIGURE REQUIRED: 営業利益YoY%]` の結果です。

主な要因として、[FACT CHECK REQUIRED: 主な増減要因を経営・財務部門に確認]。

---

### Q2. ガイダンスとの乖離についてどう説明しますか？

**A（アンサーフレーム）:**

期初ガイダンスは売上高 `[FIGURE REQUIRED: 期初ガイダンス売上]`、営業利益 `[FIGURE REQUIRED: 期初ガイダンス営業利益]` でした。
実績との差異は `[FIGURE REQUIRED: 差異額・率]` となります。

主な乖離要因: [FACT CHECK REQUIRED]

---

## Q&A: セグメント別業績

### Q3. セグメント別の成長ドライバーはどこですか？

**A（アンサーフレーム）:**

| セグメント | 売上 | YoY | コメント |
|-----------|------|-----|---------|
| {セグメント1} | [FIGURE REQUIRED] | [FIGURE REQUIRED] | [FACT CHECK REQUIRED] |
| {セグメント2} | [FIGURE REQUIRED] | [FIGURE REQUIRED] | [FACT CHECK REQUIRED] |

---

## Q&A: ガイダンス・見通し

### Q4. 次期のガイダンスはどのようなものですか？

**A（アンサーフレーム）:**

[DISCLOSURE RISK: 未公開の将来予測情報を含む可能性あり。disclosure-policy.md の「将来予測に関するルール」を確認してください]

次期ガイダンスについては、`[FIGURE REQUIRED: 次期売上ガイダンス]`、`[FIGURE REQUIRED: 次期利益ガイダンス]` を見込んでいます。

主な前提条件: [FACT CHECK REQUIRED]

---

## Q&A: 資本配分

### Q5. 配当・自社株買いの方針は？

**A（アンサーフレーム）:**

[FACT CHECK REQUIRED: 取締役会決議済み内容のみ記載。未決定事項は「検討中」と回答]

---

## Q&A: リスク要因

### Q6. 現在の主要リスクとその対応策は？

**A（アンサーフレーム）:**

[FACT CHECK REQUIRED: リスク管理部門・法務と整合確認が必要]

<!-- アナリストレポートから抽出した追加質問（存在する場合） -->
## アナリスト注目点（inbox/ レポートより）

{抽出した質問傾向・注目項目}
```