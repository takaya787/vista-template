---
name: impl-prd
description: Implements an automation from a PRD. Creates the script directory, run_script.sh entry point, main.py, requirements.txt, and venv. Updates the manifest if one exists. Use when the user says "/impl-prd", "implement this PRD", "implement the automation", or "write the code for this". Also called internally by /automate Phase 3.
argument-hint: "<prd_path | slug | manifest_path>"
---

# impl-prd — PRD Implementation

Implements a single automation following the script conventions in
`skills/automate/references/script-conventions.md`.

Works standalone or as Phase 3 of `/automate`.

---

## Entry Point

Resolve the context from the argument:

| Argument form | Action |
|---------------|--------|
| Path ending in `.md` under `.taskmaster/docs/` | Treat as PRD path; derive slug from filename |
| Slug string (e.g. `slack-daily-summary`) | Load manifest at `.taskmaster/automations/{slug}/manifest.json`; read PRD from `manifest.prd_path` |
| Path ending in `manifest.json` | Load manifest directly |
| No argument | Ask the user for the PRD path or slug |

After resolving, read the PRD fully before writing any code.

---

## Steps

### Step 1: Resolve context

1. Load PRD and manifest (if it exists)
2. Confirm slug, working_dir (default: current directory), and task list
3. If `.taskmaster/automations/.active` does not exist and a manifest was found, write it:
   ```bash
   echo "{slug}" > .taskmaster/automations/.active
   ```

### Step 2: Scaffold directory

```bash
mkdir -p scripts/{slug}
```

If `scripts/{slug}/` already contains files, read them before overwriting anything.

### Step 2.5: Copy PRD into script directory

Copy the PRD into the script directory so the implementation and its spec stay colocated:

```bash
cp {prd_path} scripts/{slug}/prd.md
```

If `scripts/{slug}/prd.md` already exists, skip this step.

### Step 3: Phase 0 — Environment setup

1. Create venv if `tmp/venv` does not exist:
   ```bash
   python -m venv tmp/venv
   ```
2. Create `scripts/{slug}/requirements.txt` from the PRD's Tools & Integrations table
3. Install:
   ```bash
   source tmp/venv/bin/activate && pip install -r scripts/{slug}/requirements.txt
   ```

### Step 4: Implement (Phase 1 → 3)

Implement tasks in PRD roadmap order. For each task:
- Mark `in_progress` in task-master (if task_ids are known)
- Write or update the relevant `.py` file(s)
- Mark `done` in task-master

Produce at minimum:
- `scripts/{slug}/main.py` — core logic
- Additional `.py` modules as needed

### Step 5: Create run_script.sh

Create `scripts/{slug}/run_script.sh` using the template in
`skills/automate/references/script-conventions.md`:

```bash
chmod +x scripts/{slug}/run_script.sh
```

Verify it runs without error:
```bash
CLAUDE_PROJECT_DIR=$(pwd) bash scripts/{slug}/run_script.sh
```

### Step 6: Update manifest

If a manifest exists, update it:
```json
{
  "scripts": ["{working_dir}/scripts/{slug}/run_script.sh"],
  "working_dir": "{absolute working_dir}",
  "phase": "implemented"
}
```

### Step 7: Report

Print a summary:
```
✓ Implementation complete
────────────────────────────────
Slug:        {slug}
Entry point: scripts/{slug}/run_script.sh
Scripts:     scripts/{slug}/main.py (+ any helpers)
venv:        tmp/venv
Manifest:    {phase updated / not found}

Next step: /automate {slug}  (Phase 4: LaunchAgent registration)
```

If called from `/automate`, skip the "Next step" line and return to Phase 4.

---

## Constraints

- Entry point is always `run_script.sh` — never point callers at `main.py` directly
- All paths in `run_script.sh` must be self-relative (no hardcoded absolute paths)
- Follow `python-environment.md`: venv must live under `tmp/`
- Do not install packages globally (`pip install` outside venv is forbidden)
- Follow the Logging rules in `script-conventions.md`:
  - `FileHandler` → `/tmp/com.vista.{slug}.log` (INFO and above)
  - `StreamHandler` → stderr, with `setLevel(logging.ERROR)` (ERROR and above only)
  - Never use bare `StreamHandler()` without `setLevel` — it writes all logs to stderr and pollutes the error log
