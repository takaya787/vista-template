---
name: automate
description: Drives the full PRD → implementation → LaunchAgent registration → verification loop. Use when the user says "/automate", "automate this", "implement this PRD", or "run the automation loop". Also use to resume a previously started automation by slug.
argument-hint: "<prd_path or slug> (omit to start from PRD creation)"
---

# Automate — Full Automation Loop

Orchestrates the complete lifecycle of a macOS automation: PRD → tasks → implementation → LaunchAgent registration → verification.

All state is persisted in a **manifest file** so the loop can be paused and resumed at any phase.

## Entry Point

1. If an argument is provided:
   - If it looks like a file path ending in `.md`, treat it as `prd_path` and start from Phase 2
   - If it looks like a slug (e.g. `slack-weekly-report`), load `.taskmaster/automations/{slug}/manifest.json` and resume from `manifest.phase`
2. If no argument is provided, start from Phase 1

## Manifest Location

```
.taskmaster/automations/{slug}/manifest.json
```

Create `.taskmaster/automations/{slug}/` if it does not exist.

Update `manifest.phase` at the **end of each phase** before proceeding to the next.

See `references/phases.md` for the manifest schema and each phase's detailed steps.

## Loop

Execute phases in order. After each phase completes, update the manifest and confirm with the user before proceeding to the next phase.

| Phase | Name | Entry condition |
|-------|------|-----------------|
| 1 | PRD Creation | No manifest exists |
| 2 | Task Generation | `manifest.phase == "prd_created"` |
| 3 | Implementation | `manifest.phase == "tasks_generated"` |
| 4 | LaunchAgent Registration | `manifest.phase == "implemented"` |
| 5 | Verification | `manifest.phase == "registered"` |
| 6 | Completion | `manifest.phase == "verified"` |

## Resuming

If the user calls `/automate {slug}` and a manifest already exists, read `manifest.phase` and skip completed phases. Announce which phase you are resuming from.
