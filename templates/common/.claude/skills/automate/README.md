# Automation Loop — Overview

End-to-end management of macOS automation lifecycles: from PRD creation through LaunchAgent registration and verification.

---

## Full Flow

```
/prepare-prd
    │  Conduct interview, generate PRD
    │  → .taskmaster/docs/YYYY-MM-DD-{slug}.md
    │  → .taskmaster/automations/{slug}/manifest.json (phase: prd_created)
    ▼
/automate {slug}  ─────────────────────────────────────────────┐
    │                                                           │
    │  Phase 2: Task Generation                                 │
    │    add_task / expand_task via task-master                 │
    │    write .active → Hook auto-updates manifest.task_ids   │
    │                                                           │
    │  Phase 3: Implementation  ← delegated to /impl-prd       │
    │    scaffold scripts/{slug}/                               │
    │    implement main.py → generate run_script.sh             │
    │                                                           │
    │  Phase 4: LaunchAgent Registration                        │
    │    launch-agent-registrar creates and loads plist         │
    │    updates automation-library.json                        │
    │                                                           │
    │  Phase 5: Verification                                    │
    │    launchctl kickstart → check logs                       │
    │                                                           │
    │  Phase 6: Complete                                        │
    │    remove .active → manifest.phase: completed             │
    └───────────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
.claude/
├── skills/
│   ├── automate/                    # /automate skill
│   │   ├── SKILL.md                 # Entry point and loop definition
│   │   └── references/
│   │       ├── phases.md            # Detailed steps for Phases 1–6
│   │       ├── script-conventions.md # scripts/{slug}/ layout and run_script.sh template
│   │       └── automation-library-schema.md  # Schema for ~/.vista/automation-library.json
│   │
│   ├── impl-prd/                    # /impl-prd skill (implementation phase only)
│   │   └── SKILL.md                 # Full procedure: PRD → code generation
│   │
│   └── prepare-prd/                 # /prepare-prd skill (PRD creation)
│       ├── skill.md                 # Interview → PRD → manifest initialization
│       └── references/
│           └── forms.md             # Interview form definitions and PRD format
│
├── agents/
│   └── launch-agent-registrar.md   # LaunchAgent registration and library management agent
│
└── hooks/
    └── update-manifest-on-task.sh  # Auto-updates manifest.task_ids on add_task / expand_task

~/.vista/
└── automation-library.json         # Machine-wide registry of all com.vista.* LaunchAgents

{workspace}/
└── .taskmaster/
    ├── docs/
    │   └── YYYY-MM-DD-{slug}.md    # PRD
    └── automations/
        ├── .active                 # Slug of the automation currently being worked on (read by Hook)
        └── {slug}/
            └── manifest.json       # Single source of truth linking PRD, tasks, scripts, and LaunchAgent
```

---

## Component Purposes

### Skills

| Skill | Command | Purpose |
|-------|---------|---------|
| prepare-prd | `/prepare-prd` | Create PRD via interview and initialize manifest |
| automate | `/automate {slug}` | Drive the full Phase 1–6 loop. Resumes from last completed phase |
| impl-prd | `/impl-prd {slug}` | Run the implementation phase standalone. Also called as Phase 3 of `/automate` |

### Agents

| Agent | Purpose |
|-------|---------|
| launch-agent-registrar | Owns plist creation, LaunchAgent loading, and `automation-library.json` updates. Supports manifest mode (called from `/automate`) and manual mode |

### Hooks

| Hook | Trigger | Purpose |
|------|---------|---------|
| update-manifest-on-task.sh | PostToolUse: `add_task` / `expand_task` | Auto-appends generated task IDs to `manifest.task_ids` while `.active` exists |

### State Files

| File | Role |
|------|------|
| `manifest.json` | One file per automation. Single cross-reference linking PRD, task IDs, scripts, and LaunchAgent |
| `.active` | Holds the current slug in one line. Used by the Hook to resolve which manifest to update |
| `automation-library.json` | Machine-wide registry. Tracks all registered LaunchAgents across multiple workspaces |

---

## manifest.json Lifecycle

```
phase: prd_created       ← created by /prepare-prd
  ↓
phase: tasks_generated   ← /automate Phase 2 done  (task_ids populated)
  ↓
phase: implemented       ← /impl-prd done           (scripts, working_dir populated)
  ↓
phase: registered        ← launch-agent-registrar done (launch_agent_label, registered_at populated)
  ↓
phase: verified          ← /automate Phase 5 done   (verified_at populated)
  ↓
phase: completed         ← /automate Phase 6        (.active removed)
```

---

## Script Structure Convention (Summary)

```
scripts/{slug}/
├── run_script.sh    ← sole entry point (the only thing the LaunchAgent plist calls)
├── main.py          ← core logic
└── requirements.txt ← Python dependencies
```

- The plist `ProgramArguments` calls only `run_script.sh` — never `main.py` directly
- `run_script.sh` owns PATH setup, venv activation, and Python execution
- No hardcoded absolute paths — `working_dir` is resolved from the script's own location

Full details: `references/script-conventions.md`

---

## Quick Reference — What to Edit

| Goal | File |
|------|------|
| Change the PRD creation process | `skills/prepare-prd/skill.md` |
| Change the loop phases | `skills/automate/references/phases.md` |
| Change the implementation procedure | `skills/impl-prd/SKILL.md` |
| Change the script structure convention | `skills/automate/references/script-conventions.md` |
| Change the LaunchAgent registration procedure | `agents/launch-agent-registrar.md` |
| Change the automation library schema | `skills/automate/references/automation-library-schema.md` |
| Change the Hook logic | `hooks/update-manifest-on-task.sh` |
