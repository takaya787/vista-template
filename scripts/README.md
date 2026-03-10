Setup and utility scripts for scaffolding Vista templates into target projects.

## Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | Sets up a role template (common + role-specific files, `.vista/` directory structure). Profile personalization is handled by the `/onboarding` skill on first Claude Code launch |
| `copy-common.sh` | Copies only the shared common templates (.claude rules, hooks, docs structure) without role-specific configuration or interactive prompts |
