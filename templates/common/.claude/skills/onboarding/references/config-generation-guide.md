# Config Generation Guide

Reference document for the onboarding skill. Defines how to generate configuration as a byproduct of task execution during onboarding.

## What Gets Saved

During onboarding, only these categories of config are generated:

1. **Owner preferences** — Written to `.vista/profile/me.json` (language, format, autonomy + any preferences discovered during task execution)
2. **Onboarding state** — Written to `.vista/state/onboarding.json`

All other configuration (role definitions, service integrations, workflow automation) is handled by dedicated skills (`/workflow-create`, etc.) outside of onboarding.

## Changeset Presentation

When presenting learned config to the owner, use plain language:

**Do:**
> Based on our work together, I picked up the following:
> - You prefer concise bullet-point outputs in Japanese
> - You like headers to organize long outputs
>
> I'll save these so I remember next time. Anything I should change?

**Do not:**
> Saving to `.vista/profile/me.json`...

The owner confirms the *insights*, not the *storage locations*. File operations happen silently after confirmation.

## onboarding.json Schema

```json
{
  "status": "active",
  "startedAt": "<ISO 8601 timestamp>",
  "maturity": "seed",
  "discoveredTasks": [
    {
      "name": "<task description>",
      "completedAt": "<ISO 8601 timestamp>"
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
| `growing` | 2-3 tasks completed | "well-configured" |
| `established` | 4+ tasks completed, workflows created | "fully set up" |

### Status Transitions

- `pending` → `active`: First onboarding session starts
- `active` → `active`: Additional tasks discovered/completed (stays active)

## Write Sequence

After owner confirms the changeset:

1. `.vista/profile/me.json` — any new preference fields discovered
2. `.vista/state/onboarding.json` — update last (confirms successful write)
