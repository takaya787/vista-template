---
paths: "**/*"
---

# Sprint Convention

Defines immutable sprint-related standards. All skills should reference this rule.
For project-specific settings (duration, schedule, etc.), see `rules/config/sprint-settings.md`.

## Status Mapping

| Project Status | Treatment | Display Order |
|---------------|-----------|---------------|
| Done | Completed | 1 |
| In Review | Treated as completed (same as Done) | 2 |
| In Progress | In progress | 3 |
| Sprint Backlog | Not started | 4 |
| Other (Icebox, etc.) | Next Sprint candidate | 5 |

- **In Review is treated as Done** — items in review are counted as completed

## Velocity Calculation

- **Completed SP**: Total SP of Done + In Review
- **Remaining SP**: Total SP of In Progress + Sprint Backlog (within sprint)
- **Completion rate**: Completed SP / (Completed + Remaining) × 100
- **Velocity**: If past sprint data is available, calculate points consumed per person per business day
- Estimate velocity using a 3-sprint moving average

## Point Notation

- Tasks without SP assigned are displayed as **`-pt`**

## Next Sprint Candidate Priority

1. **Tasks with deadlines**: Closer deadlines get highest priority
2. **EPIC-related tasks**: Higher priority when the category's total remaining SP is larger
   - Larger remaining SP in a category = greater impact on the overall project
   - For tasks linked to an EPIC, also consider the number of remaining tasks in that EPIC
3. **Standalone tasks (not part of an EPIC)**: Higher point value = higher priority

## Sprint History Format

When a skill aggregates sprint data, save the results in the following JSON format:

```json
{
  "sprint": "Sprint N",
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "team": ["member1", "member2"],
  "businessDays": 5,
  "points": {
    "done": 0,
    "inReview": 0,
    "inProgress": 0,
    "backlog": 0
  },
  "velocity": 0.0
}
```

### Usage
- Used by `/planning` for velocity calculation
- Used by `/weekly-update` for comparison with previous report
