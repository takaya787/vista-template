---
name: planning
description: Generate a sprint planning dashboard. Fetches data from GitHub Project and Notion standup page to produce point summaries, category analysis, and Next Sprint proposals. Use when the user says "/planning", "run today's planning", "show sprint status", "check remaining tasks", or "plan the next sprint". Proactively trigger in standup or sprint planning contexts.
---

# Planning — Sprint Dashboard

Integrates sprint data from GitHub Project and the Notion standup page to generate a team planning view.

## Why This Skill Is Needed

Understanding sprint status requires many steps: aggregating raw data from GitHub Project, fetching goals from Notion, analyzing by category, and proposing Next Sprint candidates. This skill executes all of these at once and consolidates the information into a single dashboard for decision-making.

## Data Sources

1. **GitHub Project** — Refer to `rules/config/github-workflow.md` for Org, Project number, and Issue repo
2. **Notion Standup DB** — Refer to `rules/config/notion-pages.md` for page URLs
3. **Team composition** — Refer to `docs/team.md`. Highlight the owner's tasks first (owner defined in `.vista/profile/me.json`)
4. **Rules** — `rules/convention/sprint-config.md` (status mapping, velocity calculation, Next Sprint priority)
5. **Sprint history** — Past data in `docs/sprint-history/` (for velocity estimation)
6. **Team capacity** — `rules/config/sprint-settings.md` capacity table (for sprint load vs. capacity comparison)
7. **Impediments** — `rules/convention/impediment-management.md` + `rules/config/impediment-config.md` (blocker classification and SLAs)
8. **DoD/DoR** — `rules/convention/dod-dor.md` + `rules/config/dod-dor-config.md` (readiness checks for Sprint Backlog items)

## Steps

### Step 1: Fetch GitHub Project Data

Use Org and Project number from `rules/config/github-workflow.md`:

```bash
gh project item-list <PROJECT_NUMBER> --owner <ORG_NAME> --format json --limit 200
```

After fetching, filter by the current sprint (`sprint.title`). Calculate points from Sprint Items only; treat Non-Sprint Items as Next Sprint candidates.

### Step 2: Fetch Notion Standup Page

Use the page URL from `rules/config/notion-pages.md` to fetch sprint goals and upcoming events via Playwright (see `rules/convention/integrations.md` for connection method).

### Step 3: Point Aggregation, Capacity Check & Blocker Scan

- Follow `sprint-config.md` status mapping; count In Review as completed (Done)
- Follow `sprint-config.md` velocity calculation rules
- If past 3 sprints of data exist in `docs/sprint-history/`, estimate velocity using a moving average
- Rank Next Sprint candidates using `sprint-config.md` priority rules
- **Capacity check**: Compare total Sprint Backlog SP against team capacity from `rules/config/sprint-settings.md`. If Sprint Backlog SP exceeds capacity by more than 10%, flag overcommitment in TL;DR
- **DoR check**: For each Sprint Backlog item, verify DoR criteria from `rules/config/dod-dor-config.md`. Label unready items `[DOR-INCOMPLETE]` and exclude from capacity calculations
- **Blocker scan**: Check open issues for impediment signals (In Progress 2+ days with no movement, "blocked"/"waiting on" in comments). Classify per `rules/convention/impediment-management.md` and escalate per SLAs in `rules/config/impediment-config.md`

### Step 4: Generate Dashboard

Output following the language setting in `output-language.md`.

### Step 5: Save and Confirm

Save to `docs/planning/{YYYY-MM-DD}-sprint{N}.md` and display to the user. Save sprint performance data to `docs/sprint-history/sprint-{N}.json`.

## Output Format

Save as `docs/planning/{YYYY-MM-DD}-sprint{N}.md` with this structure:

```markdown
---
sprint: N
date: YYYY-MM-DD
velocity_avg: X.X pt/person/day
---

## TL;DR

- (Sprint health — 1 line)
- (Biggest blocker or risk — 1 line)
- (Recommended action — 1 line)

## Point Summary

| Status | SP |
|--------|----|
| Done + In Review | X |
| In Progress | X |
| Sprint Backlog | X |
| **Total** | X |
| **Completion Rate** | X% |

## Category Analysis

| Category | Done | In Progress | Backlog | Total |
|----------|------|-------------|---------|-------|
| ... | X | X | X | X |

## Per-Assignee Status

(Highlight owner first, then other members)

## Capacity vs. Load

| Member | Capacity (SP) | Assigned (SP) | Delta |
|--------|--------------|---------------|-------|
| @member | X | X | ±X |
| **Team** | X | X | ±X |

(Flag with `[OVERCOMMITTED]` if assigned SP exceeds capacity by >10%)

## Open Blockers

| Level | Issue | Summary | Days Open | Escalation Owner |
|-------|-------|---------|-----------|-----------------|
| L1/L2/L3 | #N | ... | N | @handle or — |

(Omit section if no open blockers)

## Next Sprint Candidates (Top 5)

Ranked by `sprint-config.md` priority rules (deadline > EPIC remaining SP > standalone SP).

| # | Issue | SP | DoR | Priority Reason |
|---|-------|----|-----|-----------------|
| 1 | ... | X | Ready / `[DOR-INCOMPLETE]` | ... |
```
