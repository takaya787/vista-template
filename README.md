# Vista Template

A project template for Claude Code that provides a pre-configured `.claude/` setup with rules, skills, and hooks.

## Prerequisites

| Tool | Required | Purpose |
|------|----------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Yes | AI assistant CLI |
| [Git](https://git-scm.com/) | Yes | Version control |
| [GitHub CLI (`gh`)](https://cli.github.com/) | No | GitHub username auto-detection |
| Python 3 | No | Timezone auto-detection |

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- ~/path/to/your-project
```

This single command:

1. Downloads vista-template to `~/.vista/vista-template/` (persistent location)
2. Installs Claude Code CLI if not present
3. Deploys common templates to your project directory
4. Generates `.vista/` state and profile skeleton

After installation:

```bash
cd ~/path/to/your-project
claude
```

## Architecture

All templates live under `templates/common/`.

```
templates/common/
├── .ai/                               # Task & plan tracking
│   ├── plans/
│   └── tasks/
├── .claude/
│   ├── settings.local.sample.json     # Base permissions and hooks config
│   ├── hooks/                         # Safety hooks (block dangerous commands, notifications)
│   ├── rules/
│   │   ├── authority.md               # Convention > Config precedence
│   │   ├── convention/                # Shared standards (symlinked, do not modify)
│   │   │   ├── always.md             # Core behavior rules
│   │   │   ├── task-triage.md        # Complexity assessment
│   │   │   ├── workflow.md           # Planning, sub-agents
│   │   │   ├── documentation.md      # Doc output rules
│   │   │   ├── output-language.md    # Language settings
│   │   │   ├── claude-md.md         # CLAUDE.md guidelines
│   │   │   ├── guardrails.md        # Safety guardrails
│   │   │   ├── rule-conventions.md  # Rule authoring standards
│   │   │   ├── skill-conventions.md # Skill authoring standards
│   │   │   └── python-environment.md
│   │   └── config/                    # Project-specific settings
├── skills/
│   │   ├── minutes/                  # Meeting minutes skill
│   │   ├── task-register/            # Task registration
│   │   └── task-runner/              # Task execution
├── .vista/                            # Vista metadata
│   ├── state/                         # setup.json (gitignored)
│   └── config/                        # Vista-specific config (tracked)
├── docs/                              # Documentation
├── minutes/                           # Meeting transcripts
└── .gitignore.sample                  # Gitignore template
```

### Rules Architecture

Rules are separated into two layers:

- **Convention** (`rules/convention/`) -- Shared immutable standards. Do not modify.
- **Config** (`rules/config/`) -- Project-specific settings. Customized manually.

Convention always takes precedence over Config. See `rules/authority.md` for details.

## Deploy Script

```bash
./scripts/copy-common.sh <target-directory>
```

Deploys common templates to the target directory:

1. Creates directory skeleton (`.claude/`, `.ai/`, `.vista/`, etc.)
2. Symlinks convention files to the persistent install location
3. Copies config, skills, hooks, and other project-specific files
4. Generates `.vista/state/` skeleton
5. Auto-detects GitHub username and timezone

## Install Strategy

### Persistent install location

`install.sh` downloads vista-template once to a fixed location:

```
~/.vista/vista-template/   <- single source of truth for all workspaces
```

This path can be overridden with the `VISTA_HOME` environment variable.

### Convention files as symlinks

`copy-common.sh` deploys convention files as **absolute-path symlinks** pointing to the persistent install:

| File type | Deployment | Reason |
|---|---|---|
| `rules/convention/*.md` | symlink | Update once, reflected everywhere |
| `rules/authority.md` | symlink | Same |
| `rules/config/*.md` | copy | Project-specific content |
| `.claude/hooks/*.sh` | copy | Symlinks are a security risk for hooks |
| `.claude/skills/` | copy | Project-specific, not updated centrally |
| `.claude/settings.local.json` | copy from sample (first time only) | User edits this |

Symlinked files are listed in `.gitignore` and are **not committed** to the workspace repository. They are regenerated per machine.

### New machine setup

When cloning a workspace on a new machine, symlinks are absent (gitignored). Re-run the installer to restore them:

```bash
# If vista-template is not yet installed on this machine:
curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- ~/path/to/workspace

# If already installed:
~/.vista/vista-template/scripts/copy-common.sh ~/path/to/workspace
```

### Updating vista-template

`install.sh` always removes the existing `~/.vista/vista-template` and re-downloads the latest version. Simply re-run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- ~/path/to/workspace
```

Convention files are deployed as symlinks, so updating `~/.vista/vista-template` via `install.sh` ensures every workspace immediately reads the latest convention rules.

## Contributing

To contribute to vista-template:

1. **Add convention rules** in `templates/common/.claude/rules/convention/` -- shared standards that apply to all projects
2. **Add skills** in `templates/common/.claude/skills/` -- reusable skill definitions
3. **Add hooks** in `templates/common/.claude/hooks/` -- safety and automation hooks
Convention rules must NOT contain project-specific information or concrete service names. All project-specific details belong in config rules.

## License

MIT
