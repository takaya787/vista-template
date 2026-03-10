---
name: weekly-update
description: Generate a weekly update report from GitHub Project data. Measures SP consumption from current sprint items only, with remaining SP by category. Use when the user says "/weekly-update", "summarize this week's progress", "create a weekly report", "generate a weekly update", or "show changes since last week". Proactively trigger at end-of-week or start-of-week reporting times.
---

# Weekly Update Generator

Fetches GitHub Project data and generates a weekly update document including diffs from the previous report.

## Why This Skill Is Needed

Weekly reports are an important communication tool for conveying project progress to stakeholders and team members. By calculating diffs from GitHub Project raw data and showing trends by category, this skill auto-generates reports that make it clear at a glance "what progressed and what stalled."

## Data Sources

- **GitHub Project** — Refer to `rules/config/github-workflow.md` for Org and Project number
- **Previous report** — Latest file in `docs/weekly-updates/` (for diff calculation)
- **Issue details** — Refer to `rules/config/github-workflow.md` for the Issue repository
- **Sprint history** — Past data in `docs/sprint-history/` (for trend analysis)

## Steps

### Step 1: Fetch Project Data

Use Org and Project number from `rules/config/github-workflow.md`:

```bash
gh project item-list <PROJECT_NUMBER> --owner <ORG_NAME> --format json --limit 200
```

### Step 2: Calculate Sprint Consumption

SP consumption is measured only from current sprint items.

### Step 3: Generate Report

Output following the language setting and status label mapping in `output-language.md`.

### Step 4: Save

Save to `docs/weekly-updates/{YYYY-MM-DD}.md`.

### Step 5: Confirm with User

Display the report and prompt the user to add to the "This Week's Updates" section.

## Output Format

Save as `docs/weekly-updates/{YYYY-MM-DD}.md` with this structure:

```markdown
---
date: YYYY-MM-DD
sprint: N
sources:
  - github-project
  - sprint-history/sprint-{N-1}.json
---

## TL;DR

- (Most significant progress — 1 line)
- (Biggest blocker or risk — 1 line)
- (Recommended action — 1 line)

## Sprint Consumption

| Metric | This Week | Last Week | Diff |
|--------|-----------|-----------|------|
| Done + In Review | X pt | Y pt | +Z pt |
| In Progress | X pt | Y pt | +Z pt |
| Sprint Backlog | X pt | Y pt | -Z pt |
| Completion Rate | X% | Y% | +Z% |

## Remaining SP by Category

| Category | Remaining SP | % of Total |
|----------|-------------|------------|
| ... | X | X% |

## Key Movements

- (Completed items and newly added items this week)

## This Week's Updates

(User fills in manually after review)
```

Diff notation: use `+Xpt` / `-Xpt` for increases/decreases. Highlight significant changes (>20% swing) in bold.
