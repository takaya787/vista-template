# Workflow File Format Guide

Defines the markdown format for workflow definitions stored in `.ai/workflows/`.

## File Location

```
.ai/workflows/
├── weekly-sales-report.md
├── meeting-todo-extract.md
└── {slug}.md
```

## Naming Convention

- File name: `{verb}-{object}.md` in kebab-case (e.g., `summarize-meetings.md`, `aggregate-sales.md`)
- Keep names short and descriptive

## File Format

```markdown
---
name: {human-readable name}
trigger: "{comma-separated trigger phrases}"
created: {YYYY-MM-DD}
---

# {Workflow Name}

{1-2 sentence description of what this workflow does and when to use it.}

## Input

- Source: {where data comes from — file paths, directories, or "provided by owner"}
- Format: {expected format — CSV, TXT, markdown, etc.}

## Steps

1. {Step description}
2. {Step description}
3. {Step description}

## Output

- Destination: {where results are written — file path pattern or "display to owner"}
- Format: {output format — markdown, CSV, etc.}

## Skills Used

- {skill-name}: {how it's used in this workflow}

## Notes

{Any assumptions, limitations, or tips for this workflow. Optional section.}
```

## Example

```markdown
---
name: Meeting TODO Extract
trigger: "議事録TODO", "meeting todos", "extract action items"
created: 2026-03-31
---

# Meeting TODO Extract

Extract action items from meeting transcriptions and register them as tasks.

## Input

- Source: data/minutes/*.txt (latest transcription file)
- Format: Plain text transcription

## Steps

1. Read the latest transcription file from data/minutes/
2. Use `minutes` skill to generate structured meeting notes
3. Extract TODO items with assignees from the structured notes
4. Write summary to docs/minutes/YYYY-MM-DD-todos.md
5. Use `task-register` to add pending TODOs to .ai/tasks/

## Output

- Destination: docs/minutes/YYYY-MM-DD-todos.md
- Format: Markdown with TODO checklist

## Skills Used

- minutes: Converts raw transcription to structured meeting notes
- task-register: Registers extracted TODOs as pending tasks
```

## Guidelines

- Keep workflow definitions concise — under 50 lines
- Use existing skill names exactly as they appear in `.claude/skills/`
- Steps should be specific enough for Claude to execute without ambiguity
- Include file path patterns (with globs) so Claude knows where to look
- Trigger phrases should be natural language the owner would actually say
