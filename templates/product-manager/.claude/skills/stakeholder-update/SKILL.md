---
name: stakeholder-update
description: Write a stakeholder update memo or release note. Use when the user says "/stakeholder-update", "write a memo", "draft a release note", "update executives", "send an update to stakeholders", "progress report", "ステークホルダー報告を書いて", or "release noteを書いて". Proactively suggest after a prioritization session or when a milestone is reached.
---

# Stakeholder Update — Memo and Release Note

Draft a structured stakeholder update memo or release note tailored to the target audience.

## Why This Skill Is Needed

Stakeholder updates written ad hoc vary in format and completeness, causing stakeholders to ask follow-up questions that delay decisions. This skill enforces audience-specific structure — executives need decisions surfaced, cross-functional partners need dependencies, customers need capability descriptions — and ensures every update is grounded in source documents, not memory.

## Input Requirements

| Input | Action |
|-------|--------|
| Roadmap snapshot or PRD in `docs/` | Read and use as primary source |
| User describes the update verbally | Use as source; ask for audience if not specified |
| Milestone or sprint completion context | Read relevant `docs/prd/` or `docs/roadmap/` files |
| "Write an update" with no context | `[REQUIRES INPUT]` — Ask: "What is the update about, and who is the audience?" and stop |
| No source documents available | `[DATA REQUIRED — expected in: docs/prd/ or docs/roadmap/]` — Do not draft from memory |

## Data Sources

1. **Source documents** — `docs/prd/`, `docs/roadmap/`, `docs/research/` as applicable
2. **Product scope** — `rules/config/roadmap-settings.md` for product name and current OKR period
3. **PM data integrity** — `rules/convention/pm-data-integrity.md` for citation and draft labeling rules

## Steps

### Step 1: Confirm Audience and Purpose

Identify the target audience and update type:

| Audience | Typical purpose | Tone |
|----------|----------------|------|
| **Executive** | Decision request, milestone summary, risk escalation | Concise, outcome-focused, lead with ask |
| **Cross-functional** (Engineering, Design, Sales, Legal) | Dependency update, timeline change, scope clarification | Specific, action-oriented, surface blockers |
| **External** (customers, partners) | Feature announcement, release note | Customer-language, benefit-focused, no internal jargon |

If audience is not specified, ask before proceeding.

### Step 2: Verify Source Material

Check that source documents exist in `docs/prd/` or `docs/roadmap/` for the topic being updated.

If no source document exists:
- Emit `[DATA REQUIRED — expected in: docs/prd/{feature} or docs/roadmap/]`
- Offer to create a PRD first with `/prd`
- Do not draft an update from unverified information

### Step 3: Draft Update

Populate the audience-appropriate template from the Output Format section below. For any field where source material is insufficient:
- Insert `[DATA REQUIRED — provide: {what is missing}]`
- Do not estimate or infer unless the owner explicitly requests it

### Step 4: Apply Source Citations

Every factual claim (status, date, metric, feature scope) must cite its source document:
```
> Source: docs/prd/{filename} or docs/roadmap/{filename}
```

### Step 5: Save

Save to `docs/stakeholder-updates/{YYYY-MM-DD}-{audience}-{topic-slug}.md`. Confirm with user before saving.

## Output Format

### Executive Memo

```markdown
---
date: YYYY-MM-DD
audience: Executive
topic: <topic>
status: [DRAFT]
---

## TL;DR

(2–3 sentences. What happened or is happening? What decision or awareness is needed?)

## Context

(1 paragraph. Why does this matter to the business? Reference OKR alignment if applicable.)
> Source: docs/roadmap/...

## Status

| Item | Status | Notes |
|------|--------|-------|
| <milestone or feature> | On track / At risk / Complete | |

## Risks

- (Key risks and their mitigation status. If none, state "No critical risks identified.")

## Ask / Next Decision Needed

- (What does the executive need to decide, approve, or be aware of?)
- Due: (date, if applicable)
```

---

### Cross-Functional Update

```markdown
---
date: YYYY-MM-DD
audience: <team name>
topic: <topic>
status: [DRAFT]
---

## What Changed

(Bullet points summarizing the change and its scope.)
> Source: docs/prd/...

## Timeline

| Milestone | Target date | Owner | Status |
|-----------|-------------|-------|--------|
| ... | YYYY-MM-DD | | |

## Dependencies on Your Team

- (Specific asks or handoffs required from the recipient team)
- Due: (date)

## Blockers

- (Any blockers that require action from this team. None if not applicable.)
```

---

### Release Note / External Update

```markdown
---
date: YYYY-MM-DD
audience: External
topic: <feature or release name>
status: [DRAFT]
---

## What's New

(1–2 sentences describing the capability in customer language. No internal jargon.)

## What You Can Do Now

- (User-facing benefit 1)
- (User-facing benefit 2)

## How to Get Started

(Brief steps or link to documentation. Use `[SECTION REQUIRED — provide: getting started steps]` if unknown.)

## Known Limitations

- (Any known gaps or edge cases customers should be aware of. None if not applicable.)
```

Note: All updates are `[DRAFT]` and require owner review before distribution.
