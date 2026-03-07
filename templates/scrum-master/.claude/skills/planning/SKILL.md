---
name: planning
description: Generate a sprint planning dashboard. Fetches data from GitHub Project and Notion standup page to produce point summaries, category analysis, and Next Sprint proposals. Use when the user says "/planning", "run today's planning", "show sprint status", "check remaining tasks", or "plan the next sprint". Proactively trigger in standup or sprint planning contexts.
---

# Planning — Sprint Dashboard

Integrates sprint data from GitHub Project and the Notion standup page to generate a team planning view.

## Why This Skill Is Needed

Understanding sprint status requires many steps: aggregating raw data from GitHub Project, fetching goals from Notion, analyzing by category, and proposing Next Sprint candidates. This skill executes all of these at once and consolidates the information into a single dashboard for decision-making.

## Data Sources

1. **GitHub Project** — Refer to `CLAUDE.md` for Project number and Org
2. **Notion Standup DB** — Refer to `CLAUDE.md` Key Notion Pages (for sprint goals and events)
3. **Team composition** — Refer to `docs/team.md`. Highlight the owner's tasks first (owner defined in `CLAUDE.md`)
4. **Rules** — `.claude/rules/sprint-config.md` (status mapping, velocity calculation, Next Sprint priority)
5. **Sprint history** — Past data in `docs/sprint-history/` (for velocity estimation)

## Steps

### Step 1: Fetch GitHub Project Data

```bash
gh project item-list {PROJECT_NUMBER} --owner {ORG} --format json --limit 200
```

After fetching, filter by the current sprint (`sprint.title`). Calculate points from Sprint Items only; treat Non-Sprint Items as Next Sprint candidates.

### Step 2: Fetch Notion Standup Page

Use the Daily Standup DB URL from `CLAUDE.md` to fetch sprint goals and upcoming events via Playwright.

### Step 3: Point Aggregation & Analysis

- Follow `sprint-config.md` status mapping; count In Review as completed (Done)
- Follow `sprint-config.md` velocity calculation rules
- If past 3 sprints of data exist in `docs/sprint-history/`, estimate velocity using a moving average
- Rank Next Sprint candidates using `sprint-config.md` priority rules

### Step 4: Generate Dashboard

Output following the language setting in `output-language.md`.

### Step 5: Save and Confirm

Save to `docs/planning/{YYYY-MM-DD}-sprint{N}.md` and display to the user. Save sprint performance data to `docs/sprint-history/sprint-{N}.json`.
