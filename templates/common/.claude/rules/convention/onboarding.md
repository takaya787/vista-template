---
paths: "**/*"
---

# Owner Profile & Onboarding

## Owner Profile (.vista/profile/me.json)

`.vista/profile/me.json` is the owner's personal profile, populated during onboarding.

### Usage

- When owner information is needed, read `.vista/profile/me.json`
- If `.vista/profile/me.json` does not exist or contains only skeleton data, suggest running `/onboarding`

### Continuous Updates

`.vista/profile/me.json` is a living document. When new services or integrations are added to the project (per `rules/convention/integrations.md`), add the owner's account or configuration fields to `.vista/profile/me.json`.

- Before adding a field, confirm with the user: "May I add `fieldName` to `.vista/profile/me.json`?"
- Keep the JSON flat where possible; use nested objects only for grouped settings (e.g., `workingStyle`, `preferences`)
- Trigger: whenever a new service is registered in `integrations.md` and it requires per-user account info (ID, username, token reference, etc.)

### Reference Priority

1. `.vista/profile/me.json` — primary source for owner identity and per-user settings
2. `docs/members/{github}.md` — supplementary profile data
3. `docs/team.md` — team roster

## First-Run Detection

At the start of each session, check `.vista/state/onboarding.json`:

- If `status` is `"pending"`: suggest running the `/onboarding` skill to personalize the environment
  - Example: "I notice your profile hasn't been set up yet. Would you like to run `/onboarding` to personalize your Claude Code experience? (~3-5 minutes)"
- If the file does not exist: do not suggest onboarding (setup.sh has not been run)

## Progressive Follow-up

When `status` is `"complete"` and `skippedQuestions` is non-empty:

- After 3-5 sessions, consider gently suggesting that skipped items can be filled in
- Do not suggest more than once per session
- Example: "By the way, you skipped a few onboarding questions last time. Want to fill them in? Just say `/onboarding`"

## Re-run Policy

Users can re-run `/onboarding` at any time. When re-running:

- Pre-fill already-known answers and ask for confirmation
- Only prompt for empty or placeholder fields by default
- Allow the user to update any previously set field if they choose

## .vista/ Directory Convention

The `.vista/` directory holds Vista-specific metadata and configuration:

| Subdirectory | Purpose | Git tracked |
|-------------|---------|-------------|
| `.vista/state/` | Session state (onboarding status, setup metadata) | No (gitignored) |
| `.vista/profile/` | Owner personal data | No (gitignored) |
| `.vista/config/` | Vista-specific config files | Yes (templates only) |

- Never commit files in `.vista/state/` or `.vista/profile/` to version control
- `.vista/config/` may contain tracked template files (e.g., `.example` files)
