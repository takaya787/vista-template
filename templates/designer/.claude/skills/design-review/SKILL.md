---
name: design-review
description: Conduct a structured design review from screenshots or spec text. Use when the user says "/design-review", "デザインレビューして", "このデザインをチェック", "review this design", "フィードバック整理して", or "design feedback". Proactively trigger when image files exist in design/inbox/.
---

# Design Review

Conduct a structured, categorized design review from provided screenshots, spec text, or pasted feedback.

## Why This Skill Is Needed

Design review feedback tends to be unstructured and inconsistent in depth. This skill enforces category-based assessment with severity labels, ensuring that critical usability issues are not buried alongside minor style preferences. The structured output also serves as a handoff-ready document for engineers.

## Input Requirements

| Format | Action |
|--------|--------|
| Screenshots in `design/inbox/` (.png, .jpg) | Read images and analyze |
| Spec text or feedback pasted by user | Analyze directly |
| Figma URL only (no screenshot) | `[REQUIRES INPUT]` — Ask user to save a screenshot to `design/inbox/` and stop. Claude Code cannot open Figma directly |

If no input is available in any form, stop and ask the user to provide materials.

## Data Sources

1. **Review materials** — `design/inbox/` or user-pasted text
2. **Design tools config** — `rules/config/design-tools.md` for project context
3. **Design artifacts** — `rules/convention/design-artifacts.md` for directory rules
4. **Existing specs** — `design/specs/` for component context (if reviewing an existing component)

## Steps

### Step 1: Identify Input

Check `design/inbox/` for new files. If empty, ask the user for input.
Accept screenshots, pasted text, or exported review comments.

### Step 2: Establish Context

Before reviewing, confirm:
- What screen or component is being reviewed?
- What stage is this? (Exploration / Wireframe / Hi-fi / Pre-handoff)
- Are there specific concerns the user wants addressed?

### Step 3: Categorize Feedback

Assess every finding against these categories:

| Category | Tag | What to Assess |
|----------|-----|----------------|
| Visual Design | `[VISUAL]` | Layout, color, typography, spacing, alignment, brand consistency |
| User Experience | `[UX]` | Flow, affordance, cognitive load, error prevention, feedback |
| Copy & Content | `[COPY]` | Clarity, tone, length, localization readiness, placeholder text |
| Accessibility | `[A11Y]` | Contrast ratio, touch targets, focus order, screen reader hints — thresholds defined in `rules/convention/accessibility-standards.md` |
| Specification | `[SPEC]` | Missing states, edge cases, responsive behavior, interaction details |

### Step 4: Assign Severity

| Severity | Label | Meaning | Action Required |
|----------|-------|---------|-----------------|
| 1 | `BLOCKER` | Prevents launch or causes user harm | Must fix |
| 2 | `MAJOR` | Significant UX degradation or inconsistency | Should fix |
| 3 | `MINOR` | Polish issue, minor inconsistency | Nice to fix |
| 4 | `NICE-TO-HAVE` | Subjective improvement suggestion | Optional |

For all `[A11Y]` findings, assign severity exclusively from the table in `rules/convention/accessibility-standards.md`. Do not infer A11Y severity independently.

### Step 5: Generate Review Report

Group findings by severity (BLOCKER first). For each finding:

```
[BLOCKER|MAJOR|MINOR|NICE-TO-HAVE] [VISUAL|UX|COPY|A11Y|SPEC]
Location: <screen / component / area>
Issue: <what is wrong and why it matters>
Suggestion: <concrete improvement or direction>
```

### Step 6: Summary & Action Items

End with:
- Overall assessment: Approve / Revise / Needs Discussion
- Count of findings by severity
- Top 3 action items for the designer (prioritized)
- Engineer handoff items (if pre-handoff stage)

### Step 7: Save

Save to `docs/design-review/{YYYY-MM-DD}-{screen-name}.md`.

## Output Format

```markdown
---
date: YYYY-MM-DD
screen: <screen or component name>
stage: exploration | wireframe | hi-fi | pre-handoff
figma: <Figma URL if available>
---

## TL;DR

- (Most critical finding — 1 line)
- (Overall quality assessment — 1 line)
- (Recommended next step — 1 line)

## Findings

### BLOCKER

- [VISUAL|UX|COPY|A11Y|SPEC] **Location**: ...
  - Issue: ...
  - Suggestion: ...

### MAJOR

- ...

### MINOR

- ...

### NICE-TO-HAVE

- ...

## Summary

| Severity | Count |
|----------|-------|
| BLOCKER | X |
| MAJOR | X |
| MINOR | X |
| NICE-TO-HAVE | X |

**Assessment**: Approve / Revise / Needs Discussion

## Action Items

1. [BLOCKER] ...
2. [MAJOR] ...
3. [MAJOR] ...

## Engineer Handoff Notes

(Only if pre-handoff stage — list spec gaps that need resolution before handoff)
```
