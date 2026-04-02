---
name: workflow-create
description: Create an automated workflow definition through conversation. Use when the user says
  "/workflow-create", "automate this task", "save this as a workflow", "make this repeatable",
  "create a workflow", "ワークフロー作成", "これを自動化したい", "定型作業を登録したい",
  "毎週やってるこの作業を楽にしたい". Also proactively suggest when the user completes a task
  that appears to be recurring. Do NOT trigger for one-off tasks (use /task-register instead).
---

# Workflow Create

Build an automated workflow definition through conversation with the owner. A workflow combines existing skills (minutes, task-register, recall-context, etc.) into a repeatable sequence that can be executed with `/workflow-run`.

## Design Principles

1. **Conversation-driven** — Discover the workflow through dialogue, not a form
2. **Skill composition** — Workflows chain existing skills as building blocks
3. **Start simple** — Define the minimum viable workflow, refine through use
4. **One at a time** — Create one workflow per invocation

## Data Sources

- `.ai/workflows/*.md` — Saved workflow definitions
- `.claude/skills/` — Available skills to compose into workflows
- `references/workflow-format-guide.md` — Workflow file format specification

## Available Skills (Building Blocks)

| Skill | What it does | Workflow use |
|-------|-------------|-------------|
| `minutes` | Generate meeting minutes from transcription | Input processing step |
| `recall-context` | Retrieve past conversation history | Context gathering step |
| `task-register` | Register tasks to queue | Output step (create follow-up tasks) |
| `task-runner` | Execute queued tasks autonomously | Autonomous execution step |

Custom steps (file reading, data processing, document generation) can also be included as plain instructions.

## Steps

### Step 1: Understand the Task

Ask the owner what they want to automate. Use `AskUserQuestion`:

- **question:** "What recurring task do you want to automate?"
- **options:**
  1. `{ label: "Report or summary creation", description: "Weekly reports, meeting summaries, data digests" }`
  2. `{ label: "Data processing", description: "CSV aggregation, format conversion, analysis" }`
  3. `{ label: "Document generation", description: "Templates, proposals, standardized docs" }`
  4. `{ label: "Task coordination", description: "TODO extraction, assignment tracking, follow-ups" }`

The owner can provide a free-text answer via "Other".

### Step 2: Gather Workflow Details

Through natural conversation (not a form), learn these dimensions:

| Dimension | What to learn | Example |
|-----------|--------------|---------|
| **Trigger** | How the owner will invoke this workflow | "weekly report", "summarize meeting" |
| **Input** | Where source data comes from | `data/*.csv`, `minutes/*.txt`, clipboard |
| **Processing** | What transformation happens | Aggregate, summarize, extract, format |
| **Output** | Where the result goes | `docs/reports/`, specific file, screen |
| **Skills used** | Which existing skills to chain | minutes → task-register |

**Rules:**
- Ask at most **2 follow-up questions** to clarify
- Infer what you can from the owner's initial description
- If unclear, make reasonable assumptions and note them in the confirmation

### Step 3: Confirm the Workflow

Present the workflow definition in plain language for confirmation:

```
📋 {Workflow Name}

Trigger: "{trigger phrase}"
Steps:
  1. {Step description}
  2. {Step description}  ← skill: {skill-name}
  3. {Step description}
Output: {where results go}
```

Use `AskUserQuestion`:
- "Does this workflow look right?"
- Options: "Yes, save it" / "Let me adjust" / "Start over"

### Step 4: Save the Workflow

Write the workflow definition to `.ai/workflows/{slug}.md` following the format in `references/workflow-format-guide.md`.

Create `.ai/workflows/` directory if it does not exist.

### Step 5: Confirm and Suggest

> Workflow "{name}" saved! You can run it anytime with:
> - `/workflow-run {slug}`
> - Or just say "{trigger phrase}"
>
> Want to create another workflow, or try running this one?
