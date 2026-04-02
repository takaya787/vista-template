---
name: workflow-run
description: Execute a saved workflow from .ai/workflows/. Use when the user says
  "/workflow-run", "run workflow", "ワークフロー実行", or uses a trigger phrase that matches
  a saved workflow (e.g., "weekly report", "summarize meeting", "extract TODOs").
  When the user's request matches a workflow trigger phrase, execute the workflow directly
  without asking for confirmation. Do NOT trigger for creating new workflows (use /workflow-create).
---

# Workflow Run

Execute a previously saved workflow definition from `.ai/workflows/`.

## Steps

### Step 1: Find the Workflow

1. If the user specified a workflow name or slug: look for `.ai/workflows/{slug}.md`
2. If the user used a natural phrase: scan all `.ai/workflows/*.md` and match against `trigger` fields in frontmatter
3. If no match found: list available workflows and ask the owner to choose
4. If no workflows exist: suggest `/workflow-create`

### Step 2: Load and Confirm

1. Read the matched workflow file
2. Briefly announce what will happen:

   > Running workflow: "{name}"
   > {1-line description from the workflow file}

3. If the workflow requires input that is not available (e.g., no files in the expected directory), ask the owner before proceeding

### Step 3: Execute Steps

Follow the workflow's `## Steps` section sequentially:

- For steps referencing a skill: invoke the skill with the appropriate context
- For steps with file operations: read/write as specified
- For steps with data processing: execute the transformation described

**Error handling:**
- If a step fails, report the error and ask the owner how to proceed
- Do not skip steps silently

### Step 4: Report Completion

> Workflow "{name}" completed.
> Output: {where results were saved}
>
> {Brief summary of what was produced}

If the workflow produced follow-up tasks (via task-register), mention them.
