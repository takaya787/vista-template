---
name: minutes
description: Generate structured meeting minutes from transcription text. Use when the user says "/minutes", "create minutes", "generate minutes from transcription", "summarize the meeting", or "organize meeting notes". Proactively trigger when .txt files exist in the minutes/ folder.
---

# Minutes Generator

Takes meeting transcription (.txt) as input and auto-generates structured meeting minutes.

## Why This Skill Is Needed

Transcriptions are chronological records of utterances, making it hard to grasp "what was decided" or "who does what" as-is. This skill extracts decisions and action items from transcriptions and structures them in a team-friendly format.

## Data Sources

- **Transcription files** — `.txt` files in the `minutes/` directory
- **Team composition** — Refer to `docs/team.md` (used for speaker name resolution)

## Steps

### Step 1: Identify File

Use the file path if provided as an argument. Otherwise, list `.txt` files in the `minutes/` directory and ask the user to select one.

### Step 2: Read & Analyze Text

Read the transcription text and extract the following:

- **Participants** — List speaker names. Cross-reference with `docs/team.md` to resolve GitHub IDs
- **Agenda items** — Detect topic transitions and group by agenda item
- **Decisions** — Extract from expressions like "decided to...", "agreed on...", "going with..."
- **Action items** — Extract assignee and content from expressions like "I'll handle...", "please do...", "will take care of..."
- **Shared information** — Extract important numbers, URLs, dates, etc. as notes

### Step 3: Generate Minutes

Generate minutes in the following format. Follow the language setting in `output-language.md`.

```markdown
# Minutes: {meeting name} ({YYYY-MM-DD})

## Basic Info
| Item | Details |
|------|---------|
| Date/Time | {date/time (estimated)} |
| Participants | {name list} |

## Agenda & Discussion
### 1. {topic}
{summary}

## Decisions
- {decision}

## Action Items
| # | Action | Assignee | Deadline |
|---|--------|----------|----------|
| 1 | {content} | @{assignee} | {deadline or TBD} |

## Shared Info & Notes
- {important numbers, URLs, etc.}
```

### Step 4: Save

Save the generated minutes to `docs/reports/{YYYY}/{MM}/{YYYY-MM-DD}-{meeting-title}.md`. Organize by year/month directories with date and meeting content in the file name. If a minutes file with the same name exists on the same day, append `-{N}` to the file name. Confirm with the user before saving.

### Step 5: Mark Source File as Processed

After saving the minutes, prepend a header line to the source transcription file to indicate it has been processed:

```
<!-- minutes: docs/reports/{YYYY}/{MM}/{YYYY-MM-DD}-{meeting-title}.md -->
```

This allows quick identification of processed files. When listing `.txt` files in Step 1, skip files whose first line starts with `<!-- minutes:` as they have already been processed.
