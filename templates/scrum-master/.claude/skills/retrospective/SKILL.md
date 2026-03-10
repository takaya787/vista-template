---
name: retrospective
description: Facilitate a sprint retrospective and generate a structured retrospective report. Use when the user says "/retrospective", "run the retro", "sprint retrospective", "let's do a retro", or "振り返り". Proactively suggest at sprint end (Friday) or when a new sprint begins.
---

# Sprint Retrospective

Facilitate a structured sprint retrospective by gathering sprint data, reviewing previous action items, and guiding the team through a reflection format.

## Why This Skill Is Needed

Retrospectives are the primary mechanism for continuous improvement in Scrum. Without structured facilitation, retros tend to become shallow or repetitive. This skill ensures that previous action items are tracked, sprint data informs the discussion, and new action items are concrete and accountable.

## Data Sources

1. **GitHub Project** — Refer to `rules/config/github-workflow.md` for Org and Project number
2. **Sprint history** — `docs/sprint-history/sprint-{N}.json` for velocity and completion data
3. **Previous retrospective** — Latest file in `docs/retrospectives/` for action item follow-up
4. **Team composition** — `docs/team.md` for participants

## Steps

### Step 1: Confirm Sprint Number

Use the sprint number if provided as an argument. Otherwise, determine the current/most recent sprint from `docs/sprint-history/` or ask the user.

### Step 2: Review Previous Action Items

Read the latest file in `docs/retrospectives/`. For each action item from the previous retro:
- Check if a linked GitHub Issue (label: `retro-action`) has been closed
- Mark as Done / In Progress / Not Started
- Present the follow-up summary to the user before proceeding

### Step 3: Gather Sprint Data

Use Org and Project number from `rules/config/github-workflow.md`:

```bash
gh project item-list <PROJECT_NUMBER> --owner <ORG_NAME> --format json --limit 200
```

Calculate:
- Planned SP vs Completed SP (completion rate)
- Velocity comparison with previous sprint (from `docs/sprint-history/`)
- Items carried over (In Progress or Sprint Backlog at sprint end)
- Open and resolved blockers from `docs/sprint-history/sprint-{N}.json` (`blockers` array)
- DoD compliance rate: (items fully meeting DoD) / (items marked Done) × 100. If below `{{DOD_COMPLIANCE_THRESHOLD}}` from `rules/config/dod-dor-config.md`, add a mandatory "Problem" KPT item

### Step 4: Select Retrospective Format

Ask the user to choose a format (default: KPT):

| Format | Best For |
|--------|----------|
| **KPT** (Keep / Problem / Try) | General-purpose, most familiar |
| **Start-Stop-Continue** | When the team needs clear behavioral changes |
| **4Ls** (Liked / Learned / Lacked / Longed For) | When focusing on team sentiment |

### Step 5: Facilitate Discussion

Present the sprint data summary, then guide the user through each section of the chosen format. Ask open-ended questions:
- KPT: "What went well?", "What caused friction?", "What should we try next?"
- For each input, categorize and summarize

### Step 6: Define Action Items

For each "Try" / "Start" / improvement item:
- Define a concrete action with an owner
- Ask if it should be created as a GitHub Issue with label `retro-action`
- Confirm with user before creating issues

### Step 7: Save

Save to `docs/retrospectives/{YYYY-MM-DD}-sprint{N}.md` and display to the user.

## Output Format

Save as `docs/retrospectives/{YYYY-MM-DD}-sprint{N}.md` with this structure:

```markdown
---
sprint: N
date: YYYY-MM-DD
format: KPT | Start-Stop-Continue | 4Ls
participants:
  - member1
  - member2
---

## Previous Action Items

| Action | Owner | Status |
|--------|-------|--------|
| ... | @github | Done / In Progress / Not Started |

## Sprint Data

| Metric | Value |
|--------|-------|
| Planned SP | X |
| Completed SP | X |
| Completion Rate | X% |
| Velocity (pt/person/day) | X.X |
| Velocity Change | +X% vs previous sprint |
| Carried Over Items | N |
| Blockers (opened / resolved) | N / N |
| DoD Compliance Rate | X% (threshold: {{DOD_COMPLIANCE_THRESHOLD}}) |

## Keep / Problem / Try

### Keep

- (What went well and should continue)

### Problem

- (What caused friction or issues)

### Try

- (Concrete improvements for next sprint)

## Action Items

| # | Action | Owner | Due | GitHub Issue |
|---|--------|-------|-----|-------------|
| 1 | ... | @github | Sprint N+1 | #123 |
```

Adapt section headers to match the chosen format (e.g., Start / Stop / Continue).
