---
name: task-runner
description: Execute a single pending task from a .ai/tasks/ queue file autonomously. Invoked by the watcher process (watch.sh) via `claude -p`. Reads the task description, marks it in-progress, executes the work, then marks it done. Do NOT trigger from interactive user sessions — this skill is designed for headless autonomous execution.
---

# Task Runner

An autonomous execution skill invoked by the watcher process via `claude -p`.
Picks up one task from the `.ai/tasks/*.md` queue, executes it, and records completion.

## Steps

### Step 1: Identify the task

Read the file path and task slug from the invocation prompt.
If not specified, scan `.ai/tasks/*.md` and pick the first `[ ]` entry.

Task entry format:

```
## [ ] {slug}
{description}
Done criteria: {criteria}
```

### Step 2: Mark as In Progress

Update the relevant line in the task file (do this immediately before execution to prevent other processes from duplicate-running the same task):

```
## [ ] {slug}  →  ## [~] {slug}
```

### Step 3: Execute the task

Read the description and done criteria, explore the codebase as needed, and implement.

**Complexity assessment (per task-triage.md):**

- Simple (0pt): Execute directly
- PLAN (1pt+): Create a plan before executing. No user confirmation needed — self-approve since this is autonomous execution

**Execution notes:**

- Always keep the done criteria in mind — it defines "done"
- Do not commit changes (that is the watcher's responsibility)
- If unexpected errors or design decisions are required, proceed to Step 4b below
- **When recording completion in Step 4a, automatically fetch the current date/time in YYYY-MM-DD HH:MM format using `date '+%Y-%m-%d %H:%M'`**

### Step 4a: Completed → Mark as Done

When the implementation is complete and the done criteria are met, update the task file:

```
## [~] {slug}  →  ## [x] {slug}
{description}
Done criteria: {criteria}
Done: {YYYY-MM-DD HH:MM}
```

### Step 4b: Failed → Mark as Blocked

When execution is not possible (design decision required, dependent task incomplete, insufficient information, etc.):

```
## [~] {slug}  →  ## [!] {slug}
{description}
Done criteria: {criteria}
Blocked reason: {reason in one line}  ← appended
```

Status reference:
| Marker | Meaning |
|--------|---------|
| `[ ]` | Pending — not yet executed |
| `[~]` | In Progress — executing |
| `[x]` | Done — completed |
| `[!]` | Blocked — cannot execute (reason noted) |
