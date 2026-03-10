---
paths: "**/*"
---

# DoD / DoR Config

Project-specific Definition of Done and Definition of Ready checklists.
For when and how to apply them, see `rules/convention/dod-dor.md`.

## Definition of Done (DoD)

An issue may be marked **Done** only when all applicable items are checked:

- [ ] `{{DOD_ITEM_1}}` (e.g., All acceptance criteria in the issue are met)
- [ ] `{{DOD_ITEM_2}}` (e.g., Code reviewed and approved by at least 1 reviewer)
- [ ] `{{DOD_ITEM_3}}` (e.g., Tests written and passing in CI)
- [ ] `{{DOD_ITEM_4}}` (e.g., No new `[CRITICAL]` or `[MAJOR]` findings unresolved)
- [ ] `{{DOD_ITEM_5}}` (e.g., Deployed to staging / feature-flagged)

Remove or replace items that do not apply to this project.

## Definition of Ready (DoR)

An issue may enter **Sprint Backlog** only when all applicable items are checked:

- [ ] `{{DOR_ITEM_1}}` (e.g., Acceptance criteria written and agreed with owner)
- [ ] `{{DOR_ITEM_2}}` (e.g., Story points estimated)
- [ ] `{{DOR_ITEM_3}}` (e.g., Dependencies identified and either resolved or tracked as risks)
- [ ] `{{DOR_ITEM_4}}` (e.g., No open questions that would block implementation)

## Compliance Threshold

| Key | Value |
|-----|-------|
| DoD compliance warning threshold | `{{DOD_COMPLIANCE_THRESHOLD}}` (e.g., 80%) |

If the percentage of sprint items that met full DoD before being marked Done falls below this threshold, the retrospective must include a mandatory "Problem" item (see `rules/convention/dod-dor.md`).
