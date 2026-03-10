---
paths:
  - "docs/design-system/**"
  - "design/tokens/**"
  - "design/specs/**"
---

# Design System Changelog Convention

Defines the immutable standard for recording and maintaining the design system changelog.
All changes to tokens, components, patterns, and deprecated elements must be logged here before being communicated to engineers.

## Why a Changelog Matters

The design system changelog is the authoritative record of what changed, why, and what engineers need to do. Without it, teams discover breaking changes through failed builds rather than planned migrations. The changelog is also the input for sprint-level DesignOps reporting and deprecation tracking.

## File Location

Single file: `docs/design-system/changelog.md`

This file is append-only. Never delete or rewrite existing entries. Corrections go in a new entry that references the corrected entry's date.

## Entry Trigger Rules

A changelog entry is REQUIRED when any of the following occurs:

| Trigger | Who creates the entry |
|---------|----------------------|
| Token added | `/design-token-update` skill (automatic) |
| Token value changed | `/design-token-update` skill (automatic) |
| Token deprecated | `/design-token-update` skill (automatic) |
| Token renamed | `/design-token-update` skill (automatic) |
| New component spec created | Designer (manual), prompted by `/spec-handoff` |
| Component spec updated (breaking) | Designer (manual) |
| Component deprecated | Designer (manual) |
| Pattern or layout guideline changed | Designer (manual) |
| Accessibility requirement updated | Designer (manual) |

Minor spec fixes (typos, clarifying notes) do not require a changelog entry unless they change implementation behavior.

## Entry Format

Each entry is a level-2 heading with the date, followed by structured sections.
Entries are ordered newest-first (prepend, do not append).

```markdown
## YYYY-MM-DD

### Summary

<One sentence describing the most significant change in this release.>

### Changes

#### Added

- `{token.name}` — {description of what it is and where to use it}
- `ComponentName` v1 — {brief description}

#### Changed

- `{token.name}` — `{old value}` → `{new value}`. Reason: {why this changed}.
- `ComponentName` — {what changed in behavior or spec}. See `design/specs/{component-name}/{YYYY-MM-DD}.md`.

#### Deprecated

- `{token.name}` — Replaced by `{new.token.name}`. **Removal target: {YYYY-MM-DD}**. Migration: replace all usages of `--{old-css-var}` with `--{new-css-var}`.
- `ComponentName` — Use `NewComponentName` instead. Migration guide: {brief steps or doc link}.

#### Renamed

- `{old.token.name}` → `{new.token.name}` — Value unchanged (`{value}`). Update all references.

### Affected Components

List components from `design/specs/` whose implementation references any changed or deprecated token:

- `design/specs/{component-name}/{YYYY-MM-DD}.md` — uses `{token.name}`

### Engineer Action Required

| Priority | Action |
|----------|--------|
| `[BREAKING]` | Must update before next release: {specific action} |
| `[MIGRATION]` | Replace deprecated token `{old}` with `{new}` — deadline: {YYYY-MM-DD} |
| `[INFORMATIONAL]` | No code changes needed; awareness only |

### Source

- Raw token file: `design/tokens/raw/{filename}` (if applicable)
- Figma: {Figma URL or "n/a"}
- Requested by: {requester name or "design team"}
```

## Deprecation Lifecycle

All deprecated tokens and components follow this lifecycle:

| Phase | Duration | State |
|-------|----------|-------|
| Deprecated | Min. 2 sprints | Exists in processed files, wrapped in deprecation comment |
| Sunset warning | 1 sprint | Changelog entry reminder; ping engineering lead |
| Removed | After sunset warning | Removed from processed files; raw file is immutable |

Removal target dates are set at deprecation time and must not be shortened without engineering team agreement.

## Changelog File Skeleton

When `docs/design-system/changelog.md` does not yet exist, initialize it with:

```markdown
# Design System Changelog

All notable changes to tokens, components, and patterns are documented here.
Newest entries appear first. This file is maintained by the Senior Designer AI.

<!-- Entries below this line are added automatically or manually per convention/design-system-changelog.md -->
```

## Relationship to Other Files

- `rules/convention/design-artifacts.md` — defines where token files and spec docs live
- `/design-token-update` skill — creates changelog entries for all token changes automatically
- `/designops-report` skill — reads this file to generate health metrics
- `design/tokens/raw/` — source of truth for token values; never modified
- `design/tokens/processed/` — output files; updated by `/design-token-update` only
