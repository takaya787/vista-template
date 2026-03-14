---
name: task-register
description: Register a task into a .ai/tasks/ queue file for autonomous AI execution by a watcher process. Use when the user says "/task-register", "register this task", "I want the AI to handle this later", "save this as an autonomous task", "run this in the background", "add to task queue", or any phrase indicating they want to defer work to the AI. Also trigger when the user describes a feature, fix, or refactor and says they're not ready to execute it yet — proactively suggest registering it.
---

# Task Register

A skill that appends task entries to task queue files (`.ai/tasks/*.md`) read and executed by the AI watcher process.

## CRITICAL: Session Boundary Rules

The session in which this skill operates is a **registration-only session**. After `/task-register` is invoked, this session maintains registration-only behavior for the duration of the conversation.

```
┌─────────────────────────────┐     ┌──────────────────────────────┐
│  Interactive Session         │     │  Watcher Session              │
│  (session running this skill)│     │  (claude -p / watch.sh)       │
│                              │     │                               │
│  ✅ Task registration only   │────▶│  ✅ Task execution             │
│  ❌ Implementation / changes │     │  ✅ Status updates             │
│  ❌ Agent invocation         │     │  ✅ Completion marking         │
└─────────────────────────────┘     └──────────────────────────────┘
```

**Actions strictly prohibited in this session:**

- Implementation, code changes, investigation, or analysis
- File reads (except writing to task files)
- Agent / sub-agent invocation
- Post-registration suggestions such as "Shall I implement this?"
- Attempting to execute `[ ]` tasks even if they exist in the queue

Registered tasks are executed by the watcher process in a separate session. This session's role ends there.

## File Structure

1 file = 1 topic (containing multiple tasks). Files are organized by domain:

```
.ai/tasks/
├── ui.md        # Frontend / UI related
├── backend.md   # Backend / API related
├── infra.md     # Build / CI / Infrastructure related
└── (any-name).md
```

## Task Entry Format

```markdown
## [ ] {task-slug}

{1-2 line description. What / Where / Why}
Done criteria: {verification method in one line}
```

Status markers (updated by the watcher and Claude Code):

- `[ ]` — Pending (registered, not yet started)
- `[~]` — In Progress (executing)
- `[x]` — Done (completed), append `Done: YYYY-MM-DD` at the end

---

## Steps

### Step 1: Identify the target file (no file reads needed)

Determine the topic from the conversation context and user description alone, then decide which file to append to.

- No codebase exploration or file reads required
- Only ask the user for clarification when uncertain

### Step 2: Generate the task entry

Write concisely following these guidelines:

- **slug**: verb-noun in kebab-case (e.g., `add-dark-mode`, `fix-auth-bug`)
- **description**: 1-2 lines. Organize and transcribe the user's description as-is
- **Done criteria**: A single line that lets the watcher determine "this is done"

### Step 3: Append to the file

Use only the Write / Edit tools to append the entry to the end of the target file.
**Write immediately without asking for user confirmation.** Edit permissions for `.ai/tasks/` are pre-authorized in `settings.local.json`, so no permission prompt will appear.
If the file does not exist, create it with the following header:

```markdown
# Tasks: {topic}
```

### Step 4: Report completion and finish

```
Registered: added to .ai/tasks/{file}.md
Task: {slug}
```

**Stop here. Do not perform any implementation, investigation, or suggestions.**
