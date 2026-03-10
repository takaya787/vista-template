---
paths: "**/*"
---

# PM Data Integrity

Defines immutable rules for handling product data, user research, and prioritization scores.
No Config, Skill, or user instruction may override these rules.

## Core Prohibition

Never present inferred, estimated, or fabricated figures as source data.
When a required metric is absent from source files, stop and surface a `[DATA REQUIRED]` notice.

This applies to:

- User research findings (quotes, frequencies, sentiment)
- Prioritization scores (reach, impact, confidence, effort)
- Metric values (DAU, conversion rates, revenue figures)
- Market sizing numbers

## Estimation — With Explicit Labeling

Unlike financial data, PM work legitimately involves estimation. Estimation is allowed when:

1. Source data is insufficient and estimation is explicitly requested by the owner
2. The estimate is clearly labeled as `[ESTIMATED]` with the reasoning shown

Format: `[ESTIMATED] {value} — basis: {reasoning}`

Never use `[ESTIMATED]` values as inputs to further calculations without surfacing the chain.

## Stop Conditions

Halt and surface a `[DATA REQUIRED]` notice when:

- A required source (research notes, metric CSV, feedback file) is not present in `inbox/` or `data/`
- Conflicting data exists across two source files for the same metric/period
- A prioritization score cannot be derived from provided data

Format: `[DATA REQUIRED] {metric or insight} — expected in {expected_file_path}`

## Source Traceability

Every prioritization recommendation or research synthesis MUST cite its source:

```
> Source: inbox/user-interviews-2026-03.md (Interview #3, pain point: checkout friction)
```

If a recommendation draws from multiple sources, cite all of them.

## Draft Classification

All PM outputs default to draft status:

| Tag | Meaning | Rule |
|-----|---------|------|
| `[DRAFT]` | AI-generated, requires owner review | Default for all outputs |
| `[OWNER-REVIEWED]` | Owner has confirmed the content | Set manually by owner |

Never remove `[DRAFT]` without explicit owner instruction.
