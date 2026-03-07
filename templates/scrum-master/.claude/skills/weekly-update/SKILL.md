---
name: weekly-update
description: Generate a weekly update report from GitHub Project data. Measures SP consumption from current sprint items only, with remaining SP by category. Use when the user says "/weekly-update", "summarize this week's progress", "create a weekly report", "generate a weekly update", or "show changes since last week". Proactively trigger at end-of-week or start-of-week reporting times.
---

# Weekly Update Generator

Fetches GitHub Project data and generates a weekly update document including diffs from the previous report.

## Why This Skill Is Needed

Weekly reports are an important communication tool for conveying project progress to stakeholders and team members. By calculating diffs from GitHub Project raw data and showing trends by category, this skill auto-generates reports that make it clear at a glance "what progressed and what stalled."

## Data Sources

- **GitHub Project** — Refer to `CLAUDE.md` for Project number and Org
- **Previous report** — Latest file in `docs/weekly-updates/` (for diff calculation)
- **Issue details** — Refer to `CLAUDE.md` for the Issue repository
- **Sprint history** — Past data in `docs/sprint-history/` (for trend analysis)

## Steps

### Step 1: Fetch Project Data

```bash
gh project item-list {PROJECT_NUMBER} --owner {ORG} --format json --limit 200
```

### Step 2: Calculate Sprint Consumption

SP consumption is measured only from current sprint items.

### Step 3: Generate Report

Output following the language setting and status label mapping in `output-language.md`.

### Step 4: Save

Save to `docs/weekly-updates/{YYYY-MM-DD}.md`.

### Step 5: Confirm with User

Display the report and prompt the user to add to the "This Week's Updates" section.
