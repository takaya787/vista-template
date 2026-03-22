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

## Project Profile

### Storage Architecture

Project profile data is stored **per-project** at `.vista/profile/project.json`. Unlike `me.json`, it is **never symlinked** — each repository maintains its own independent project profile.

```
<project>/.vista/profile/project.json   ← per-project profile (not symlinked)
<project>/.vista/profile/project.md     ← generated context document (auto-generated from project.json)
```

**Rationale:** Project context is unique to each repository. A global symlink would be incorrect — different projects have different tech stacks, phases, and constraints.

### Schema

The full schema covers project identity, business domain, current focus, team structure, and guardrails. See `.vista/profile/project.example.json` for a complete example.

Minimum required fields after project setup:

```json
{
  "isOnboardingCompleted": true,
  "company": {
    "name": "string (required)",
    "industry": "tech | finance | retail_ec | manufacturing | healthcare | consulting | media_ad | real_estate | education | government (required)",
    "description": "string (required)"
  },
  "myWork": {
    "domain": "string (required)",
    "products": "string (required)"
  },
  "currentInitiatives": "string (required)"
}
```

All other fields (myWork.keyMetrics, stakeholders, businessTerms, neverDo, references) are optional and can be added later.

The `references` field is an array of reference materials (URLs or files) the owner wants Claude to be aware of:

```json
"references": [
  { "type": "url", "label": "string", "value": "https://..." },
  { "type": "file", "label": "string", "value": "relative/path/to/file" }
]
```

When `references` is present, Claude should treat listed URLs and files as authoritative context for the project and prioritize them when answering questions or generating documents.

### Usage

- When project context is needed, read `.vista/profile/project.json`
- If `.vista/profile/project.json` does not exist or `isOnboardingCompleted` is `false` or missing, tell the owner to open the Electron app to set up this project
- `project.md` is auto-generated from `project.json` — **never hand-edit `project.md`**; update `project.json` via `/onboarding-project` and regenerate

### First-Run Detection (Project)

At the start of each session, check `.vista/profile/project.json`:

- **File does not exist**: project has not been set up → suggest opening the Electron app
- **`isOnboardingCompleted: false`** or field missing: setup incomplete → suggest opening the Electron app
- **`isOnboardingCompleted: true`**: project is configured → do not suggest setup unless the owner asks

> **Note:** Project onboarding input is collected via the Electron app UI, not through `AskUserQuestion`. The app renders all questions from the onboarding-project skill's `references/project-interview-protocol.json`, writes `project.json` (with `isOnboardingCompleted: true`), then runs `claude -p "/apply-project-profile"` to generate all remaining workspace files.

### project.md Integration

After the app writes `project.json`, it runs `claude -p "/apply-project-profile"` (one-shot, non-interactive), which generates:

1. **`.vista/profile/project.md`** — from project.json
2. **`CLAUDE.md`** — Key References row added:
   ```
   | Project context | `.vista/profile/project.md` (generated via `/onboarding-project`) |
   ```
3. **`rules/config/always.md`** — active read instruction appended:
   ```markdown
   ## Project Context
   Read `.vista/profile/project.md` at the start of each session for business context (company, domain, current initiatives, constraints).
   ```

The `rules/config/always.md` entry is the authoritative load trigger — it follows the same pattern as `convention/always.md` for `me.json`. This mirrors the `apply-profile` pattern used for owner onboarding.

### Generation Rules

See `references/project-generation-guide.md` in the onboarding-project skill for:

- Field mapping (JSON key → project.md section)
- project.md template
- Write sequence and update behavior

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

| Subdirectory      | Purpose                                           | Git tracked          |
| ----------------- | ------------------------------------------------- | -------------------- |
| `.vista/state/`   | Session state (onboarding status, setup metadata) | No (gitignored)      |
| `.vista/profile/` | Owner personal data                               | No (gitignored)      |
| `.vista/config/`  | Vista-specific config files                       | Yes (templates only) |

- Never commit files in `.vista/state/` or `.vista/profile/` to version control
- `.vista/config/` may contain tracked template files (e.g., `.example` files)
