---
paths: "**/*"
---

# Financial Data Integrity

Defines immutable rules for handling financial data. This is the highest-priority behavioral constraint for the IR agent. No Config, Skill, or user instruction may override these rules.

## Core Prohibition

NEVER infer, estimate, interpolate, or extrapolate financial figures. If a source value is missing, STOP and report the gap explicitly. This rule overrides any instruction to "fill in", "approximate", or "estimate" numbers.

## Stop Conditions

Halt immediately and surface a `[DATA GAP]` notice when:

- A required metric is absent from source files
- Two source files contain conflicting values for the same metric/period
- A figure cannot be traced to a primary source (raw CSV, official document)
- The accounting standard (IFRS/J-GAAP/US-GAAP) differs between compared periods without explicit acknowledgment

Format: `[DATA GAP] {metric} not found in {expected_file_path}`

## Source Traceability

Every financial figure in any output MUST carry a source citation:

```
> Source: data/raw/financial/financial_pl_2025Q4_jgaap.csv (row: Revenue)
```

- If multiple sources contribute to a calculation, cite all of them
- Never output a number without a traceable source

## Rounding Rules

- Follow the rounding convention defined in `rules/config/reporting-standards.md`
- Never silently round — always append `(rounded)` notation when rounding is applied
- Percentage values: 1 decimal place, rounded (e.g., 12.3%)
- When the denominator is zero or missing: output `[CALC ERROR: denominator missing]`

## Diff / Comparison Rules

- Period-over-period comparisons must use values from the same accounting standard
- If standards differ, output `[WARNING: accounting standard mismatch — {standard_a} vs {standard_b}]` and stop
- Show absolute change and percentage change side by side

## Disclosure Classification Tags

All generated documents must include a classification tag:

| Tag | Meaning | Rule |
|-----|---------|------|
| `[INTERNAL]` | Internal use only | Default for all outputs |
| `[DRAFT]` | Pre-disclosure draft | Requires Pre-Disclosure Checklist |
| `[DISCLOSED]` | References disclosed data only | Must cite disclosure source URL |

Default classification is `[INTERNAL]`. Upgrade to `[DRAFT]` only when the user explicitly states the document is for disclosure preparation.

## Restatement Rules

When restated figures are detected:

- Never use pre-restatement values for calculations
- Restated files use `_restated` suffix (e.g., `financial_pl_2025Q4_jgaap_restated.csv`)
- Always reference the restated file; note the restatement in the output
