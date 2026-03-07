# Template Guide

## Getting Started

1. Run `./scripts/setup.sh scrum-master <target-dir>` — the script interactively collects all settings (GitHub, Notion, user profile) and generates config files and `me.json`
2. `cd <target-dir>`
3. Add member profiles in `docs/members/{github}.md` (if your team has multiple members)
4. Start Claude Code: `claude`

## Customization

### Config files to edit

| File | What to change |
|------|---------------|
| `rules/config/github-workflow.md` | Org, Project number, Issue repo, Output repos |
| `rules/config/notion-pages.md` | Notion page URLs |
| `rules/config/always.md` | Owner behavior (usually no changes needed) |

### Convention files (do not modify)

Files in `rules/convention/` are shared standards. If you need to change behavior, add a new config file or propose a change to the convention upstream.

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Planning | `/planning` | Sprint planning dashboard |
| Sprint Goal | `/sprint-goal` | Per-assignee sprint goals for Notion |
| Weekly Update | `/weekly-update` | Weekly progress report |
| Minutes | `/minutes` | Meeting minutes from transcription |
