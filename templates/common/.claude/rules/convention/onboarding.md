---
paths: "**/*"
---

# Owner Profile & Onboarding

## Owner Profile

### Storage Architecture

Owner profile data is stored **globally** at `~/.vista/profile/me.json` and shared across all projects via symlink.

```
~/.vista/profile/me.json          ← canonical location (written by onboarding app)
<project>/.vista/profile/me.json  → symlink to ~/.vista/profile/me.json
```

**Rationale:** Onboarding is filled out once per user, not per project. A symlink ensures every project automatically reflects the latest profile without re-running onboarding.

### Schema

The full schema covers identity, communication preferences, role, work patterns, meetings, tools, documentation, and goals. See `.vista/profile/me.example.json` for a complete example.

Minimum required fields after onboarding:

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

All other fields (role, work, meetings, services, documentation, goals) are populated during the app-based onboarding flow.

### Usage

- When owner information is needed, read `.vista/profile/me.json` (resolves to global via symlink)
- If `.vista/profile/me.json` does not exist or contains only skeleton data (no `name`), suggest completing the onboarding in the app
- Never write to `~/.vista/profile/me.json` directly in Claude — always write via the symlink path `.vista/profile/me.json`

### Applying Profile to CLAUDE.md

After onboarding is complete (`status: "active"`), Claude applies the profile to the project's `CLAUDE.md`:

1. Read `.vista/profile/me.json`
2. If `CLAUDE.md` does not yet have an `## Owner` section, append one using the profile values
3. If `CLAUDE.md` already has an `## Owner` section, do not overwrite — prompt the owner to review instead
4. The injected section should contain only fields relevant to daily interaction (name, language, output format, tone, autonomy, neverDo, alwaysFollow) — not raw JSON

### Deferred Configuration

When a skill or task requires a field not yet in `me.json`:

1. Check if the field exists in `.vista/profile/me.json`
2. If missing, collect it at that moment (just-in-time) via `AskUserQuestion`
3. Write the new field to `me.json` immediately (writes persist globally via symlink)
4. Do not pre-collect fields "in case they are needed later"

### Reference Priority

1. `.vista/profile/me.json` — primary source for owner identity and per-user settings
2. `docs/members/{github}.md` — supplementary profile data (optional; do not error if missing)
3. `docs/team.md` — team roster (optional; do not error if missing)

## First-Run Detection

At the start of each session, check `.vista/state/onboarding.json`:

- If file does not exist AND `.vista/` directory does not exist: do not suggest onboarding (setup.sh has not been run)
- If file does not exist AND `.vista/` directory exists: suggest completing onboarding via the app
- If `status` is `"pending"`: onboarding was started but not completed — prompt the user to finish the onboarding flow in the app
  - Example: "I notice your profile hasn't been set up yet. Please complete the onboarding in the app to get started."
- If `status` is `"active"`: environment is configured — do not suggest onboarding unless the owner asks

> **Note:** Onboarding input is collected via the Electron app UI, not through `AskUserQuestion`. The app renders all questions from `references/interview-protocol.json` and writes the result directly to `.vista/profile/me.json`.

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
