Setup and utility scripts for scaffolding Vista templates into target projects.

## Scripts

| Script | Purpose |
|--------|---------|
| `install.sh` | Entry point for curl-based installation. Downloads vista-template, installs Claude Code CLI, then delegates to `setup.sh` or `copy-common.sh` |
| `setup.sh` | Sets up a role template (common + role-specific files, `.vista/` directory structure). Profile personalization is handled by the `/onboarding` skill on first Claude Code launch |
| `copy-common.sh` | Copies only the shared common templates (.claude rules, hooks, docs structure) without role-specific configuration |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VISTA_HOME` | `~/.vista/vista-template` | Override install path |
| `VISTA_FORCE` | `true` | Skip confirmation prompts (set `false` to enable interactive prompts) |
