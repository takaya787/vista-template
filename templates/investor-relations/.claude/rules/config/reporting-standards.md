---
paths: "**/*"
---

# Reporting Standards Config

Project-specific financial reporting settings. Referenced by `rules/convention/financial-data-integrity.md` for rounding and format rules.

## Number Format

| Key | Value |
|-----|-------|
| Currency | `{{CURRENCY}}` (e.g., JPY, USD) |
| Unit | `{{UNIT}}` (e.g., millions, thousands) |
| Decimal places (amounts) | `{{DECIMAL_PLACES}}` (e.g., 0 for JPY millions) |
| Decimal places (percentages) | 1 |
| Negative display | `{{NEGATIVE_FORMAT}}` (e.g., △, parentheses, minus sign) |

## Key Metrics

| Metric | Source Field | Category |
|--------|-------------|----------|
| Revenue | `{{REVENUE_FIELD}}` | Financial |
| Operating Profit | `{{OP_FIELD}}` | Financial |
| Net Income | `{{NI_FIELD}}` | Financial |
| EPS | `{{EPS_FIELD}}` | Financial |
| <!-- Add KPIs --> | | Non-Financial |

## Data File Naming

`{category}_{content}_{fiscal_period}_{accounting_standard}.{ext}`

| Category Key | Description |
|-------------|-------------|
| `financial` | PL, BS, CF statements |
| `kpi` | Non-financial KPIs (ARR, NRR, churn, etc.) |
| `market` | Stock price, market data |

Examples: `financial_pl_2025Q4_jgaap.csv`, `kpi_arr_2025-12.csv`
