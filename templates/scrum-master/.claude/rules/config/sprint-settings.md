---
paths: "**/*"
---

# Sprint Settings

Project-specific sprint configuration. Customize these values per project.
For calculation rules and standards, see `rules/convention/sprint-config.md`.

## Schedule

| Key | Value |
|-----|-------|
| **Duration** | 1 week |
| **Start day** | Monday |
| **End day** | Friday |

- Calculate period from `sprint.startDate` + duration

## Sprint History Storage

| Key | Value |
|-----|-------|
| **Location** | `docs/sprint-history/sprint-{N}.json` |
