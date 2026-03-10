---
name: sprint-goal
description: Generate per-assignee Sprint Goals from GitHub Project. Outputs concise markdown for pasting into Notion. Use when the user says "/sprint-goal", "create sprint goals", "summarize this sprint's goals", or "generate goals for Notion". Accepts a sprint number as an argument.
---

# Sprint Goal Generator

Fetches tasks for a specified Sprint from GitHub Project and generates Sprint Goals summarized by theme per assignee.

## Why This Skill Is Needed

Sprint Goals are pasted into the Notion standup page and shared with the whole team. Rather than listing tasks, the important thing is to convey "who is working on what" at a thematic level. This skill automatically generates that summary from GitHub Project data.

## Data Sources

- **GitHub Project** — Refer to `rules/config/github-workflow.md` for Org and Project number
- **Team composition** — Refer to `docs/team.md` (managers are excluded from task display)

## Steps

### Step 1: Confirm Sprint Number

Use the sprint number if provided as an argument. Otherwise, ask the user.

### Step 2: Fetch GitHub Project Data

Use Org and Project number from `rules/config/github-workflow.md`:

```bash
gh project item-list <PROJECT_NUMBER> --owner <ORG_NAME> --format json --limit 200
```

Filter items where `sprint.title` matches `Sprint {N}`.

### Step 3: Aggregate Data

Aggregate sprint period and tasks grouped by assignee.

### Step 4: Generate Sprint Goals

Summarize each assignee's tasks by theme. Write in the completion form matching the `output-language.md` language setting.

### Step 5: Output

Output markdown in a format ready to paste into Notion.

## Output Format

```markdown
## Sprint {N} Goals ({start_date} - {end_date})

### {Assignee Name} (@github)

- **Theme 1**: (1-sentence summary of related tasks)
- **Theme 2**: (1-sentence summary of related tasks)
- **Theme 3**: (if applicable)

### {Assignee Name} (@github)

- **Theme 1**: ...
```

Rules:
- Group each assignee's tasks into 2-3 themes (do not list individual issues)
- Write in the completion form matching `output-language.md` (e.g., "〜を完了する" in Japanese)
- Exclude managers from task display (per `docs/team.md` roles)
- Highlight the owner's section first
