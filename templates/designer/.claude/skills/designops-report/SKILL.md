---
name: designops-report
description: Generate a DesignOps health report covering spec coverage, token hygiene, review throughput, and open deprecations. Use when the user says "/designops-report", "DesignOpsレポート", "design system health", "デザインシステムの状態確認", "how healthy is our design system", or "sprint design summary". Proactively trigger at sprint boundaries.
---

# DesignOps Report

Generate a DesignOps health report from local design artifacts. Surfaces spec coverage gaps, token hygiene issues, open deprecations, review throughput, and handoff quality signals.

## Why This Skill Is Needed

Design system health degrades silently. Specs go stale, deprecated tokens linger, and review throughput slows without anyone noticing until engineers start filing "design doesn't match" bugs. This report makes health measurable — a single dashboard a designer can run in 30 seconds to know what needs attention before the next sprint.

## Input Requirements

This skill reads local files only. No external service access is required.

| Check | Source |
|-------|--------|
| Spec coverage | `design/specs/` directory tree |
| Token hygiene | `design/tokens/raw/` and `design/tokens/processed/` |
| Changelog activity | `docs/design-system/changelog.md` |
| Review throughput | `docs/design-review/` directory tree |
| Open deprecations | `docs/design-system/changelog.md` — deprecated entries without removal confirmation |

If a source directory does not exist, note it as `[NOT INITIALIZED]` in the relevant section and continue — do not stop.

## Data Sources

1. **Spec documents** — `design/specs/`
2. **Token files** — `design/tokens/raw/`, `design/tokens/processed/`
3. **Design system changelog** — `docs/design-system/changelog.md`
4. **Design reviews** — `docs/design-review/`
5. **Design tools config** — `rules/config/design-tools.md` (for context on platform and tooling)

## Steps

### Step 1: Spec Coverage Audit

Scan `design/specs/`:
- Count total components with a spec document
- Flag specs not updated in the last 60 days as `[STALE]`
- Flag specs with any `[SPEC REQUIRED: ...]` placeholder as `[INCOMPLETE]`
- Note components that have multiple dated versions (shows active maintenance)

**Cannot assess**: which components *should* have specs but do not — surface as `[CANNOT ASSESS — no component inventory found]` if no component list exists in `docs/` or `design/`.

### Step 2: Token Hygiene Check

Compare `design/tokens/raw/` and `design/tokens/processed/`:
- Flag any raw file dated more than 30 days ago with no corresponding processed update as `[TOKEN SYNC GAP]`
- Count total token categories (color, spacing, typography, radius, shadow, other)
- Flag any processed file that references raw values (hex or px) instead of token names as `[HARDCODED VALUE]`
- Count `[TOKEN REQUIRED]` placeholders across all spec documents in `design/specs/`

### Step 3: Deprecation Tracking

Scan `docs/design-system/changelog.md` for all `#### Deprecated` entries:
- List each deprecated token or component
- Calculate days since deprecation date
- Flag as `[OVERDUE]` if removal target date has passed
- Flag as `[SUNSET WARNING]` if removal target date is within 14 days

### Step 4: Changelog Activity

Scan `docs/design-system/changelog.md`:
- Count entries in the last 30 days
- Count entries in the last 90 days
- List the 3 most recent entries (date + summary line)

Low activity (0 entries in 30 days) is not inherently a problem — surface as `[LOW ACTIVITY]` for the designer to interpret.

### Step 5: Review Throughput

Scan `docs/design-review/`:
- Count reviews in the last 30 days
- Count reviews by assessment verdict (Approve / Revise / Needs Discussion)
- Count total findings by severity across all recent reviews:
  - BLOCKER, MAJOR, MINOR, NICE-TO-HAVE
- Flag any review file older than 14 days with a `pre-handoff` stage that has not been followed by a spec in `design/specs/` as `[HANDOFF GAP]`

### Step 6: Generate Report

Output the report to the user. Save to `docs/design-system/{YYYY-MM-DD}-designops-report.md`.

## Output Format

```markdown
---
date: YYYY-MM-DD
period: last-30-days | sprint-N | custom
---

## TL;DR

- (Most urgent action — 1 line)
- (Design system health signal — 1 line)
- (One recommended next step — 1 line)

## Spec Coverage

| Metric | Count |
|--------|-------|
| Total component specs | N |
| Stale (>60 days, no update) | N |
| Incomplete ([SPEC REQUIRED] placeholders) | N |
| Actively maintained (multiple versions) | N |

### Stale Specs

| Component | Last updated | Status |
|-----------|-------------|--------|
| ComponentName | YYYY-MM-DD | [STALE] |

### Incomplete Specs

| Component | Open placeholders |
|-----------|-----------------|
| ComponentName | 3 × [SPEC REQUIRED] |

## Token Hygiene

| Metric | Status |
|--------|--------|
| Token categories tracked | N |
| Raw → processed sync gaps | N [TOKEN SYNC GAP] |
| Hardcoded values in processed files | N [HARDCODED VALUE] |
| [TOKEN REQUIRED] in specs | N |

### Sync Gaps

| Raw file | Last processed | Gap (days) |
|----------|---------------|-----------|
| colors-YYYY-MM-DD.json | YYYY-MM-DD | N |

## Open Deprecations

| Token / Component | Deprecated on | Removal target | Status |
|-------------------|--------------|----------------|--------|
| color.brand.legacy | YYYY-MM-DD | YYYY-MM-DD | [OVERDUE] |
| ComponentName | YYYY-MM-DD | YYYY-MM-DD | [SUNSET WARNING] |

## Changelog Activity

| Period | Entries |
|--------|---------|
| Last 30 days | N |
| Last 90 days | N |

### Recent Entries

| Date | Summary |
|------|---------|
| YYYY-MM-DD | ... |
| YYYY-MM-DD | ... |
| YYYY-MM-DD | ... |

## Review Throughput (Last 30 Days)

| Metric | Value |
|--------|-------|
| Reviews conducted | N |
| Approve | N |
| Revise | N |
| Needs Discussion | N |

### Finding Distribution

| Severity | Total across reviews |
|----------|---------------------|
| BLOCKER | N |
| MAJOR | N |
| MINOR | N |
| NICE-TO-HAVE | N |

### Handoff Gaps

| Review | Date | Stage | Gap |
|--------|------|-------|-----|
| screen-name | YYYY-MM-DD | pre-handoff | [HANDOFF GAP] — no spec created |

## Action Items

1. [URGENT] ...
2. [SOON] ...
3. [MONITOR] ...

## Cannot Assess

- [CANNOT ASSESS — ...]: description of what data would be needed to assess this
```
