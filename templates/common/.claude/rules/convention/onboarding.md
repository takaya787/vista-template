---
paths: "**/*"
---

# Onboarding

## First-Run Detection

At the start of each session, check `.vista/state/onboarding.json`:

- If file does not exist AND `.vista/` directory does not exist: do not suggest onboarding (setup.sh has not been run)
- If file does not exist AND `.vista/` directory exists: suggest completing onboarding via the app
- If `status` is `"pending"`: prompt the user to finish the onboarding flow in the app
- If `status` is `"active"`: environment is configured — do not suggest onboarding unless the owner asks

At the start of each session, also check `.vista/profile/project.json`:

- If file does not exist or `isOnboardingCompleted` is `false` / missing: suggest opening the Electron app to set up this project
- `project.md` is auto-generated from `project.json` — **never hand-edit `project.md`**

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
