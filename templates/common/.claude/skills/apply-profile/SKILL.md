---
name: apply-profile
description: Apply the completed interview profile to CLAUDE.md and .claude/agents/*.md in one shot.
  Triggers on "/apply-profile", "apply my profile", "configure my workspace", "ワークスペースの初期設定", "プロフィールを反映して", "設定を適用して".
  Also trigger when the user says the onboarding interview is done and wants the workspace configured
  (e.g. "オンボーディング完了したのでCLAUDE.mdとエージェントを作って", "the interview is done, please set up my workspace",
  "me.json is ready — generate the agents", "isOnboardingCompleted is true now, configure everything").
  Run automatically after the onboarding app sets isOnboardingCompleted to true in me.json.
  Do NOT trigger for: profile editing, reading me.json, starting onboarding, deleting/listing agents, or any task unrelated to initial workspace setup.
---

# Apply Profile

One-shot skill that reads the completed owner profile and generates workspace configuration files.
No interactive questions — all input comes from `.vista/profile/me.json`.

## Data Sources

| File | Role |
|------|------|
| `.vista/profile/me.json` | Source of truth |
| `CLAUDE.md` | Role + Owner sections target |
| `.claude/agents/` | Agent files target |
| `memory/MEMORY.md` | Preference seed target |
| `.vista/state/onboarding.json` | Updated to `active` on success |

## Steps

### Step 1: Validate

Read `.vista/profile/me.json`. If `isOnboardingCompleted` is not `true`, stop:
> Profile interview is not yet complete. Please finish the onboarding interview in the app first.

Otherwise announce: `Profile loaded for {name}. Generating workspace configuration...`

### Step 2: Generate Role Section

Build a 1-2 sentence `## Role` block:

```
You are a {domain} assistant for {name}, helping with {top 2-3 outputs}.
Focus on {primary use case} — especially {pain point summary}.
```

Fields: `role.category`, `role.title`, `role.industry`, `work.primaryOutputs`, `goals.primaryUseCases`, `goals.painPoint`.
Describe the work, not the job title.

### Step 3: Generate Owner Section

Build `## Owner` block. Label mappings → `references/owner-section-labels.md`.

```markdown
## Owner

- **Name**: {name}
- **Language**: {label}
- **Output format**: {label}
- **Verbosity**: {label}
- **Tone**: {label}
- **Autonomy**: {label}
- **Edit scope**: {label}
- **Never do**: {workingStyle.neverDo — omit line if empty}
- **Always follow**: {workingStyle.alwaysFollow — omit line if empty}
```

### Step 4: Write CLAUDE.md

1. Read `CLAUDE.md`
2. Replace `## Role` section content with the generated role line
3. If `## Owner` already exists: skip and notify the owner
4. If missing: append the generated `## Owner` block

### Step 5: Generate Agent Files

Create `.claude/agents/` if absent. Generate one file per matching domain.
Domain conditions, file names, and system prompt templates → `references/agent-domains.md`.

### Step 6: Seed memory/MEMORY.md

Append to `memory/MEMORY.md` (create if absent):

```markdown
## Owner Preferences
- Do: Output in {preferences.language} with {preferences.outputFormat} format
- Do: Keep responses {preferences.verbosity} in length
- Do: Use {preferences.tone} tone
{if neverDo non-empty: "- Don't: {workingStyle.neverDo first item}"}

## Workflow Context
- Role: {role.category} in {role.industry} ({role.companySize})
- Primary outputs: {work.primaryOutputs joined}
- Key tools: {services.communication + services.projectManagement top 3}
- Core problem: {goals.painPoint truncated to 1 sentence}
```

### Step 7: Update onboarding.json

Set `status: "active"`, add `appliedAt` (ISO 8601), add/update `configGenerated` list. Preserve all other fields.

### Step 8: Confirm

> Done! Here's what I set up:
>
> - **Your assistant role** — {role line summary}
> - **Communication style** — {language}, {format}, {tone}
> - **Specialists ready** — {plain-language list of created agents}
>
> You're all set. Just ask me anything naturally — I'll work the way you prefer from the start.

Do not mention skipped domains unless the owner asks.
