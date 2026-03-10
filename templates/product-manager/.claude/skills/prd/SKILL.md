---
name: prd
description: Draft a Product Requirements Document from provided context. Use when the user says "/prd", "write a PRD", "draft requirements", "product spec", "write up this feature", "feature document", or "PRD作って". Proactively trigger when inbox/ contains user research or feature briefs without a corresponding PRD.
---

# PRD — Product Requirements Document

Draft a structured PRD from provided feature context, user research, and business goals.

## Why This Skill Is Needed

PRDs written ad hoc vary widely in structure and completeness, leading to misaligned engineering implementations. This skill enforces a consistent structure that covers user problem, success metrics, scope boundaries, and edge cases — the information engineers most commonly report as missing.

## Input Requirements

| Input | Action |
|-------|--------|
| Feature brief or notes in `inbox/` | Read and use as source |
| User research files in `inbox/` | Synthesize and cite |
| User describes feature verbally | Use as source, ask for clarification on success metrics |
| No feature context provided | `[REQUIRES INPUT]` — Ask: "What is the feature or user problem you want to document?" and stop |

## Data Sources

1. **Feature context** — `inbox/` or user description
2. **Product scope** — `rules/config/roadmap-settings.md` for product name, target user, OKR period
3. **PM data integrity** — `rules/convention/pm-data-integrity.md` for source citation rules

## Steps

### Step 1: Confirm Scope

Ask (or infer from input):
- What is the user problem being solved?
- What is the target user? (confirm against `roadmap-settings.md` → Target user)
- What does success look like — any existing metrics targets?

If the user provides a brief, confirm the problem statement before expanding.

### Step 2: Synthesize Research

If research files exist in `inbox/`, extract: key pain points, representative quotes, frequency signals.
Apply `pm-data-integrity.md` source citation for every finding used.

### Step 3: Draft PRD Sections

Follow the Output Format below. For each section:
- Problem Statement: must answer who, what problem, current workaround, cost of the problem — no solution in this section
- Success Metrics: at least one primary metric (the needle it moves) and one guardrail metric (what must not regress)
- User Stories: `As a [persona], I want [action] so that [outcome]`
- Out of Scope: must be explicit — ambiguity here is the #1 cause of scope creep

Use `[DATA REQUIRED]` for any section where source material is missing and estimation is inappropriate.

### Step 4: Identify Open Questions

List explicit open questions the owner must resolve before the PRD is handoff-ready. Each question must have an owner and due date field.

### Step 5: Save

Save to `docs/prd/{YYYY-MM-DD}-{feature-name}.md`. Confirm with user.

## Output Format

```markdown
---
date: YYYY-MM-DD
feature: <feature name>
status: [DRAFT]
okr_period: (from roadmap-settings.md)
---

## Problem Statement

（Who has the problem, what is the problem, what is the current workaround, what is the cost?）

> Source: inbox/...

## Target User

（Primary user persona. Reference `rules/config/roadmap-settings.md` → Target user as baseline.）

## Success Metrics

| Metric | Type | Baseline | Target | Measurement |
|--------|------|----------|--------|-------------|
| ... | Primary | [DATA REQUIRED] | ... | ... |
| ... | Guardrail | ... | ... | ... |

## Scope

### In Scope

- ...

### Out of Scope

- ...

## User Stories

| As a... | I want to... | So that... |
|---------|-------------|------------|
| ... | ... | ... |

## Functional Requirements

1. ...

## Non-Functional Requirements

- Performance: ...
- Security: ...

## Edge Cases & Constraints

- ...

## Open Questions

| # | Question | Owner | Due |
|---|----------|-------|-----|
| 1 | ... | | |

## References

- Source: ...
```
