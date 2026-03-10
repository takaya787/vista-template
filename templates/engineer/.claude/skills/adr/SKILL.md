---
name: adr
description: Draft an Architecture Decision Record for a technical decision. Use when the user says "/adr", "write an ADR", "document this decision", "architecture decision", "アーキテクチャ決定を記録して", "why did we pick X", or "record this choice". Proactively trigger when the user discusses choosing between two technical approaches.
---

# ADR — Architecture Decision Record

Draft a structured ADR that captures the problem, options considered, decision made, and reversibility assessment.

## Why This Skill Is Needed

Technical decisions made without documentation become "invisible architecture" — future contributors cannot understand why constraints exist and re-litigate settled debates. ADRs make decisions searchable, attributable, and auditable. The reversibility classification is required because the cost of a wrong decision is proportional to how hard it is to undo.

## Input Requirements

| Input | Action |
|-------|--------|
| User describes the decision | Draft directly |
| Discussion notes in `inbox/` | Read and synthesize |
| PR or issue number | Fetch with `gh pr view <n>` or `gh issue view <n>` for context |
| No problem statement provided | `[REQUIRES INPUT]` — Ask: "What is the architectural problem or decision you want to document?" and stop |
| Options exist but no decision made | Draft as status `Proposed`; list options without forcing conclusion |

## Data Sources

1. **Decision context** — user description, discussion, or linked PR/issue
2. **Existing ADRs** — `docs/adr/` for sequential numbering
3. **Tech stack** — `rules/config/tech-stack.md` for consistency check against existing choices

## Steps

### Step 1: Clarify Scope

Confirm with the owner (or infer from context):
- What is the problem being solved?
- Was a decision already made, or is this still being evaluated?
- Who are the relevant stakeholders?

If decided and implemented → status `Accepted`. If evaluating → status `Proposed`.

### Step 2: Extract Options

List every option that was seriously considered, not just the chosen one.
For each: advantages, disadvantages, why accepted or rejected.
If only one option described, ask: "Were any alternative approaches considered?"

### Step 3: Assess Reversibility

| Class | Definition | Examples |
|-------|-----------|---------|
| **Reversible** | Undone with a single PR, no data migration | Swapping a utility library |
| **Costly to reverse** | Multi-sprint effort or data migration | Changing ORM, splitting a service |
| **Effectively irreversible** | Reverting requires rebuilding dependent systems | Primary key strategy on live DB, cloud provider choice |

### Step 4: Draft ADR

Populate all required sections. For any missing context, insert `[SECTION REQUIRED — provide: {what is needed}]`.

### Step 5: Save and Confirm

Determine next sequence number from `docs/adr/`. Save to `docs/adr/{NNN}-{kebab-case-title}.md`.
If `docs/adr/` is empty, start at 001. Never renumber existing ADRs.
Remind user: change status from `Proposed` to `Accepted` when finalized.

## Output Format

```markdown
---
adr: NNN
title: <short title>
date: YYYY-MM-DD
status: Proposed | Accepted | Deprecated | Superseded by ADR-NNN
deciders: <owner + stakeholders>
reversibility: Reversible | Costly to reverse | Effectively irreversible
---

## Context

（What situation forced this decision? What constraints existed?）

## Decision

（What was decided, stated as a single clear sentence.）

## Options Considered

### Option A: <name>
**Pros**: ...
**Cons**: ...
**Verdict**: Chosen / Rejected — <reason>

### Option B: <name>
**Pros**: ...
**Cons**: ...
**Verdict**: Chosen / Rejected — <reason>

## Consequences

### Positive
- ...

### Negative / Tradeoffs
- ...

### Risks
- ...

## Reversibility Assessment

**Class**: Reversible | Costly to reverse | Effectively irreversible
**Rationale**: （Why this classification? What would reverting require?）
**Mitigation**: （If costly or irreversible: what reduces reversal cost?）

## Related

- ADR-NNN: <title>
- PR: <link>
```
