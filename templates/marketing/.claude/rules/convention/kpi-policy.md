---
paths: "**/*"
---

# KPI Policy Convention

KPI目標値の設定・参照・出力に関する不変ルール。
campaign-plan / weekly-report / monthly-report の全スキルはこのルールに従うこと。

## KPI目標値のソース階層

スキルがKPI目標値（CPA / ROAS / CVR / CTR 等）を使用する場合、必ず以下の階層順に参照し、使用したソースをタグで明示すること。

| 階層 | ソース | タグ | 条件 |
|------|--------|------|------|
| **1st** | `rules/config/channels.md` の `kpi_targets` フィールド | タグ不要（信頼できる設定値） | フィールドに値が設定されている場合 |
| **2nd** | `reports/weekly/` または `reports/monthly/` の過去実績から算出 | `[PAST-DATA: {N}週/月]` | 過去レポートが1件以上存在する場合 |
| **3rd** | 業界ベンチマーク（出所を明記） | `[BENCHMARK: {出所名}]` | オーナーが明示的に使用を承認した場合のみ |

**どのソースも利用できない場合**: `[KPI_TARGET REQUIRED]` を出力してユーザーに目標値の設定を促し、処理を停止すること。根拠なしにKPI目標値を生成・推測してはならない。

## 禁止事項

- ソースなしに数値を生成すること（例: 「CPA目標: ¥3,000」を根拠なしに設定する）
- 過去データがない初期状態で業界ベンチマークを無断で使用すること
- `[BENCHMARK]` タグを使う際に出所を省略すること

## タグフォーマット

```
CPA目標: ¥3,000 [PAST-DATA: 4週平均]
ROAS目標: 300% [BENCHMARK: Google業界平均 2025年版]
CVR目標: [KPI_TARGET REQUIRED]
```

## campaign-plan での適用ルール

キャンペーン計画にKPI目標を設定する際の参照順序：

1. `rules/config/channels.md` → `kpi_targets` を確認
2. 未設定の場合: `reports/weekly/` の直近4週分の平均値を算出して `[PAST-DATA: 4週]` で提案
3. レポートも存在しない場合: `[KPI_TARGET REQUIRED]` を出力し、以下を案内して停止:
   > 「KPI目標を設定するには、① `rules/config/channels.md` の `kpi_targets` に値を追記するか、② 過去の週次レポートを作成して実績値を蓄積してください。」

## weekly-report / monthly-report での適用ルール

レポート内で目標達成率を表示する際:

- `channels.md` に `kpi_targets` が存在する場合: 達成率を算出し `[OVER_TARGET]` / `[UNDER_TARGET]` でラベリング
- `kpi_targets` が未設定の場合: 達成率列に `[NO_TARGET]` を表示し、目標値の設定を促すメモを TL;DR の下に追加する

```
> [KPI目標未設定] channels.md の kpi_targets にCPA・ROAS目標を設定すると、達成率が自動表示されます。
```

## ベンチマーク値の取り扱い

- 業界ベンチマークは推測ではなく公開資料（Google官資料、業界白書等）を出所とすること
- ベンチマーク値はオーナーの確認を得た場合のみ目標として採用する
- ベンチマークを使用した場合は必ず `[BENCHMARK: {出所名} {確認日 YYYY-MM}]` を付記する
