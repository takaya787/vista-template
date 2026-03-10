---
paths: "**/*"
---

# Impediment Config

Project-specific escalation contacts and SLA targets for blocker management.
For classification rules and tracking format, see `rules/convention/impediment-management.md`.

## SLA Targets

| Level | Max Age Before Escalation |
|-------|---------------------------|
| L1 `[BLOCKER]` | `{{L1_SLA_DAYS}}` business days (e.g., 1) |
| L2 `[BLOCKER-TEAM]` | `{{L2_SLA_DAYS}}` business days (e.g., 0 — same day) |
| L3 `[BLOCKER-ESCALATE]` | Immediate |
| Unresolved L3 hard stop | `{{ESCALATION_SLA_DAYS}}` business days (e.g., 3) |

## PR Review Threshold

| Key | Value |
|-----|-------|
| Flag as blocker if PR open for | `{{PR_REVIEW_THRESHOLD_DAYS}}` business days (e.g., 2) |

## Escalation Contacts

| Scope | Contact | Channel |
|-------|---------|---------|
| Team-internal (L1/L2) | `{{SM_GITHUB}}` | `{{TEAM_CHANNEL}}` |
| External dependency (L3) | `{{ESCALATION_CONTACT}}` | `{{ESCALATION_CHANNEL}}` |
| Org-level decision (L3) | `{{EXEC_CONTACT}}` | `{{EXEC_CHANNEL}}` |

## GitHub Labels

| Label | Usage |
|-------|-------|
| `blocker` | Applied to any GitHub Issue that is or creates a blocker |
| `retro-action` | Applied to retrospective action items (tracked by `/retrospective`) |

Ensure these labels exist in `{{ORG_NAME}}/{{ISSUE_REPO}}` before the first sprint.
