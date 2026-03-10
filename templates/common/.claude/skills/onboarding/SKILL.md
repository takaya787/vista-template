---
name: onboarding
description: Interactive onboarding that personalizes Claude Code configuration.
  Triggers automatically when .vista/state/onboarding.json has status "pending".
  Also triggers on "/onboarding", "run onboarding", "set up my profile",
  "configure my preferences". Can be re-run anytime.
---

# Onboarding

Interactive, conversational onboarding that personalizes the Claude Code environment for the project owner. Collects profile information, working style preferences, and role-specific settings through a friendly interview.

## Why This Skill Is Needed

After `setup.sh` copies template files, the environment still lacks personalization — the owner's name, preferences, and role-specific settings are unconfigured. This skill bridges the gap by conducting a conversational interview that populates `.vista/profile/me.json`, seeds `memory/MEMORY.md`, and fills in remaining config placeholders.

## Data Sources

- `.vista/state/onboarding.json` — Current onboarding status
- `.vista/state/setup.json` — Role and setup metadata
- `.vista/profile/me.json` — Owner profile (skeleton or partially filled)
- `rules/config/` — Config files with placeholders to fill
- `references/interview-protocol.md` — Role-specific question bank

## Steps

### Step 1: Detect State

1. Read `.vista/state/onboarding.json` to determine current status
2. Read `.vista/profile/me.json` to identify already-filled vs empty fields
3. Read `.vista/state/setup.json` to determine the active role
4. Identify which fields are missing or still contain placeholder values
5. If `status` is `"complete"` and user explicitly triggered re-run, proceed with all questions (pre-filling known answers)

### Step 2: Welcome

Greet the owner and set expectations:

- Explain this is a one-time personalization (~3-5 minutes)
- Mention that any question can be skipped (defaults will apply)
- If re-running, acknowledge existing settings and offer to update them

Example:
> Welcome! I'll ask a few questions to personalize your Claude Code setup. This takes about 3-5 minutes — you can skip any question by saying "skip".

### Step 3: Core Profile Interview

Collect the owner's basic profile. Ask questions conversationally, one at a time. Do NOT present all questions at once.

For each field in `.vista/profile/me.json` that is empty or contains a placeholder:

1. **Name** — "What should I call you?"
2. **Position / Title** — "What's your role or title?"
3. **Team** — "Which team are you on?"
4. **Email** — "What's your work email?" (skip if not needed)
5. **Slack ID** — "What's your Slack member ID?" (explain how to find it if asked)

For technical roles (engineer, designer), also ask:
6. **Tech Stack** — "What are your primary technologies?"
7. **Focus Areas** — "What are you currently focused on?"

Refer to `references/interview-protocol.md` for the full question bank and skip defaults.

### Step 4: Working Style Interview

Collect working preferences:

1. **Communication style** — "How do you prefer to communicate? (e.g., async Slack, real-time huddles)"
2. **Working hours** — "What are your typical working hours?"
3. **Timezone** — Auto-detect from system if possible, confirm with user
4. **Output language** — "Which language should I use for reports and communication? (default: Japanese)"
5. **Output format** — "Do you prefer concise bullet points or detailed prose?"

### Step 5: Role-Specific Configuration

Based on the role from `.vista/state/setup.json`, ask role-specific questions. Refer to `references/interview-protocol.md` for the complete question bank.

**scrum-master:**
- Sprint frequency and duration
- Notion page URLs (if not already configured)
- Reporting preferences

**marketing:**
- Active advertising channels
- Analytics tools in use
- Report sharing preference (Notion / Google Sheets / Markdown)

**engineer:**
- Code review style preferences
- Documentation conventions
- Preferred development workflow

Also check `rules/config/` files for remaining `{{PLACEHOLDER}}` values and ask the user to provide them.

### Step 6: Integration Check

Verify external service connections based on role:

1. Run `gh auth status` to check GitHub CLI authentication
2. For roles using Notion: check if Notion access is configured
3. Report status to user and suggest fixes for any missing integrations

### Step 7: Apply Configuration

1. Update `.vista/profile/me.json` with all collected answers
2. Update any `rules/config/` files where placeholders were filled
3. Seed `memory/MEMORY.md` with initial preferences:
   - Owner communication preferences
   - Output format preferences
   - Any notable working style information

### Step 8: Finalize

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
