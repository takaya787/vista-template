# Automate Skill — Phase Reference

## Manifest Schema

```json
{
  "id": "{slug}",
  "phase": "prd_created | tasks_generated | implemented | registered | verified | completed",
  "prd_path": ".taskmaster/docs/YYYY-MM-DD-{slug}.md",
  "task_ids": ["1", "2", "3"],
  "scripts": ["/absolute/path/to/scripts/{slug}/main.py"],
  "working_dir": "/absolute/path/to/project",
  "launch_agent_label": "com.vista.{slug}",
  "plist_path": "~/Library/LaunchAgents/com.vista.{slug}.plist",
  "verified_at": null,
  "registered_at": null,
  "created_at": "ISO8601"
}
```

---

## Phase 1: PRD Creation

**Entry condition:** No manifest exists.

1. Invoke the `prepare-prd` skill (present Form 1–4, generate PRD)
   - `prepare-prd` saves the PRD to `.taskmaster/docs/YYYY-MM-DD-{slug}.md`
   - `prepare-prd` also creates the manifest at `.taskmaster/automations/{slug}/manifest.json` with `phase: "prd_created"` (see prepare-prd Step 4)
2. If the user provided a pre-existing PRD path, skip the interview and read the PRD to derive the slug

**Manifest fields set:** `id`, `prd_path`, `created_at`, `phase: "prd_created"`

---

## Phase 2: Task Generation

**Entry condition:** `manifest.phase == "prd_created"`

0. Write the active automation pointer so the PostToolUse hook can resolve the manifest:
   ```bash
   echo "{slug}" > .taskmaster/automations/.active
   ```
1. Read the PRD at `manifest.prd_path`
2. Use taskmaster MCP tools to generate tasks from the PRD:
   - `parse_prd` with the PRD path, or
   - `add_task` + `expand_task` for each phase in the PRD's Development Roadmap
3. Collect all generated task IDs
4. Update manifest: `task_ids`, `phase: "tasks_generated"`

**Manifest fields set:** `task_ids`, `phase: "tasks_generated"`

---

## Phase 3: Implementation

**Entry condition:** `manifest.phase == "tasks_generated"`

Delegate entirely to the `impl-prd` skill:

> Invoke `impl-prd` with the manifest path or slug.
> `impl-prd` handles scaffolding, venv, coding, `run_script.sh` creation, and manifest update.
> When `impl-prd` returns, verify `manifest.phase == "implemented"` before proceeding.

Full implementation rules are defined in:
- `skills/impl-prd/SKILL.md` — step-by-step procedure
- `skills/automate/references/script-conventions.md` — directory layout and `run_script.sh` template

**Manifest fields set:** `scripts`, `working_dir`, `phase: "implemented"`

---

## Phase 4: LaunchAgent Registration

**Entry condition:** `manifest.phase == "implemented"`

Invoke the `launch-agent-registrar` agent with the manifest context:

1. Read the current manifest
2. Derive label: `com.vista.{slug}`
3. Create plist at `/tmp/com.vista.{slug}.plist` with:
   - `ProgramArguments` calling `manifest.scripts[0]` (always `run_script.sh` — see `script-conventions.md`)
   - `WorkingDirectory` from `manifest.working_dir`
   - Schedule from the PRD's Execution Conditions
   - Log paths: `/tmp/com.vista.{slug}.log` and `/tmp/com.vista.{slug}-error.log`
4. Copy to LaunchAgents via `cp` (triggers PostToolUse Hook)
5. Bootstrap with `launchctl`
6. Update `automation-library.json` — include these fields sourced from the manifest:
   ```json
   {
     "label": "com.vista.{slug}",
     "task_ids": ["..."],
     "prd_path": "...",
     "scripts": ["..."],
     "working_dir": "...",
     ...
   }
   ```
7. Update manifest: `launch_agent_label`, `plist_path`, `registered_at`, `phase: "registered"`

**Manifest fields set:** `launch_agent_label`, `plist_path`, `registered_at`, `phase: "registered"`

---

## Phase 5: Verification

**Entry condition:** `manifest.phase == "registered"`

1. Confirm launchctl registration:
   ```bash
   launchctl list | grep com.vista.{slug}
   ```
2. Kick off a test run:
   ```bash
   launchctl kickstart -k gui/$(id -u)/com.vista.{slug}
   ```
3. Check logs:
   ```bash
   cat /tmp/com.vista.{slug}.log
   cat /tmp/com.vista.{slug}-error.log
   ```
4. If errors found: diagnose, fix scripts, re-register (loop back to Phase 4)
5. If clean: update manifest `verified_at`, `phase: "verified"`

**Manifest fields set:** `verified_at`, `phase: "verified"`

---

## Phase 6: Completion

**Entry condition:** `manifest.phase == "verified"`

1. Remove the active automation pointer:
   ```bash
   rm -f .taskmaster/automations/.active
   ```
2. Set `manifest.phase: "completed"`
2. Print a summary table:

```
✓ Automation registered and verified
─────────────────────────────────────
ID:          {slug}
PRD:         {prd_path}
Tasks:       {task_ids}
Scripts:     {scripts}
LaunchAgent: {launch_agent_label}
Schedule:    {schedule from PRD}
Verified at: {verified_at}
```

3. Remind the user that logs are at `/tmp/com.vista.{slug}.log`
