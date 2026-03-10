---
paths: "**/*"
---

# IR Calendar

Project-specific disclosure schedule and quiet periods. Convention rules in `rules/convention/disclosure-workflow.md` reference this file for timing constraints.

## Fiscal Year

| Key | Value |
|-----|-------|
| Fiscal year end | `{{FISCAL_YEAR_END}}` (e.g., March, December) |
| Accounting standard | `{{ACCOUNTING_STANDARD}}` (jgaap / ifrs / us-gaap) |

## Disclosure Schedule

| Event | Date | Quiet Period Start | Status |
|-------|------|--------------------|--------|
| Q1 Earnings | `{{Q1_EARNINGS_DATE}}` | `{{Q1_QUIET_START}}` | <!-- scheduled / completed --> |
| Q2 Earnings | `{{Q2_EARNINGS_DATE}}` | `{{Q2_QUIET_START}}` | <!-- scheduled / completed --> |
| Q3 Earnings | `{{Q3_EARNINGS_DATE}}` | `{{Q3_QUIET_START}}` | <!-- scheduled / completed --> |
| Full Year Earnings | `{{FY_EARNINGS_DATE}}` | `{{FY_QUIET_START}}` | <!-- scheduled / completed --> |
| Annual Report Filing | `{{ANNUAL_REPORT_DATE}}` | — | <!-- scheduled / completed --> |
| AGM | `{{AGM_DATE}}` | — | <!-- scheduled / completed --> |

## Quiet Period Default

- Default quiet period: `{{QUIET_PERIOD_WEEKS}}` weeks before earnings announcement
- During quiet period, external-facing document generation is blocked per `disclosure-workflow.md`

## Disclosure Channels

| Channel | URL/Detail |
|---------|-----------|
| TDnet | <!-- URL or "N/A" --> |
| EDINET | <!-- URL or "N/A" --> |
| IR Website | `{{IR_WEBSITE_URL}}` |
| Earnings Call Platform | <!-- Zoom / YouTube / In-person --> |
