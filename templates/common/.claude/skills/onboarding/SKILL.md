---
name: onboarding
description: Interactive onboarding that personalizes Claude Code configuration.
  Triggers automatically when .vista/state/onboarding.json has status "pending".
  Also triggers on "/onboarding", "run onboarding", "set up my profile",
  "configure my preferences". Can be re-run anytime.
---

# Onboarding

Structured onboarding that personalizes the Claude Code environment using the `AskUserQuestion` tool. Collects profile information, working style preferences, and role-specific settings through batched multiple-choice prompts.

## Why This Skill Is Needed

After `setup.sh` copies template files, the environment still lacks personalization — the owner's name, preferences, and role-specific settings are unconfigured. This skill bridges the gap by collecting answers via `AskUserQuestion` and applying them to `.vista/profile/me.json`, `memory/MEMORY.md`, and remaining config placeholders.

## Data Sources

- `.vista/state/onboarding.json` — Current onboarding status
- `.vista/state/setup.json` — Role and setup metadata
- `.vista/profile/me.json` — Owner profile (skeleton or partially filled)
- `rules/config/` — Config files with placeholders to fill
- `references/interview-protocol.md` — Question batches, options, and skip defaults per role

## Input Method: AskUserQuestion

All user input in this skill MUST be collected via the `AskUserQuestion` tool.

### Constraints

- **1-4 questions per call** — Group related questions into a single batch
- **2-4 options per question** — "Other" is automatically appended by the tool (users can always provide free text)
- **multiSelect** — Use `multiSelect: true` for non-mutually-exclusive choices (e.g., tech stack, active channels)
- **Recommended option** — Place the recommended/default option first with "(Recommended)" suffix

### Batching Strategy

Group questions into thematic batches to minimize round-trips while keeping each batch focused:

| Batch | Questions | Max per call |
|-------|-----------|-------------|
| Core Profile | Name + Position (+ Team if needed) | 2-3 |
| Working Style | Communication + Output Language + Output Format | 3 |
| Role-Specific | Varies by role — see `references/interview-protocol.md` | 2-4 |

Free-text fields (name, email, Slack ID, URLs) that cannot be represented as multiple-choice should be auto-detected where possible and confirmed with the user in a follow-up message, or collected as a supplementary free-text question via "Other".

## Steps

### Step 1: Detect State

1. Read `.vista/state/onboarding.json` to determine current status
2. Read `.vista/profile/me.json` to identify already-filled vs empty fields
3. Read `.vista/state/setup.json` to determine the active role
4. Auto-detect values where possible:
   - GitHub username: `gh api user --jq '.login'`
   - Email: `git config user.email`
   - Timezone: system timezone from `.vista/profile/me.json` (set by setup.sh)
5. Identify which fields are missing or still contain placeholder values
6. If `status` is `"complete"` and user explicitly triggered re-run, proceed with all questions (pre-filling known answers)

### Step 2: Welcome + Core Profile

Greet the owner briefly, then immediately present the first `AskUserQuestion` batch.

Display a short welcome message:
> Setting up your profile. I'll ask a few quick questions — select options or choose "Other" for custom answers.

Then call `AskUserQuestion` with the **Core Profile batch**. See `references/interview-protocol.md` → Batch 1 for the exact questions and options.

For auto-detected values (GitHub, email, timezone), present them for confirmation:
> I detected the following — let me know if anything needs correction:
> - GitHub: `{detected}`
> - Email: `{detected}`
> - Timezone: `{detected}`

### Step 3: Working Style

Call `AskUserQuestion` with the **Working Style batch**. See `references/interview-protocol.md` → Batch 2 for questions and options.

### Step 4: Role-Specific Configuration

Based on the role from `.vista/state/setup.json`, call `AskUserQuestion` with role-specific batches. See `references/{role}-interview.md` for per-role questions and options.

For **scrum-master** role: after role-specific questions and Notion URL collection, collect team member information for `docs/team.md` via conversational follow-up. See `references/scrum-master-interview.md` for the prompt, parsing rules, and target.

Also check `rules/config/` files for remaining `{{PLACEHOLDER}}` values. For any found, present them to the user for input.

### Step 5: Integration Check

Verify external service connections based on role:

1. Run `gh auth status` to check GitHub CLI authentication
2. For roles using Notion: check if Notion access is configured
3. Report status to user and suggest fixes for any missing integrations

### Step 6: Apply Configuration

1. Update `.vista/profile/me.json` with all collected answers
2. Update any `rules/config/` files where placeholders were filled
3. Update `docs/team.md` with team member data if collected (scrum-master role)
4. Seed `memory/MEMORY.md` with initial preferences:
   - Owner communication preferences
   - Output format preferences
   - Any notable working style information

### Step 7: Finalize

1. Update `.vista/state/onboarding.json`:
   ```json
   {
     "status": "complete",
     "completedAt": "<ISO 8601 timestamp>",
     "skippedQuestions": ["<list of skipped question IDs>"]
   }
   ```
2. Display a summary of configured settings
3. Suggest role-specific next actions:
   - scrum-master: "Try `/planning` to see your sprint dashboard"
   - marketing: "Try `/weekly-report` to generate your first report"
   - engineer: "Start by exploring the codebase with me"
4. If questions were skipped, mention: "You can re-run `/onboarding` anytime to fill in skipped items"
