---
paths: "**/*"
---

# Design Artifacts Convention

Defines directory structure and management rules for design-related artifacts.
Project-specific tool settings (Figma URLs, etc.) belong in `rules/config/design-tools.md`.

## Directory Structure

```
design/
├── tokens/
│   ├── raw/           # Figma Tokens Plugin exports — NEVER edit directly
│   └── processed/     # Derived files (CSS variables, JSON) — generated from raw
├── specs/             # Component specification documents (AI-generated)
├── inbox/             # Screenshots, review requests, pasted text — temporary input
└── figma-links/       # Figma URL references as Markdown files
```

## Token Management

### Naming Convention

Tokens follow the `{category}.{tier}.{variant}` pattern:

| Category | Example |
|----------|---------|
| color | `color.primary.500`, `color.neutral.100` |
| spacing | `spacing.sm`, `spacing.page-margin` |
| typography | `typography.heading.xl`, `typography.body.md` |
| radius | `radius.sm`, `radius.full` |
| shadow | `shadow.card`, `shadow.modal` |

### Data Integrity Rules

1. Files in `design/tokens/raw/` are **immutable** — never edit originals. Process into `design/tokens/processed/`
2. When referencing token data, note the source at the top of the output:
   `> Source: design/tokens/raw/colors-2026-03-10.json`
3. If token data does not exist, use `[TOKEN DATA REQUIRED]` placeholder — never invent values
4. Name token files as `{category}-{YYYY-MM-DD}.{ext}` (e.g., `colors-2026-03-10.json`)

### Token Change Documentation

When tokens are added, changed, or deprecated, document the change:
- Save to `docs/design-system/{YYYY-MM-DD}-token-change.md`
- Include: changed tokens, reason, affected components, migration guide (if deprecated)

## Spec Documents

- Save as `design/specs/{component-name}/{YYYY-MM-DD}.md`
- Include frontmatter with Figma link and version
- Cover: states, interactions, accessibility, responsive behavior, edge cases

## Inbox Rules

- `design/inbox/` is a temporary staging area for review materials
- Accepted formats: screenshots (.png, .jpg), PDF, pasted text (.md, .txt)
- Process and move results to appropriate directories after use
- Do not accumulate files — clean up after each review session

## Integration with Common

This convention **extends** (does not override) the common `documentation.md` rules:
- `docs/` follows the same `{folder}/{YYYY-MM-DD-description}.md` naming from common
- `assets/` from common is used for Playwright-generated screenshots only
- Design-specific artifacts go in `design/` to avoid collision
