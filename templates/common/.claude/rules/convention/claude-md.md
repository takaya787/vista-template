---
paths:
  - "CLAUDE.md"
---

# CLAUDE.md Writing Guidelines

CLAUDE.md is the project's "entry point" — the first file the AI reads.
Prioritize brevity; do not include information discoverable through exploration.

## What to Include

| Type | Example |
|------|---------|
| **AI role and behavior definition** | "Act as a senior task manager" |
| **Settings not discoverable from code** | Pointers to `rules/config/` where settings are defined |
| **Reference pointers** | "See `docs/team.md` for team info" |
| **Constraints and prerequisites** | "Notion API is unavailable due to org restrictions" |

## What NOT to Include

| Type | Reason | Alternative |
|------|--------|-------------|
| **Directory structure trees** | Discoverable via `ls` | Not needed |
| **File listing tables** | Discoverable by browsing directories | Not needed |
| **Command usage examples** | Belong in `rules/` or `scripts/` | Reference the relevant rule/script |
| **Skills listing** | Auto-injected via system reminder | Not needed |
| **Team member details** | Defined in `docs/team.md` | Include pointer only |
| **Hardcoded personal info** | Dynamically managed via `.vista/profile/me.json` | Reference `.vista/profile/me.json` |
| **Service-specific config** | URLs, org names, project IDs, repo names belong in `rules/config/` | Add pointer to the config file |
| **Info duplicating rules/** | Creates dual maintenance | Reference the relevant rule |

## Principles

1. **Only include information that can ONLY live here** — Do not include info obtainable from other files or exploration
2. **Pointers over transcription** — Delegate details to referenced files; CLAUDE.md holds links only
3. **Do not hardcode settings** — Reference dynamic sources like `.vista/profile/me.json`
4. **No duplication with rules/** — Do not repeat content written in Convention/Config in CLAUDE.md
5. **Service config in rules/config/** — External service settings (URLs, org/project IDs, repo names, API keys references) must live in `rules/config/`, not in CLAUDE.md. CLAUDE.md only holds a pointer to the config file
