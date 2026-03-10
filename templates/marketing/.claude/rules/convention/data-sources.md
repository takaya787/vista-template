---
paths: "**/*"
---

# Data Source Convention

## Directory Rules

| ディレクトリ      | 用途                                            | 編集                     |
| ----------------- | ----------------------------------------------- | ------------------------ |
| `data/raw/`       | GA4・広告管理画面からのCSVエクスポート原本      | **禁止**                 |
| `data/processed/` | rawを加工・結合したファイル                     | 可（生成元を冒頭に明記） |
| `inbox/`          | 競合スクショ・PDF・貼り付けテキストの一時置き場 | 可                       |

## Naming Convention

`{source}_{content}_{YYYY-MM or YYYY-MM-DD}.{ext}`

| source キー | 対応サービス          |
| ----------- | --------------------- |
| `ga4`       | Google Analytics 4    |
| `gads`      | Google Ads            |
| `meta`      | Meta Ads              |
| `line`      | LINE Ads              |
| `bq`        | BigQuery エクスポート |

例: `ga4_sessions_2025-06.csv` / `gads_campaign_2025-06-10.csv`

## Data Integrity Rules

1. `data/raw/` のファイルは絶対に編集しない。加工は `data/processed/` に別名保存する
2. データファイルを参照した場合、出力の冒頭に必ず明記する:
   `> Source: data/raw/ga4_sessions_2025-06.csv`
3. データが存在しない場合は数値を推測・補完せず `[DATA REQUIRED]` プレースホルダーを使う
4. BigQueryの結果はCSVでエクスポートし `data/raw/bq_{content}_{YYYY-MM-DD}.csv` として保存してから渡す

## Pre-Task Checklist

データ系タスク開始前に必ず確認する:

- [ ] `data/raw/` に対象期間のファイルが存在するか
- [ ] ファイルの日付範囲と依頼の期間が一致しているか
- [ ] 複数ファイルを使う場合、集計粒度（日次/週次/月次）が揃っているか
