---
paths: "**/*"
---

# Prioritization Standards

Defines immutable standards for feature prioritization frameworks, scoring rules, and roadmap placement.
For project-specific defaults (reach unit, effort unit, OKR period), see `rules/config/roadmap-settings.md`.
For data labeling rules ([ESTIMATED], [DATA REQUIRED]), see `rules/convention/pm-data-integrity.md`.

## Framework Selection Guide

Choose the framework based on data availability and the primary goal of the session:

| Situation | Recommended Framework |
|-----------|----------------------|
| Quantitative data available (reach, impact metrics) | RICE |
| Limited data, speed is priority | ICE |
| Stakeholder alignment is the primary goal | MoSCoW |
| Comparing features across multiple product areas | MoSCoW by theme, then RICE within each theme |

Default to the framework set in `rules/config/roadmap-settings.md` → Default framework.
If not configured, default to RICE when data is available, ICE otherwise.

## RICE Scoring

**Formula**: `(Reach × Impact × Confidence%) / Effort`

| Component | Definition | Notes |
|-----------|-----------|-------|
| Reach | Number of users affected per quarter | Unit from `roadmap-settings.md` → Reach unit |
| Impact | How much it moves the needle per user | 0.25 = minimal / 0.5 = low / 1 = medium / 2 = high / 3 = massive |
| Confidence | Certainty in reach and impact estimates | 10%–100%; reflect data quality honestly |
| Effort | Total person-time to build and ship | Unit from `roadmap-settings.md` → Effort unit |

- Any component without source data must be labeled `[ESTIMATED]` per `pm-data-integrity.md`
- If two or more components are `[ESTIMATED]`, mark the entire row `[LOW CONFIDENCE]`

## ICE Scoring

**Formula**: `Impact × Confidence × Ease` (each 1–10)

| Component | Definition |
|-----------|-----------|
| Impact | How significantly it improves the target metric |
| Confidence | How certain we are about impact and ease |
| Ease | How easy it is to implement (10 = very easy) |

Use ICE when RICE inputs are unavailable. All ICE scores are implicitly `[LOW CONFIDENCE]` — state this in the output.

## MoSCoW Classification

| Class | Definition | Capacity cap |
|-------|-----------|-------------|
| Must | Without this, the product fails or the release is blocked | Max 60% of capacity |
| Should | High value; pain if absent but not a blocker | No fixed cap |
| Could | Nice to have; include if capacity allows | Filler only |
| Won't | Out of scope for this horizon — document why | Must include rationale |

The 60% Must cap is non-negotiable. If Must items exceed capacity, escalate to the owner for scope reduction.

## Tie-Breaking Rules

When two features have equal scores, apply in order:

1. Higher Confidence wins (reduces delivery risk)
2. Stronger alignment with current OKR period wins (see `roadmap-settings.md` → Current OKR period)
3. Lower Effort wins (faster to validate)

## Score Validity

Scores older than **90 days** are considered stale and must be re-evaluated before roadmap placement.
Surface a `[SCORE STALE — scored on {date}]` notice when using scores beyond this threshold.

## Roadmap Placement Rules

A high score does not automatically place a feature in the "Now" horizon. Before placement:

1. Confirm OKR alignment: the feature must contribute to at least one Key Result in the current period
2. Confirm capacity: the team's available effort (from `roadmap-settings.md`) can accommodate it
3. Confirm dependencies: no blocking external dependencies without a resolution plan

Features that pass scoring but fail the above checks are placed in "Next" or "Later" with a note.
