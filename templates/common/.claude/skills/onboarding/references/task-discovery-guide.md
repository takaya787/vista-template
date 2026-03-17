# Task Discovery Guide

Reference document for the onboarding skill. Guides the task discovery conversation after profile setup. The goal is to identify one concrete task the owner wants to accomplish right now, then do it together.

## Opening Question

Ask via `AskUserQuestion`:

- **header:** "First Task"
- **question:** "What's the most time-consuming or tedious task you deal with this week?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Writing a report or summary", description: "Progress updates, meeting notes, weekly reports" }`
  2. `{ label: "Organizing or analyzing data", description: "Spreadsheets, metrics, dashboards" }`
  3. `{ label: "Coordinating timelines or priorities", description: "Project schedules, deadlines, team coordination" }`
  4. `{ label: "Creating or reviewing documents", description: "Proposals, specs, presentations" }`

Note: These options describe work categories, not AI capabilities. The framing must always be about the owner's work.

The owner can always provide a free-text answer via "Other".

## Deep-Dive: 5 Dimensions

Once the owner selects or describes a task, gather these 5 dimensions through natural conversation (not a form). Infer as much as possible from the owner's initial answer; only ask about what is unclear.

| Dimension | What to learn | Example inference |
|-----------|--------------|-------------------|
| **What** | The deliverable type | "report" → document, "dashboard" → data visualization |
| **Input** | Where the source data/info comes from | "from GitHub" → API data, "from meetings" → transcription |
| **Output** | Where the result goes | "send to team" → Slack/email, "update the doc" → file write |
| **Frequency** | How often this task recurs | "every Monday" → weekly, "after each sprint" → bi-weekly |
| **Pain** | What makes it tedious | "copy-pasting data" → automation opportunity |

### Conversation Style

Weave dimension discovery into natural follow-up, not sequential questions.

**Example:**
- Owner selects: "Writing a report or summary"
- Good: "Tell me more — what kind of report is it, and where do you usually pull the data from?"
  (This covers What + Input naturally)
- Bad: "What is the deliverable type? Where does the source data come from? Where does the result go?"
  (This feels like a form)

### Inference Rules

Use these to minimize follow-up questions:

| Owner says | Infer |
|-----------|-------|
| "report" or "summary" | What=document, Output=file or message |
| "data" or "numbers" | What=analysis, Input=spreadsheet or API |
| "meeting" or "standup" | What=minutes or agenda, Input=calendar/transcription |
| "review" or "check" | What=checklist, Input=existing document |
| "plan" or "schedule" | What=plan document, Input=backlog or calendar |

### Follow-Up Limit

- Ask at most **1 follow-up question** to clarify dimensions that cannot be inferred
- **The 1-question limit is absolute.** It takes priority over dimension coverage. If multiple dimensions are unclear, select the single most impactful dimension to clarify and infer the rest.
- If still unclear after 1 follow-up, make reasonable assumptions and proceed — the task execution itself will surface corrections

## Task Scope Confirmation

After gathering dimensions, confirm the task scope with the owner before proceeding. Use `AskUserQuestion`:

- **header:** "Task Confirmation"
- **question:** "Here's what I'll help you with: [2-3 sentence summary of the understood task]. Does this sound right?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Yes, that's right", description: "Let's get started" }`
  2. `{ label: "Close, but let me adjust", description: "I'll clarify what I need" }`
  3. `{ label: "Let's pick a different task", description: "I'd rather work on something else" }`

If the owner selects "adjust", ask a single open-ended follow-up: "What should I change?" Then incorporate their response. If the adjustment changes the core task (different deliverable type), re-confirm once. If it is a refinement (same deliverable, different scope), proceed directly to Step 4. If they select "different task", return to the Opening Question.

## Common Task Patterns

Reference table for mapping discovered tasks to execution approaches:

| Pattern | Typical Input | Typical Output |
|---------|--------------|----------------|
| Progress report | GitHub/project data | Markdown summary |
| Meeting minutes | Transcription text | Structured notes |
| Data analysis | CSV/spreadsheet | Summary + charts |
| Document draft | Requirements/notes | Structured doc |
| Sprint planning | Backlog items | Sprint plan |
| Review/audit | Existing artifacts | Checklist + findings |

## Anti-Patterns

- **Do not ask the owner's role or job title** — discover what they do through what they need done
- **Do not present a menu of capabilities** — ask about their work, not about AI features
- **Do not collect information speculatively** — only gather what is needed for the immediate task
- **Do not ask more than 1 follow-up** — start doing, learn by doing
