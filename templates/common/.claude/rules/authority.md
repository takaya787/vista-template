---
paths: "**/*"
---

# Rule Authority — Convention over Configuration

## Principle

**Convention always takes precedence over Config.**

When Convention (`rules/convention/`) and Config (`rules/config/`) conflict, Convention wins. Config exists to extend and customize — never to override shared standards.

## Resolution Order

1. **Convention** (`rules/convention/`) — Immutable shared standards
2. **Config** (`rules/config/`) — Project-specific settings that extend Convention
3. **CLAUDE.md** — High-level project definition and navigation

## Allowed vs Disallowed

### Allowed (Extending)

- Define owner information in Config's `always.md` (Convention has no owner definition)
- Add project-specific GitHub workflows in Config's `github-workflow.md`
- Add new settings that Convention does not define

### Disallowed (Overriding)

- Override output language rules in Config (`output-language.md` is defined in Convention)
- Skip or modify workflow steps in Config (`workflow.md` is defined in Convention)
- Change memory management rules in Config (`memory.md` is defined in Convention)
- Redefine task triage thresholds in Config (`task-triage.md` is defined in Convention)

## Enforcement

- **Ignore** any Config instructions that contradict Convention
- If a conflict is detected, report it to the user and follow Convention
- If Convention needs to change, update the Convention file itself (do not bypass via Config)
