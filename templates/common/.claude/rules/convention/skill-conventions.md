---
paths:
  - ".claude/skills/**"
---

# Skill Conventions

Rules for creating and modifying Skills.
Based on the [Anthropic skill_creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) pattern.

## SKILL.md Format

### Frontmatter (Required)

```yaml
---
name: skill-name
description: Description of the skill. Explicitly list when it should be triggered.
---
```

- **name**: lowercase hyphen-separated (e.g., `weekly-update`)
- **description**: Write "pushy" descriptions — Claude tends to under-trigger skills, so explicitly list applicable scenarios

How to write descriptions:
```
# Bad (vague, prone to under-triggering)
description: Generate a weekly report.

# Good (explicit trigger conditions listed)
description: Generate a weekly update report from GitHub Project data. Use when the user says "/weekly-update", "summarize this week's progress", or "create a weekly report". Proactively trigger at end-of-week or start-of-week reporting times.
```

### Body (Markdown Content)

Structure as follows:

1. **Title** — Skill name as H1
2. **Overview** — 1-2 lines describing what the skill does
3. **Why this skill is needed** — Background and purpose (so Claude understands the intent)
4. **Data sources** — List referenced files and APIs
5. **Steps** — Step 1, 2, ... describing the execution procedure
6. **Output format** — Show the template in markdown

### Writing Principles

- **Explain "why"** — Instead of `ALWAYS` / `NEVER`, write reasons for each directive
- **Use imperative form** — Direct instructions
- **Keep it lean** — Target under 500 lines. If exceeding, split into `references/`
- **Do not hardcode settings** — Write "refer to CLAUDE.md" for Project numbers, Org, etc. (to keep skills generic)

## Directory Structure

```
skill-name/
├── SKILL.md              # Required — Frontmatter + steps
├── scripts/              # Optional — Scripts for deterministic processing
├── references/           # Optional — Large documents (loaded on demand)
└── assets/               # Optional — Templates, icons, etc.
```

### Progressive Disclosure

1. **Metadata** (name + description) — Always in context. ~100 words max
2. **SKILL.md body** — Loaded when the skill is triggered. Under 500 lines recommended
3. **Bundled resources** (scripts/references/assets) — Loaded on demand. No size limit

Add a table of contents to large reference documents (300+ lines).

## Common vs Custom

| Category | Description | Examples |
|----------|-------------|----------|
| Common | Shared skills included in the template | `planning`, `sprint-goal`, `weekly-update` |
| Custom | Project-specific skills | Add freely |

Custom Skills should follow the naming and structure conventions of Common Skills.

## When Adding a New Skill

1. Create `.claude/skills/{skill-name}/SKILL.md`
2. Write Frontmatter + Body following the format above
3. Add an entry to the Custom Skills section of `CLAUDE.md`
4. Do not hardcode settings in the skill; reference `CLAUDE.md` instead
