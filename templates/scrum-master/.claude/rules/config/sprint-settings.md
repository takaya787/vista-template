---
paths: "**/*"
---

# Sprint Settings

Project-specific sprint configuration. Customize these values per project.
For calculation rules and standards, see `rules/convention/sprint-config.md`.

## Schedule

| Key | Value |
|-----|-------|
| **Duration** | `{{SPRINT_DURATION}}` (e.g., 1 week, 2 weeks) |
| **Start day** | `{{SPRINT_START_DAY}}` (e.g., Monday) |
| **End day** | `{{SPRINT_END_DAY}}` (e.g., Friday) |

- Calculate period from `sprint.startDate` + duration

## Sprint History Storage

| Key | Value |
|-----|-------|
| **Location** | `docs/sprint-history/sprint-{N}.json` |

## Team Capacity

Default available capacity per sprint. Override per sprint if team members are on leave.

| Member (GitHub) | SP/day | Days/Sprint | Sprint Capacity (SP) |
|-----------------|--------|-------------|----------------------|
| `{{MEMBER_1_GITHUB}}` | `{{MEMBER_1_SP_PER_DAY}}` | `{{SPRINT_BUSINESS_DAYS}}` | — |
| `{{MEMBER_2_GITHUB}}` | `{{MEMBER_2_SP_PER_DAY}}` | `{{SPRINT_BUSINESS_DAYS}}` | — |

- **SP/day** = individual sustainable velocity from sprint history; initialize from 3-sprint average once data is available
- Sprint Capacity (SP) is calculated at `/planning` time using actual available days (accounts for holidays and leave)
- To record a one-off adjustment, add a note to the relevant `docs/sprint-history/sprint-{N}.json` under `"capacityNotes"`
