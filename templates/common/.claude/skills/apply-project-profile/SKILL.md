---
name: apply-project-profile
description: Apply the completed project interview profile to workspace files in one shot.
  Triggers on "/apply-project-profile", "apply project profile", "configure project workspace",
  "プロジェクト設定を反映して", "プロジェクトプロフィールを適用して".
  Run automatically after the onboarding app sets isOnboardingCompleted to true in project.json.
  Do NOT trigger for: editing project details, reading project.json, starting onboarding,
  or updating an already-configured project (use /onboarding-project for updates instead).
---

# Apply Project Profile

One-shot skill that reads the completed project profile and generates workspace configuration files.
No interactive questions — all input comes from `.vista/profile/project.json`.

## Data Sources

| File | Role |
|------|------|
| `.vista/profile/project.json` | Source of truth |
| `.vista/profile/project.md` | Generated context document (target) |
| `CLAUDE.md` | Key References table target |
| `rules/config/always.md` | Active load instruction target |

Generation rules and templates → `.claude/skills/onboarding-project/references/project-generation-guide.md`

## Steps

### Step 1: Validate

Read `.vista/profile/project.json`. Stop if any of the following:

- File does not exist → `Project profile not found. Please complete the project interview in the app first.`
- `isOnboardingCompleted` is not `true` → `Project interview is not yet complete. Please finish it in the app first.`
- Required fields missing (`company.name`, `company.industry`, `company.description`, `myWork.domain`, `myWork.products`, `currentInitiatives`) → list missing fields and stop.

If valid, announce:
> Project profile loaded for {company.name}. Generating workspace configuration...

### Step 2: Generate project.md

Read `.claude/skills/onboarding-project/references/project-generation-guide.md` for the template and field mapping rules. Generate `.vista/profile/project.md` from the JSON. Omit sections whose source fields are absent.

### Step 3: Update CLAUDE.md

Read `CLAUDE.md`. If the Key References table does not already contain a row for `project.md`, add one after the `Owner personal data` row:

```
| Project context | `.vista/profile/project.md` (generated via `/onboarding-project`) |
```

If the row already exists, skip silently.

### Step 4: Update rules/config/always.md

Append to `rules/config/always.md` (create the file if absent). Skip if the `## Project Context` section already exists.

```markdown

## Project Context

Read `.vista/profile/project.md` at the start of each session for business context (company, domain, current initiatives, constraints).
```

If the file does not exist, create it with the following frontmatter before appending:

```markdown
---
paths: "**/*"
---
```

### Step 5: Confirm

> Done! Here's what I set up for **{company.name}**:
>
> - **Project context file** — `.vista/profile/project.md` generated
> - **Session auto-load** — Claude will read your project context at the start of every session
> - **Domain**: {myWork.domain}
> - **Current focus**: {currentInitiatives — truncated to 1 sentence if long}
>
> Run `/onboarding-project` anytime to update your project context.
