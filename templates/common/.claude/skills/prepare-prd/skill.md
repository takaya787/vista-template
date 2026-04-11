---
name: prepare-prd
description: Conducts a structured interview to create a PRD for an automation task. Use when the user says "/prepare-prd", "I want to organize requirements", "I want to create a PRD", or "I have something I want to automate". Presents fixed forms one by one to elicit requirements and saves the PRD to .taskmaster/docs/.
argument-hint: "<brief description of what you want to automate (optional)>"
---

# Prepare PRD — From Form Interview to PRD Creation

## Overview

Conduct an interview using the fixed forms in `references/forms.md`, then map the answers to the PRD Format in the same file to create and save the PRD.

**Language:** Present all questions and responses in the user's language. Translate form questions on the fly — the source forms are in English but always speak to the user in their preferred language.

## Steps

### Step 1: Load Forms

Load `references/forms.md`.

### Step 2: Conduct Interview

Present Form 1–5 **one at a time**, collecting answers before moving to the next.
Translate each question into the user's language before presenting it.

Rules:
- Present one form at a time; wait for the previous form's answers before proceeding
- Skip items left blank
- If a reference resource URL is provided in Form 3 Q3, load it immediately and reflect it in the PRD
- If an answer is ambiguous, ask for clarification once: "Do you mean something like ~?"
- If the user says "skip", "next", or "continue", end the current form and move on
- If an argument is provided, treat it as the answer to Form 1 and ask only for missing information

### Step 3: Create and Save PRD + Manifest

After all forms are complete, generate the PRD and initialize the manifest in one step.

**3-1. PRD saving:**
1. Generate a slug from the title (e.g., "Weekly Slack Sales Report" → `slack-weekly-sales-report`)
2. File name: `YYYY-MM-DD-{slug}.md` (today's date)
3. If `.taskmaster/docs/` does not exist, run `mkdir -p .taskmaster/docs`
4. Write to `.taskmaster/docs/YYYY-MM-DD-{slug}.md`

**3-2. Manifest initialization (always, regardless of task generation):**
1. Run `mkdir -p .taskmaster/automations/{slug}`
2. Write `.taskmaster/automations/{slug}/manifest.json`:

```json
{
  "id": "{slug}",
  "phase": "prd_created",
  "prd_path": ".taskmaster/docs/YYYY-MM-DD-{slug}.md",
  "task_ids": [],
  "scripts": [],
  "working_dir": "",
  "launch_agent_label": "",
  "plist_path": "",
  "verified_at": null,
  "registered_at": null,
  "created_at": "<ISO8601 now>"
}
```

3. Display both paths after saving:
   - PRD: `.taskmaster/docs/YYYY-MM-DD-{slug}.md`
   - Manifest: `.taskmaster/automations/{slug}/manifest.json`

### Step 4: Task Generation (Optional)

Ask the user if they want to auto-generate tasks.
Only if approved, use taskmaster MCP tools to:

1. Create epic tasks with `add_task`
2. Expand each task into subtasks and set dependencies with `expand_task`
3. Display the list of generated tasks
4. Update the manifest `task_ids` with the generated IDs and set `phase: "tasks_generated"`

After Step 4, inform the user: `Run /automate {slug} to continue to implementation.`
