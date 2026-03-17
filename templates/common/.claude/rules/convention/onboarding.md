---
paths: "**/*"
---

# Owner Profile & Onboarding

## Owner Profile (.vista/profile/me.json)

`.vista/profile/me.json` is the owner's personal profile, populated during onboarding.

### Schema (Required Fields)

```json
{
  "name": "string (required)",
  "email": "string (required)",
  "preferences": {
    "language": "ja | en | bilingual (required)",
    "outputFormat": "bullets | prose | tables | mixed (required)"
  },
  "workingStyle": {
    "timezone": "string (required, auto-detected)"
  }
}
```

Additional fields are added just-in-time during task execution — not collected upfront.

### Usage

- When owner information is needed, read `.vista/profile/me.json`
- If `.vista/profile/me.json` does not exist or contains only skeleton data, suggest running `/onboarding`

### Deferred Configuration

When a skill or task requires a field not yet in `me.json`:

1. Check if the field exists in `.vista/profile/me.json`
2. If missing, collect it at that moment (just-in-time) via `AskUserQuestion`
3. Write the new field to `me.json` immediately
4. Do not pre-collect fields "in case they are needed later"

### Reference Priority

1. `.vista/profile/me.json` — primary source for owner identity and per-user settings
2. `docs/members/{github}.md` — supplementary profile data (optional; do not error if missing)
3. `docs/team.md` — team roster (optional; do not error if missing)

## First-Run Detection

At the start of each session, check `.vista/state/onboarding.json`:

- If file does not exist AND `.vista/` directory does not exist: do not suggest onboarding (setup.sh has not been run)
- If file does not exist AND `.vista/` directory exists: suggest: "It looks like we haven't finished setting things up yet. Want to run `/onboarding` to get started?"
- If `status` is `"pending"`: suggest running `/onboarding`
  - Example: "I notice your profile hasn't been set up yet. Would you like to run `/onboarding`? I'll ask a few quick questions and then we can jump into a real task together."
- If `status` is `"active"`: environment is configured — do not suggest onboarding unless the owner asks

## Pending Task Suggestions

When `status` is `"active"` and `pendingTasks` is non-empty:

- Suggest at most **once per session**: "Last time we identified some tasks you wanted help with: [list]. Want to pick one up?"
- Do not repeat if the owner declines or changes topic

## Re-run Policy

When the owner explicitly triggers `/onboarding` on an already-active environment:

1. Show current maturity level (using plain-language labels) and completed task count from `onboarding.json`
2. Skip profile questions (name, language, format) — these are already set
3. Go directly to task discovery, prioritizing `pendingTasks` from previous sessions
4. Allow the owner to update profile fields if they explicitly request it. Show current values and ask which field to change. Collect the new value conversationally (free-text) and update `me.json` immediately.

## .vista/ Directory Convention

The `.vista/` directory holds Vista-specific metadata and configuration:

| Subdirectory | Purpose | Git tracked |
|-------------|---------|-------------|
| `.vista/state/` | Session state (onboarding status, setup metadata) | No (gitignored) |
| `.vista/profile/` | Owner personal data | No (gitignored) |
| `.vista/config/` | Vista-specific config files | Yes (templates only) |

- Never commit files in `.vista/state/` or `.vista/profile/` to version control
- `.vista/config/` may contain tracked template files (e.g., `.example` files)
