---
name: apply-profile
description: Apply the completed owner profile to CLAUDE.md.
  Triggers on "/apply-profile", "apply my profile", "プロフィールを反映して", "設定を適用して".
  Run automatically after the onboarding app sets isOnboardingCompleted to true in me.json.
  Do NOT trigger for: profile editing, reading me.json, starting onboarding, or any task unrelated to workspace setup.
---

# Apply Profile

One-shot skill that reads the completed owner profile and generates the Owner section in CLAUDE.md.
No interactive questions — all input comes from `.vista/profile/me.json`.

## Data Sources

| File | Role |
|------|------|
| `.vista/profile/me.json` | Source of truth (6 fields) |
| `CLAUDE.md` | Owner section target |
| `.vista/state/onboarding.json` | Updated to `active` on success |

## Steps

### Step 1: Validate

Read `.vista/profile/me.json`. If `isOnboardingCompleted` is not `true`, stop:
> Profile is not yet complete. Please finish the onboarding first.

Otherwise announce: `Profile loaded for {name}. Applying settings...`

### Step 2: Generate Owner Section

Build `## Owner` block. Label mappings → `references/owner-section-labels.md`.

```markdown
## Owner

- **Name**: {name}
- **Language**: {label}
- **Output format**: {label}
- **Autonomy**: {label}
```

### Step 3: Write CLAUDE.md

1. Read `CLAUDE.md`
2. If `## Owner` already exists: replace its content with the generated block
3. If missing: append the generated `## Owner` block

### Step 4: Update onboarding.json

Set `status: "active"`, add `appliedAt` (ISO 8601). Preserve all other fields.

### Step 5: Confirm

> Done! Here's what I set up:
>
> - **Language** — {language label}
> - **Output format** — {format label}
> - **Autonomy** — {autonomy label}
>
> You're all set. To automate recurring tasks, try `/workflow-create`.
