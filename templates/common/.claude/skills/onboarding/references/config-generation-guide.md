# Config Generation Guide

Reference document for the onboarding skill. Defines how to generate configuration files as a byproduct of task execution during onboarding.

## Service Detection

During task execution, detect which external services are relevant and generate config accordingly.

### GitHub Detection

1. Run `which gh` to check if GitHub CLI is installed
2. If not installed: skip GitHub config entirely. Add "Set up GitHub CLI integration" to `pendingTasks` in `onboarding.json`. Do not suggest installation steps — this breaks the onboarding flow.
3. If installed: run `gh auth status` to check authentication
4. If not authenticated: skip GitHub config. Add "Authenticate GitHub CLI" to `pendingTasks`.
5. If authenticated: detect org and repo via `gh repo view --json owner,name`
6. Generate relevant config entries in `rules/config/` if placeholders exist

### Generic Service Detection

When a task references an external service (Notion, Google Sheets, Jira, etc.):

1. Note the service name and how the owner interacts with it
2. Do not attempt to auto-configure — record the service reference for future setup
3. Add a note to `memory/MEMORY.md` using the format: `- Owner uses {service} for {purpose} (mentioned during onboarding)`
4. Add `{service} integration setup` to `pendingTasks` in `onboarding.json` so it surfaces in future sessions

## CLAUDE.md Role Definition

When the first task reveals the owner's working domain, draft a role line for `CLAUDE.md`:

```markdown
## Role
You are a [domain] assistant for [owner name], helping with [primary task type].
```

- Present the draft to the owner in natural language: "I'd describe my role as: '[draft]'. Does that feel right?"
- Only write a role definition if the repository's CLAUDE.md does not already contain one
- Keep it to 1-2 sentences maximum
- Do not mention specific job titles — describe the work, not the role

## Changeset Presentation

When presenting the changeset to the owner for confirmation (SKILL.md Step 5), use plain language:

**Do:**
> Based on our work together, I picked up the following:
> - You prefer concise bullet-point outputs in Japanese
> - You create a weekly marketing report from Google Sheets every Monday
> - Your team reviews reports via Slack
>
> I'll save these so I remember next time. Anything I should change?

**Do not:**
> Saving to `.vista/profile/me.json`, `memory/MEMORY.md`, `rules/config/`...

The owner confirms the *insights*, not the *storage locations*. File operations happen silently after confirmation.

## Memory Seed Format

After completing the first task, seed `memory/MEMORY.md` with initial preferences. Follow the `memory.md` convention (Do/Don't format).

Before writing, check if `memory/MEMORY.md` already exists. If so, append seeds under existing sections using the same headers already present. If not, create it with these default sections:

```markdown
## Owner Preferences
- Do: [observed preference from task execution]
- Don't: [observed anti-preference from task execution]

## Workflow Context
- [Key context discovered during task, e.g., "Owner reviews sprint data every Monday"]
```

- Only record preferences that were directly observed during the task
- Do not speculate about preferences not yet demonstrated
- Keep the initial seed to 3-5 items maximum

## onboarding.json Schema

The onboarding state file tracks progress across sessions:

```json
{
  "status": "active",
  "startedAt": "<ISO 8601 timestamp>",
  "maturity": "seed",
  "discoveredTasks": [
    {
      "name": "<task description>",
      "completedAt": "<ISO 8601 timestamp>",
      "configGenerated": ["<list of files created/updated>"]
    }
  ],
  "pendingTasks": [
    "<task description mentioned but not yet executed>"
  ]
}
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `status` | `"pending"` \| `"active"` | Current onboarding state |
| `startedAt` | ISO 8601 string | When onboarding first ran |
| `maturity` | `"seed"` \| `"growing"` \| `"established"` | How personalized the environment is |
| `discoveredTasks` | array | Tasks completed during onboarding sessions |
| `pendingTasks` | array of strings | Tasks identified but not yet executed |

### Maturity Progression

| Level | Criteria | Display Label |
|-------|----------|---------------|
| `seed` | Profile created, 0-1 tasks completed | "just getting started" |
| `growing` | 2-3 tasks completed, some config generated | "well-configured" |
| `established` | 4+ tasks completed, stable config in place | "fully set up" |

When displaying maturity to the owner, use the Display Label (plain language), not the internal level name.

### Status Transitions

- `pending` → `active`: First onboarding session starts
- `active` → `active`: Additional tasks discovered/completed (stays active)
