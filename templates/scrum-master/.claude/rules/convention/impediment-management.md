---
paths: "**/*"
---

# Impediment Management

Defines immutable standards for identifying, tracking, and escalating blockers.
For project-specific escalation contacts and SLA targets, see `rules/config/impediment-config.md`.

## Blocker Classification

| Level | Label | Definition | Max Age Before Escalation |
|-------|-------|------------|---------------------------|
| L1 | `[BLOCKER]` | Stops one task; owner can unblock with help from a peer | 1 business day |
| L2 | `[BLOCKER-TEAM]` | Stops multiple tasks or one assignee's entire sprint | Same day |
| L3 | `[BLOCKER-ESCALATE]` | Requires action from outside the team (external dependency, org decision) | Immediate |

## Detection — When to Flag a Blocker

Apply a blocker label when any of the following is true:

- An issue has been **In Progress for 2+ business days** with no status change
- An issue comment contains the words "blocked", "waiting on", "dependency", or "can't proceed"
- A PR has been open for review for longer than the threshold in `rules/config/impediment-config.md`
- A team member explicitly flags it in standup notes

## Tracking Format

When a blocker is detected, add a `blockers` entry to the sprint history JSON:

```json
"blockers": [
  {
    "issue": 123,
    "level": "L2",
    "summary": "Waiting for API contract from platform team",
    "detectedDate": "YYYY-MM-DD",
    "owner": "@github-handle",
    "escalatedTo": null,
    "resolvedDate": null
  }
]
```

## Escalation Steps

1. **L1**: Mention the blocker in the next standup summary. Suggest a specific peer who can help.
2. **L2**: Surface in the `/planning` TL;DR section under "Biggest blocker or risk". Create a GitHub Issue labeled `blocker` if one does not already exist.
3. **L3**: Immediately surface to the SM. Propose adding to the `[BLOCKER-ESCALATE]` section of `rules/config/impediment-config.md` escalation contacts. Create a GitHub Issue labeled `blocker` and link to the blocking external dependency.

## Resolution

- When a blocker is resolved, update `resolvedDate` in the sprint history JSON.
- Carry unresolved L2/L3 blockers forward automatically as the first item in the `/planning` TL;DR of every subsequent sprint until resolved.
- Retrospective Step 3 ("Gather Sprint Data") must include a count of open and resolved blockers for the sprint.

## Stop Condition

If an L3 blocker has been open for more than `{{ESCALATION_SLA_DAYS}}` business days (defined in `rules/config/impediment-config.md`) without a resolution owner, halt sprint planning recommendations and surface:

`[BLOCKER-UNRESOLVED] Issue #{N} has been blocked for {X} days with no escalation owner. Sprint planning cannot proceed reliably until this is addressed.`
