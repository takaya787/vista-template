---
paths:
  - ".claude/rules/**"
---

# Rule Conventions

Rules for creating and modifying Rule files (`rules/convention/` and `rules/config/`).

## Frontmatter (Required)

Every rule file MUST start with YAML frontmatter. This enables Claude Code to scope when the rule is loaded.

```yaml
---
paths:
  - "pattern/to/match/**"
---
```

- **paths**: Glob patterns defining when the rule activates. Use `"**/*"` for rules that always apply
- Frontmatter must be the very first content in the file (no blank lines before `---`)

### Examples

```yaml
# Always active
---
paths: "**/*"
---

# Scoped to specific directories
---
paths:
  - ".claude/skills/**"
---

# Scoped to multiple patterns
---
paths:
  - "CLAUDE.md"
  - "docs/**"
  - "assets/**"
---
```

## Body (Markdown Content)

Structure as follows:

1. **Title** — Rule name as H1
2. **Overview** — 1-2 lines describing the rule's purpose
3. **Sections** — Organized by topic with H2/H3 headings

## Writing Principles

- **Explain "why"** — Provide reasoning, not just directives
- **Use imperative form** — Direct instructions
- **Keep it lean** — Avoid unnecessary verbosity
- **Convention vs Config** — Convention files must NOT contain project-specific information (see `authority.md`)

## When Adding a New Rule

1. Determine if the rule is Convention (shared standard) or Config (project-specific)
2. Create the file in the appropriate directory (`rules/convention/` or `rules/config/`)
3. Add YAML frontmatter with appropriate `paths` patterns
4. Follow the body structure above
