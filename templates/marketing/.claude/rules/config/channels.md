---
paths: "**/*"
---

# Active Channels Config

スキルが参照するチャネル設定。`copy_limits` / `kpi_targets` の定義方法は `rules/convention/kpi-policy.md` を参照。

## Paid Channels

### Google Search Ads

- enabled: <!-- true | false -->
- copy_limits:
    headline: 30字以内
    description: 90字以内
    # ※ 仕様変更時はここを更新すること（最終確認: YYYY-MM）
- kpis: [CTR, CPC, CVR, CPA]
- kpi_targets:
    CPA: <!-- 目標CPA (例: ¥3,000) -->
    CVR: <!-- 目標CVR (例: 2.5%) -->
- benchmark_source: <!-- past-data | industry | none -->

### Meta Ads (Facebook / Instagram)

- enabled: <!-- true | false -->
- copy_limits:
    headline: 40字以内
    body: 125字以内
    # ※ 仕様変更時はここを更新すること（最終確認: YYYY-MM）
- kpis: [CPM, CTR, CVR, CPA, ROAS]
- kpi_targets:
    CPA: <!-- 目標CPA -->
    ROAS: <!-- 目標ROAS (例: 300%) -->
- benchmark_source: <!-- past-data | industry | none -->

### LINE Ads

- enabled: <!-- true | false -->
- copy_limits:
    headline: 20字以内
    body: 60字以内
    # ※ 仕様変更時はここを更新すること（最終確認: YYYY-MM）
- kpis: [CTR, CVR, CPA]
- kpi_targets:
    CPA: <!-- 目標CPA -->
- benchmark_source: <!-- past-data | industry | none -->

## Owned Channels

### Corporate Blog / SEO

- enabled: <!-- true | false -->
- kpis: [Organic Sessions, Keyword Rankings, CV]
- kpi_targets:
    monthly_cv: <!-- 目標月間CV数 -->

### Email Newsletter

- enabled: <!-- true | false -->
- kpis: [Open Rate, CTR, CV]
- kpi_targets:
    open_rate: <!-- 目標開封率 (例: 25%) -->

### X (Twitter) / Instagram

- enabled: <!-- true | false -->
- kpis: [Impressions, Engagement Rate, CV]
- kpi_targets: {}

## Analytics

- Primary tool: <!-- GA4 / Mixpanel / etc. -->
- Data warehouse: <!-- BigQuery / None -->
