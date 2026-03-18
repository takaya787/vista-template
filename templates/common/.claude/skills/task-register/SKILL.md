---
name: task-register
description: Register a task into a .ai/tasks/ queue file for autonomous AI execution by a watcher process. Use when the user says "/task-register", "register this task", "I want the AI to handle this later", "save this as an autonomous task", "run this in the background", "add to task queue", or any phrase indicating they want to defer work to the AI. Also trigger when the user describes a feature, fix, or refactor and says they're not ready to execute it yet — proactively suggest registering it.
---

# Task Register

A skill that appends task entries to a task queue file (`.ai/tasks/*.md`) to be read and executed by an AI watcher process.

## CRITICAL: Session Boundary Rules

The session in which this skill runs is a **registration-only session**. Even after `/task-register` is invoked, this session maintains registration-only behavior for the duration of the conversation.

```
┌─────────────────────────────┐     ┌──────────────────────────────┐
│  Interactive Session         │     │  Watcher Session              │
│  (where this skill runs)     │     │  (claude -p / watch.sh)       │
│                              │     │                               │
│  ✅ Register tasks only       │────▶│  ✅ Execute tasks              │
│  ❌ Implementation / changes  │     │  ✅ Update status              │
│  ❌ Launch agents             │     │  ✅ Mark as done               │
└─────────────────────────────┘     └──────────────────────────────┘
```

**Never do the following in this session:**

- Implement, modify code, investigate, or analyze
- Read files (other than writing to task files)
- Launch agents or sub-agents
- Suggest "shall I implement this?" after registration
- Attempt to execute `[ ]` tasks found in the queue

Registered tasks are executed by the watcher process in a separate session. This session's role ends there.

## File Structure

1 file = 1 topic (may contain multiple tasks). Separate files by domain:

```
.ai/tasks/
├── ui.md        # Frontend / UI related
├── backend.md   # Backend / API related
├── infra.md     # Build / CI / Infrastructure related
└── (any name).md
```

## Task Entry Format

```markdown
## [ ] {task-slug}

{1–2 line description. What, where, and why}
Done criteria: {one-line verification method}
```

Status markers (updated by the watcher and Claude Code):

- `[ ]` — Pending (registered, not started)
- `[~]` — In Progress (running)
- `[x]` — Done (completed), append `Done: YYYY-MM-DD` at the end

---

## Steps

### Step 1: Identify the target file (no reading required)

Determine the topic from conversation context and user description alone, then decide which file to append to.

- No need to explore the codebase or read files
- Ask the user only when the topic is unclear

### Step 2: Generate the task entry

Write concisely following these guidelines:

- **slug**: verb-object kebab-case (e.g., `add-dark-mode`, `fix-auth-bug`)
- **description**: 1–2 lines. Organize the user's description as-is
- **done criteria**: a one-line criterion the watcher can use to determine completion

### Step 3: Append to the file

Use only the Write / Edit tools to append the entry to the end of the target file.
**Write immediately without asking the user for confirmation.** Edit permissions for `.ai/tasks/` are pre-authorized in `settings.local.json`, so no permission prompt will appear.

**File splitting when exceeding 1000 lines:**
Check the line count of the target file before appending. If the file exists and exceeds 1000 lines, switch the append target to the next file with a numeric suffix of the same name.

- `ui.md` exceeds 1000 lines → check `ui-2.md`
- `ui-2.md` also exceeds 1000 lines → check `ui-3.md`
- Continue similarly, using the first file that is 1000 lines or fewer, or does not exist

If the file does not exist, create it with the following header:

```markdown
# Tasks: {topic}
```

### Step 4: Report completion and stop

```
Registered: added to .ai/tasks/{file}.md
Task: {slug}
```

If the file was split, report that as well:

```
Registered: added to .ai/tasks/{file}.md ({original}.md exceeded 1000 lines, split)
Task: {slug}
```

**Stop here. Do not implement, investigate, or suggest anything further.**
