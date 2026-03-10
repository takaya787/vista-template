# Vista Template

Role-based project templates for Claude Code. Each template provides a pre-configured `.claude/` setup with rules, skills, and hooks tailored to a specific job function.

## Available Templates

| Role | Status | Description |
|------|--------|-------------|
| `scrum-master` | Ready | Task management, sprint planning, weekly reports, meeting minutes |
| `product-manager` | Planned | Product roadmap, feature prioritization, stakeholder communication |
| `designer` | Planned | Design review, asset management, design system documentation |
| `engineer` | Planned | Code review, architecture decisions, technical documentation |
| `marketing` | Planned | Campaign tracking, content planning, analytics reports |
| `investor-relations` | Planned | Financial reporting, investor communication, KPI dashboards |

## Prerequisites

| Tool | Version | Required | Purpose |
|------|---------|----------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | latest | Yes | AI assistant CLI |
| [Git](https://git-scm.com/) | any | Yes | Repository cloning |
| [Node.js](https://nodejs.org/) | >= 18 | Yes | Notion scripts (Playwright) |
| [pnpm](https://pnpm.io/) | >= 8 | Yes | Package manager (used by setup script) |
| [GitHub CLI (`gh`)](https://cli.github.com/) | >= 2.0 | Yes (scrum-master) | GitHub API operations |
| Python 3 | >= 3.9 | No | Timezone auto-detection in setup |

> **Note:** `gh auth login` must be completed before running Claude Code with the scrum-master template. Notion access additionally requires `node scripts/notion-login.mjs` after setup.

## Quick Start

### One-command install (via curl)

No `git clone` required. Just run one command:

**Full Setup** (role-specific):

```bash
curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- scrum-master ~/path/to/your-project
```

**Quick Use** (common only):

```bash
curl -fsSL https://raw.githubusercontent.com/takaya787/vista-template/main/scripts/install.sh | bash -s -- ~/path/to/your-project
```

**Show Directory Usage** (scrum-master):

```bash
find templates/scrum-master -name "README.md" -not -path "templates/scrum-master/README.md" -exec sh -c 'echo "--- $(dirname "$1" | sed "s|templates/scrum-master/||") ---" && cat "$1" && echo' _ {} \;
```

**Show Directory Usage** (marketing):

```bash
find templates/marketing -name "README.md" -not -path "templates/marketing/README.md" -exec sh -c 'echo "--- $(dirname "$1" | sed "s|templates/marketing/||") ---" && cat "$1" && echo' _ {} \;
```

## Architecture: common + role

Templates are split into **common** (shared across all roles) and **role-specific** layers. The setup script merges both into the target directory.

```
templates/
├── common/                            # Shared across ALL roles
│   ├── .ai/                           # Task & plan tracking
│   ├── .claude/
│   │   ├── settings.local.json        # Base permissions and hooks config
│   │   ├── hooks/                     # Safety hooks (block dangerous commands, notifications)
│   │   ├── rules/
│   │   │   ├── authority.md           # Convention > Config precedence
│   │   │   ├── convention/            # Shared standards (do not modify)
│   │   │   │   ├── task-triage.md     # Complexity assessment
│   │   │   │   ├── workflow.md        # Planning, sub-agents
│   │   │   │   ├── documentation.md   # Doc output rules
│   │   │   │   ├── output-language.md # Language settings
│   │   │   │   ├── memory.md          # Self-learning policy
│   │   │   │   ├── onboarding.md      # Owner profile & onboarding rules
│   │   │   │   ├── claude-md.md       # CLAUDE.md guidelines
│   │   │   │   └── skill-conventions.md
│   │   │   └── config/
│   │   │       └── always.md          # Owner definition
│   │   └── skills/                    # Common skills (if any)
│   ├── docs/team.md                   # Team roster
│   ├── minutes/                       # Meeting transcripts
│   ├── screenshots/                   # Captured screenshots
│   ├── .vista/                        # Vista metadata directory
│   │   ├── state/                     # Onboarding & setup state (gitignored)
│   │   ├── profile/                   # Owner profile (gitignored)
│   │   │   └── me.example.json        # Owner profile template
│   │   └── config/                    # Vista-specific config (tracked)
│   ├── memory/MEMORY.md               # Auto-memory starter template
│   └── .gitignore                     # Pre-configured gitignore
│
├── scrum-master/                      # Role-specific (merged on top of common)
│   ├── CLAUDE.md                      # AI role: scrum master
│   ├── .claude/
│   │   ├── settings.local.json        # Extended permissions (gh, node, playwright)
│   │   ├── rules/convention/          # sprint-config.md, integrations.md
│   │   ├── rules/config/              # github-workflow.md, notion-pages.md
│   │   └── skills/                    # planning, sprint-goal, weekly-update, minutes
│   ├── docs/template-guide.md
│   ├── scripts/                       # Notion scripts
│   └── package.json                   # Playwright dependency
│
├── product-manager/                   # (planned)
├── designer/                          # (planned)
├── engineer/                          # (planned)
├── marketing/                         # (planned)
└── investor-relations/                # (planned)
```

### Rules Architecture

Rules are separated into two layers:

- **Convention** (`rules/convention/`) -- Shared immutable standards. Do not modify.
- **Config** (`rules/config/`) -- Project-specific settings. Customize for your environment.

Convention always takes precedence over Config. See `rules/authority.md` for details.

Common convention rules apply to all roles. Role-specific templates add additional convention and config rules on top.

## Setup Script

```bash
./scripts/setup.sh <role> <target-directory>
```

The script copies template files and creates the `.vista/` directory structure:

1. Copies common + role-specific files to the target
2. Creates `.vista/` directory with skeleton profile and onboarding state
3. On first Claude Code launch, `/onboarding` is automatically suggested to personalize your profile and settings (~3-5 minutes conversational interview)

See `docs/template-guide.md` in each template for detailed instructions.

## Contributing

To add a new role template:

1. Create a directory under `templates/<role-name>/`
2. Add only role-specific files -- common files are inherited automatically
3. Add a `CLAUDE.md` defining the AI's role
4. Add role-specific rules in `.claude/rules/convention/` and `.claude/rules/config/`
5. Add role-specific skills in `.claude/skills/`

## License

MIT
