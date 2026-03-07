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

## Quick Start

```bash
# Clone the repository
git clone https://github.com/takaya787/vista-template.git
cd vista-template

# Set up a template in your project
./scripts/setup.sh scrum-master ~/path/to/your-project

# Navigate to your project and start Claude Code
cd ~/path/to/your-project
claude
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
│   │   │   │   ├── onboarding.md      # me.json lifecycle
│   │   │   │   ├── claude-md.md       # CLAUDE.md guidelines
│   │   │   │   └── skill-conventions.md
│   │   │   └── config/
│   │   │       └── always.md          # Owner definition
│   │   └── skills/
│   │       └── onboarding/            # /onboarding skill
│   ├── docs/team.md                   # Team roster
│   ├── minutes/                       # Meeting transcripts
│   ├── screenshots/                   # Captured screenshots
│   ├── me.example.json                # Owner profile template
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

The script copies **common first**, then **role-specific files on top** (overwriting where needed). After setup:

1. Edit `.claude/rules/config/` files to set your project-specific settings
2. Edit `docs/team.md` to add your team members
3. Start Claude Code and run `/onboarding` to create your `me.json`

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
