---
name: design-consistency-audit
description: Audit multiple design assets in design/inbox/ for cross-screen consistency violations in tokens, spacing, typography, and component patterns. Use when the user says "/design-consistency-audit", "一貫性をチェック", "consistency audit", "デザインの統一性を確認", "複数画面の整合性確認", or "design drift check". Proactively trigger when 3 or more files appear in design/inbox/ simultaneously.
---

# Design Consistency Audit

Examine multiple design assets for cross-screen and cross-component consistency violations, comparing against each other and against the processed token set.

## Why This Skill Is Needed

Design systems degrade silently through drift: spacing values diverge between screens, tokens are replaced by hardcoded values, and component variants multiply informally. A single-screen review (`/design-review`) cannot detect this drift — it requires comparing assets against each other. This skill provides that horizontal audit before inconsistencies reach engineering.

## Difference from /design-review

| Dimension | /design-review | /design-consistency-audit |
|-----------|---------------|--------------------------|
| Scope | Single screen or component | Multiple assets compared cross-screen |
| Goal | Quality assessment per asset | Pattern violations across assets |
| Output | Severity-sorted findings for one screen | Violation matrix by category across all assets |
| Token check | Incidental (when token values are visible) | Systematic — all extractable values checked |
| Save location | `docs/design-review/` | `docs/design-review/` (with `-consistency-audit` suffix) |

## Input Requirements

| Format | Action |
|--------|--------|
| 2+ screenshots in `design/inbox/` | Read all images; compare |
| 1 screenshot only | `[REQUIRES INPUT]` — Consistency audit needs 2 or more assets to compare. Add more files to `design/inbox/` or use `/design-review` for single-asset review. |
| Spec text describing multiple components | Compare descriptions directly |
| Figma URL only | `[REQUIRES INPUT]` — Claude Code cannot open Figma directly. Save screenshots to `design/inbox/` and re-run. |
| No files | `[REQUIRES INPUT]` — Ask: "Please add design files to `design/inbox/` or paste spec descriptions for the screens you want to audit." and stop. |

## Data Sources

1. **Design assets** — all files in `design/inbox/` (screenshots, pasted text)
2. **Processed tokens** — `design/tokens/processed/` for the canonical token set
3. **Component specs** — `design/specs/` for established component patterns
4. **Accessibility standards** — `rules/convention/accessibility-standards.md` for contrast and target size thresholds
5. **Token naming convention** — `rules/convention/design-artifacts.md`

## Steps

### Step 1: Inventory and Scope

List all files in `design/inbox/`. Confirm with the user:
- Which files are in scope (if inbox contains mixed materials)
- What the comparison context is (e.g., "all onboarding screens", "card component variants", "mobile and desktop counterparts")

If fewer than 2 comparable assets are present after scoping, emit `[REQUIRES INPUT]` and stop.

### Step 2: Extract Values from Each Asset

For each asset, record observable design values:

| Property type | What to extract |
|---------------|----------------|
| Spacing | Gap, padding, and margin values (in px or as token names if labeled) |
| Color | Background, text, border, icon, and overlay colors |
| Typography | Font size, weight, line-height, font family |
| Shape | Border radius values |
| Elevation | Shadow styles |
| Components | Component names, variants, and states used |

For each extracted value, note whether it appears to reference a token (named) or is a raw value (hardcoded).

Check `design/tokens/processed/` for the canonical token values.

### Step 3: Cross-Asset Comparison

Compare extracted values across assets and against `design/tokens/processed/`. Flag each violation:

| Violation type | Tag | Definition |
|----------------|-----|-----------|
| Same semantic role, different value across screens | `[INCONSISTENT]` | e.g., primary button padding is 12px on screen A, 16px on screen B |
| Value does not match any processed token | `[OFF-TOKEN]` | e.g., a hardcoded `#1C64F2` where `color.primary.500` should be used |
| Component used in a non-standard variant or context | `[PATTERN-DRIFT]` | e.g., a card component with a custom shadow not in the token set |
| Spacing value not on the token grid | `[GRID-VIOLATION]` | e.g., 14px gap where the nearest tokens are 12px (`spacing.sm`) and 16px (`spacing.md`) |
| A11Y: contrast ratio below threshold | `[A11Y-CONTRAST]` | Per `rules/convention/accessibility-standards.md` |
| A11Y: touch target below minimum size | `[A11Y-TARGET]` | Per `rules/convention/accessibility-standards.md` |

Record for each violation:
- Which assets are affected (list screen/file names)
- The conflicting values observed
- The recommended token or pattern to standardize on

### Step 4: Classify Severity

| Violation | Severity |
|-----------|---------|
| `[OFF-TOKEN]` on color or typography | MAJOR |
| `[INCONSISTENT]` on primary interactive elements | MAJOR |
| `[PATTERN-DRIFT]` that breaks component contract | MAJOR |
| `[GRID-VIOLATION]` on layout-critical spacing | MINOR |
| `[INCONSISTENT]` on decorative or non-interactive elements | MINOR |
| `[A11Y-CONTRAST]` or `[A11Y-TARGET]` | Per `accessibility-standards.md` severity table |

### Step 5: Generate Audit Report

Save to `docs/design-review/{YYYY-MM-DD}-consistency-audit.md`.

## Output Format

```markdown
---
date: YYYY-MM-DD
scope: <description of screens or components audited>
assets: <list of filenames from design/inbox/>
status: [DRAFT]
---

## TL;DR

- (Most widespread violation — 1 line)
- (Most impactful single finding — 1 line)
- (Recommended first fix — 1 line)

## Violation Matrix

| Category | Violation count | Assets affected |
|----------|----------------|----------------|
| Color (OFF-TOKEN / INCONSISTENT) | N | screen-a, screen-b |
| Spacing (GRID-VIOLATION / INCONSISTENT) | N | |
| Typography (OFF-TOKEN / INCONSISTENT) | N | |
| Component patterns (PATTERN-DRIFT) | N | |
| Accessibility (A11Y-CONTRAST / A11Y-TARGET) | N | |

## Findings

### MAJOR

#### [OFF-TOKEN] Color — Primary button background
- **Assets affected**: screen-a.png, screen-b.png
- **Observed values**: `#1C64F2` (screen-a), `#1A56DB` (screen-b)
- **Canonical token**: `color.primary.500` = (value from design/tokens/processed/)
- **Recommendation**: Apply `color.primary.500` uniformly. Run `/design-token-update` if processed tokens are out of date.

#### [INCONSISTENT] Spacing — Card body padding
- **Assets affected**: screen-a.png vs screen-c.png
- **Observed values**: 12px (screen-a), 20px (screen-c)
- **Nearest tokens**: `spacing.sm` (12px), `spacing.md` (16px), `spacing.lg` (24px)
- **Recommendation**: Standardize on `spacing.md` (16px). Confirm which screen follows the intended pattern.

### MINOR

#### [GRID-VIOLATION] Spacing — Gap between list items
...

## Assets with No Violations

- screen-d.png — all values within token spec

## Recommended Actions

1. (Most impactful fix — standardize X across N screens)
2. (Token hygiene — run /design-token-update if OFF-TOKEN violations suggest stale processed files)
3. (Component spec update — if PATTERN-DRIFT reveals an undocumented variant)

## Cannot Assess

- [CANNOT ASSESS — processed token file missing]: color tokens could not be verified against design/tokens/processed/ (file not found)
- [CANNOT ASSESS — token values required]: contrast ratio for {element} on {screen} requires exact token values
```

Note: This audit is `[DRAFT]` and requires designer review before sharing with engineers.
