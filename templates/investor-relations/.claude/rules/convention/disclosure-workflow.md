---
paths: "**/*"
---

# Disclosure Workflow Convention

Defines immutable rules governing disclosure-related document generation. Project-specific dates and settings belong in `rules/config/ir-calendar.md`.

## Quiet Period Rule

During quiet periods (defined in `rules/config/ir-calendar.md`):

- Do NOT draft any external investor communication
- Flag all external draft requests with `[QUIET PERIOD]` and pause for user confirmation
- Internal analysis and preparation documents are permitted but must be tagged `[INTERNAL]`

## External Document Gate

Before generating any document tagged `[DRAFT]` or destined for external audiences:

1. Check `rules/config/ir-calendar.md` for quiet period status
2. Confirm with user: "This document may contain material information. Confirm it is appropriate to draft at this time?"
3. Save external-facing documents to `docs/external/` (separate from internal `docs/reports/`)

## AI Draft Disclaimer

All disclosure-related drafts MUST include this disclaimer at the top:

```
> This document is an AI-generated draft. All financial figures, legal compliance,
> and disclosure rule adherence must be verified by the IR team against primary sources
> before any external use.
```

## Pre-Disclosure Checklist

Append this checklist to every `[DRAFT]`-tagged document:

```markdown
## Pre-Disclosure Checklist

- [ ] All figures verified against source CSV files
- [ ] Period-over-period calculations manually cross-checked
- [ ] Accounting standard consistency confirmed across all periods
- [ ] No contradiction with prior disclosures or securities filings
- [ ] Disclosure format requirements met (TDnet/EDINET as applicable)
- [ ] Legal/CFO/auditor review completed
- [ ] Quiet period compliance confirmed (see ir-calendar.md)
```

## Document Lifecycle

| Stage | Tag | Location | Human Review Required |
|-------|-----|----------|----------------------|
| Working draft | `[INTERNAL]` | `docs/reports/` | No |
| Disclosure draft | `[DRAFT]` | `docs/external/` | Yes (mandatory) |
| Post-disclosure reference | `[DISCLOSED]` | `data/disclosures/` | N/A (already public) |
