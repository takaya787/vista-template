# Sprint Configuration

Centralizes all sprint-related definitions. All skills should reference this rule.

## Sprint Duration

- Default: **1 week** (Monday start – Friday end)
- Calculate period from `sprint.startDate` + duration

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

## Point Notation

- Tasks without SP assigned are displayed as **`-pt`**

## Next Sprint Candidate Priority

1. **Tasks with deadlines**: Closer deadlines get highest priority
2. **EPIC-related tasks**: Higher priority when the category's total remaining SP is larger
   - Larger remaining SP in a category = greater impact on the overall project
   - For tasks linked to an EPIC, also consider the number of remaining tasks in that EPIC
3. **Standalone tasks (not part of an EPIC)**: Higher point value = higher priority

## Sprint History Storage

When a skill aggregates sprint data, save the results in the following format:

### Location
`docs/sprint-history/sprint-{N}.json`

### Format
```json
{
  "sprint": "Sprint 28",
  "startDate": "2026-02-24",
  "endDate": "2026-02-28",
  "team": ["member1", "member2"],
  "businessDays": 5,
  "points": {
    "done": 10,
    "inReview": 2,
    "inProgress": 3,
    "backlog": 0
  },
  "velocity": 2.4
}
```

### Usage
- Used by `/planning` for velocity calculation
- Used by `/weekly-update` for comparison with previous report
- Estimate velocity using a 3-sprint moving average
