---
name: investor-letter
description: Draft a formal investor letter or shareholder communication. Use when the user says "/investor-letter", "投資家向けレターを書いて", "株主向けメッセージを作って", "shareholder letter", or "investor communication". Do NOT trigger automatically — always require explicit user invocation.
---

# Investor Letter Drafter

決算報告・事業進捗・重大発表に関する投資家向け正式レターのドラフトを生成する。

## Why This Skill Is Needed

投資家向けレターは規制リスクが最も高い文書カテゴリに属する。不正確な数値・未公開情報の混入・静粛期間中の発信はすべて法的リスクを生む。このスキルはドラフト生成の効率化と同時に、リーガルレビュー前の外部配布禁止を構造的に強制する。

## Input Requirements

| 項目 | 形式 | 必須 |
|------|------|------|
| レターの目的・種別 | テキスト（決算報告/事業進捗/重大発表） | 必須 |
| 参照する財務サマリー | `docs/reports/financial-summary_*.md` | 必須 |
| 経営コメント・メッセージ骨子 | テキスト（箇条書き可） | 必須 |
| 配信対象（機関/個人/全株主） | テキスト | 推奨 |

## Data Sources

- **財務サマリー** — `docs/reports/financial-summary_*.md`（このスキルが生成した数値確認済みファイル）
- **会社情報** — `.vista/profile/me.json`（会社名・代表者名・署名情報）
- **静粛期間カレンダー** — `rules/config/ir-calendar.md`（quiet period定義）
- **開示規則** — `rules/convention/disclosure-policy.md`（記載禁止事項・必須文言）

## Steps

### Step 1: 静粛期間チェック（BLOCKER）

`rules/config/ir-calendar.md` を読み込み、本日日付が quiet period に該当するか確認。

**該当する場合は即座に停止:**

```
[QUIET PERIOD] 本日 {YYYY-MM-DD} は静粛期間中です（{period_name}: {start} 〜 {end}）。
投資家向け外部コミュニケーションのドラフト作成は静粛期間終了後に行ってください。
静粛期間の変更は rules/config/ir-calendar.md で管理してください。
```

`ir-calendar.md` が存在しない場合:

```
[QUIET PERIOD CHECK REQUIRED] rules/config/ir-calendar.md が見つかりません。
静粛期間の確認ができないため、処理を停止します。
ファイルを作成してから再実行してください。
```

### Step 2: ソース文書確認（BLOCKER）

`docs/reports/` に `financial-summary_*.md` が存在するか確認。

- 存在しない場合: `[REQUIRES INPUT: 財務サマリーが必要です。先に /financial-summary を実行してdocs/reports/にファイルを生成してください]` を出力して停止
- 存在する場合: ファイル一覧を表示し、ユーザーに参照ファイルを選択させる

### Step 3: 経営コメントの確認

ユーザーから経営コメント・メッセージ骨子を受け取る。AIが経営コメントを独自に生成してはいけない（事実確認不能なため）。

骨子が未提供の場合: 「経営コメントの骨子をご提供ください（箇条書き可）。AIが経営見解を創作することはできません。」と案内して待機。

### Step 4: ドラフト生成

`rules/convention/disclosure-policy.md` の記載規則に従いドラフトを生成:

- 財務数値は `financial-summary_*.md` から引用（AIによる数値の変更・推測禁止）
- 将来予測を含む場合は必ず `[FORWARD-LOOKING STATEMENT]` タグを付与
- 未公開情報に該当する可能性がある記述には `[LEGAL REVIEW REQUIRED]` タグを付与

### Step 5: 保存

`[DRAFT][INTERNAL]` タグを冒頭に付与し、`docs/external/investor-letter_{purpose}_{YYYY-MM-DD}.md` に保存。

## Output Format

```markdown
[DRAFT][INTERNAL] このドキュメントはドラフトです。外部配布前に必ずリーガルレビューと経営承認を受けてください。

---
date: YYYY-MM-DD
type: investor-letter
purpose: {決算報告 | 事業進捗 | 重大発表}
audience: {機関投資家 | 個人株主 | 全株主}
sources:
  - docs/reports/financial-summary_{period}.md
status: DRAFT — requires legal review before distribution
---

## Pre-Disclosure Checklist

以下をリーガル担当者と確認すること（配布前必須）:

- [ ] 静粛期間外であることを確認
- [ ] 未公開情報（MNPI）が含まれていないことを確認
- [ ] 将来予測には適切な免責文言が付与されていることを確認
- [ ] 財務数値が監査済みデータと一致することを確認
- [ ] 代表者の確認・署名を取得

---

{会社名}
{日付}

拝啓

{書き出し — 目的・期間の明示}

{本文セクション1: 財務ハイライト}

（数値は docs/reports/financial-summary_{period}.md より引用）

| 指標 | 当期 | 前期 | 増減率 |
|------|------|------|--------|
| ... | ... | ... | ... |

{本文セクション2: 事業進捗・トピック}

{本文セクション3: 今後の方針} [FORWARD-LOOKING STATEMENT]

> 注: 上記の将来予測は現時点の仮定に基づくものであり、実際の結果と異なる場合があります。

敬具

{代表者名}
{役職}
{会社名}

---

AI生成免責: このドキュメントはAIによるドラフトです。内容の正確性・法的適切性についてはご自身で確認し、専門家のレビューを受けてください。
```