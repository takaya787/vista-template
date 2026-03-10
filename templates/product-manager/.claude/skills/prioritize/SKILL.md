---
name: prioritize
description: Score and rank a feature backlog using RICE, ICE, or MoSCoW frameworks from provided data. Use when the user says "/prioritize", "rank these features", "help me prioritize", "RICE score this", "what should we build next", or "feature scoring". Proactively trigger when files appear in inbox/ containing feature lists or backlog items.
---

# Prioritize — Feature Scoring

Score and rank a provided feature list using a structured prioritization framework.

## Why This Skill Is Needed

Prioritization without a consistent framework produces inconsistent recommendations that are hard to defend to stakeholders. This skill enforces explicit scoring with traceable sources for each component, so every recommendation can be explained and revisited.

## Input Requirements

| Input | Action |
|-------|--------|
| Feature list in `inbox/` (.md, .csv, .txt) | Read and parse |
| Feature list pasted by user | Analyze directly |
| Vague request with no features listed | `[REQUIRES INPUT]` — Ask user to provide the feature list or drop a file in `inbox/` and stop |
| Scores requested but no supporting data | `[REQUIRES INPUT]` — Ask user to provide reach/impact data or confirm estimation is acceptable |

## Data Sources

1. **Feature input** — `inbox/` or user-pasted list
2. **Product scope** — `rules/config/roadmap-settings.md` for product area, OKR period, and framework defaults
3. **PM data integrity** — `rules/convention/pm-data-integrity.md` for estimation labeling rules

## Steps

### Step 1: Confirm Framework

Ask the user (or detect from context):

| Framework | Best For |
|-----------|----------|
| **RICE** | When reach and impact data are available |
| **ICE** | Faster scoring when data is limited |
| **MoSCoW** | When stakeholder alignment, not scoring, is the goal |

Default: use `rules/config/roadmap-settings.md` → Default framework. If not set, use RICE when data is available, ICE otherwise.

### Step 2: Parse Feature List

Extract feature items from input. For each feature, identify any existing context: user problem, affected users, effort estimate, strategic alignment.

### Step 3: Score Each Feature

For RICE: score Reach, Impact, Confidence, Effort per feature.
- Reach: users/quarter in `{{REACH_UNIT}}`
- Impact: 0.25 (minimal) / 0.5 (low) / 1 (medium) / 2 (high) / 3 (massive)
- Confidence: 10-100%
- Effort: in `{{EFFORT_UNIT}}`
- Formula: `(Reach × Impact × Confidence) / Effort`

For ICE: score Impact (1-10), Confidence (1-10), Ease (1-10).

For MoSCoW: classify Must/Should/Could/Won't with rationale. Must = max 60% of capacity.

Apply `pm-data-integrity.md` rules: label any score component lacking source data as `[ESTIMATED]` with reasoning.

### Step 4: Rank and Identify Risks

Sort by score descending. Flag items where:
- Two or more components are `[ESTIMATED]` → mark as `[LOW CONFIDENCE]`
- Strategic alignment with current OKR period is unclear
- Tie-breaking: prefer higher Confidence (reduces risk)

### Step 5: Save and Confirm

Save to `docs/roadmap/{YYYY-MM-DD}-prioritization.md`. Confirm with user before finalizing.

## Output Format

```markdown
---
date: YYYY-MM-DD
framework: RICE | ICE | MoSCoW
okr_period: (from roadmap-settings.md)
status: [DRAFT]
---

## TL;DR

- （Top recommendation — 1 line）
- （Biggest uncertainty — 1 line）
- （Recommended next step — 1 line）

## Prioritized Backlog

### RICE Scoring

| # | Feature | Reach | Impact | Confidence | Effort | Score | Notes |
|---|---------|-------|--------|------------|--------|-------|-------|
| 1 | ... | ... | ... | ...% | ... | ... | |
| 2 | ... | ... [ESTIMATED] | ... | ...% | ... | ... | [LOW CONFIDENCE] |

> Source: inbox/{file_name}

### Strategic Alignment

| Feature | OKR Alignment | Notes |
|---------|--------------|-------|
| ... | ... | |

## Risks & Uncertainties

- （Items with [LOW CONFIDENCE] and why）

## Recommended Next Steps

1. ...
2. ...
3. ...
```
