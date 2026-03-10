---
paths: "**/*"
---

# Roadmap Settings

Project-specific roadmap configuration. Customize these values per product.
For prioritization framework standards, see `rules/convention/prioritization.md`.

## Product Scope

| Key | Value |
|-----|-------|
| Product name | `{{PRODUCT_NAME}}` |
| Product area | `{{PRODUCT_AREA}}` (e.g., Growth, Core Platform, Mobile) |
| Target user | `{{TARGET_USER}}` |

## Roadmap Horizon

| Horizon | Timeframe | Status |
|---------|-----------|--------|
| Now | `{{NOW_HORIZON}}` (e.g., This quarter) | Active development |
| Next | `{{NEXT_HORIZON}}` (e.g., Next quarter) | Committed |
| Later | `{{LATER_HORIZON}}` (e.g., 6-12 months) | Directional |

## OKR Cycle

| Key | Value |
|-----|-------|
| Cycle | `{{OKR_CYCLE}}` (e.g., Quarterly, Annual) |
| Current period | `{{CURRENT_OKR_PERIOD}}` (e.g., 2026-Q1) |

## Prioritization Defaults

| Key | Value |
|-----|-------|
| Default framework | `{{DEFAULT_PRIORITIZATION_FRAMEWORK}}` (RICE / ICE / MoSCoW) |
| Reach unit | `{{REACH_UNIT}}` (e.g., MAU, paying customers) |
| Effort unit | `{{EFFORT_UNIT}}` (e.g., person-weeks, story points) |

## Output Storage

| Artifact | Location |
|----------|----------|
| PRDs | `docs/prd/` |
| Roadmap snapshots | `docs/roadmap/` |
| Stakeholder memos | `docs/stakeholder-updates/` |
| Research synthesis | `docs/research/` |
