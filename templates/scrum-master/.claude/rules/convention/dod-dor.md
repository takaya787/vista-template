---
paths: "**/*"
---

# Definition of Done and Definition of Ready

Defines how DoD and DoR are applied during sprint ceremonies.
Project-specific checklists live in `rules/config/dod-dor-config.md`.

## When to Apply DoD

Apply DoD verification when:

- Moving an issue from **In Progress** to **In Review** — check DoD before tagging for review
- Moving an issue from **In Review** to **Done** — confirm DoD is fully met
- Generating the `/planning` dashboard — flag any "Done" items with unmet DoD criteria

If a "Done" item has unmet DoD criteria, reclassify it as **In Review** and note it in the TL;DR section as:
`[DOD-INCOMPLETE] Issue #{N}: missing {criterion}`

## When to Apply DoR

Apply DoR verification when:

- Adding a backlog item to **Sprint Backlog** during `/planning`
- Creating a new GitHub Issue with acceptance criteria

If a Sprint Backlog item fails DoR, label it `not-ready` and exclude it from sprint capacity calculations. Surface it as:
`[DOR-INCOMPLETE] Issue #{N}: missing {criterion} — not counted in sprint capacity`

## Authority

DoD and DoR checklists are defined by the team and stored in `rules/config/dod-dor-config.md`. They can be updated by the SM with team agreement. The **Convention** (this file) defines when and how to apply them — it does not define the checklist content itself.

## Retrospective Integration

At the start of each retrospective (Step 2), review DoD/DoR compliance for the just-completed sprint:

- Count issues that moved to Done with a `[DOD-INCOMPLETE]` flag still open
- If compliance rate drops below `{{DOD_COMPLIANCE_THRESHOLD}}` (defined in `rules/config/dod-dor-config.md`), add a mandatory "Problem" item to the KPT: "DoD compliance was below threshold this sprint"
