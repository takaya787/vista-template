---
name: research-synthesis
description: Synthesize user research, interview transcripts, and feedback into structured insights. Use when the user says "/research-synthesis", "summarize user research", "analyze these interviews", "what did users say about", "ユーザーリサーチをまとめて", or "synthesize feedback". Proactively trigger when 2+ files appear in inbox/ that appear to be interview notes, survey results, or support logs.
---

# Research Synthesis — User Research Analysis

Synthesize raw user research from `inbox/` into structured, source-traceable insights grouped by theme.

## Why This Skill Is Needed

Unstructured analysis of interview notes produces findings that cannot be defended to stakeholders or traced back to source material. This skill enforces source citation at the signal level, prevents fabrication of frequencies, and outputs a format ready to feed directly into `/prd` or `/prioritize`.

## Input Requirements

| Input | Action |
|-------|--------|
| Interview transcripts or notes in `inbox/` | Read all files; process each |
| Survey results or CSV in `inbox/` | Read and extract verbatim responses |
| Support tickets or feedback logs in `inbox/` | Read and classify by entry |
| Files pasted directly by user | Use as source; label with user-provided filename |
| No files and no pasted content | `[REQUIRES INPUT]` — Ask: "Please drop your research files in `inbox/` or paste the content here." and stop |
| Vague request with no topic specified | Proceed with full synthesis; note scope in output |

## Data Sources

1. **Raw research** — all files in `inbox/` matching research, interview, survey, or feedback patterns
2. **Product scope** — `rules/config/roadmap-settings.md` for target user and product area (to focus theme relevance)
3. **PM data integrity** — `rules/convention/pm-data-integrity.md` for source citation and estimation labeling rules

## Steps

### Step 1: Inventory Source Files

List all files in `inbox/`. Classify each as:
- `interview` — 1:1 user interview transcript or notes
- `survey` — structured survey responses
- `feedback` — support tickets, app store reviews, NPS comments, sales call notes
- `unknown` — cannot determine type

If no files exist and no content was pasted, emit `[REQUIRES INPUT]` and stop.

### Step 2: Extract Raw Signals

For each source file, extract individual signals — discrete observations, statements, or behaviors. For each signal, record:

| Field | Rule |
|-------|------|
| Signal | Verbatim quote or close paraphrase |
| Type | `pain` / `gain` / `behavior` / `workaround` / `request` |
| Source | Filename + participant ID or entry number |

Apply `pm-data-integrity.md`: every signal must have a traceable source. Do not infer signals not present in the material.

### Step 3: Cluster Themes

Group signals with similar meaning into themes. For each theme:

- Name the theme in a noun phrase (e.g., "Onboarding friction", "Trust in data accuracy")
- Count the number of distinct sources that mention it (frequency)
- Select 1–3 representative verbatim quotes
- Note whether the theme is positive (gain), negative (pain), or behavioral

A theme with only one source is noted as `[SINGLE SOURCE — verify]`.

### Step 4: Identify Opportunities and Gaps

From the themes, derive:

- **Top pain points**: themes with highest frequency and `pain` or `workaround` signals
- **Unmet needs**: requests and workarounds with no current product solution
- **Gaps in research**: important user segments or scenarios not represented in the source material

Any opportunity derived by inference (not directly stated) must be labeled `[ESTIMATED]` with reasoning.

### Step 5: Save

Save to `docs/research/{YYYY-MM-DD}-{topic-slug}.md`. Confirm topic slug with user if not obvious from source content.

## Output Format

```markdown
---
date: YYYY-MM-DD
topic: <research topic>
sources: <N> files — list filenames
status: [DRAFT]
---

## Executive Summary

(3–5 sentences. What is the most important finding? What does it suggest for the product?)

## Key Themes

### 1. <Theme Name>

- **Frequency**: N out of M sources
- **Type**: Pain / Gain / Behavior
- **Representative quotes**:
  > "..." — Source: inbox/{filename}, participant {ID}
  > "..." — Source: inbox/{filename}, participant {ID}
- **Insight**: (1–2 sentences interpreting the pattern. Label with [ESTIMATED] if inferred.)

### 2. <Theme Name>

...

## Top Pain Points

| Pain | Frequency | Severity signal | Source |
|------|-----------|----------------|--------|
| ... | N/M sources | (quote or behavior indicating severity) | inbox/... |

## Opportunities

| Opportunity | Supporting themes | Confidence |
|-------------|------------------|------------|
| ... | Theme 1, Theme 2 | [ESTIMATED] / Source-backed |

## Research Gaps

- (User segments not represented in this research)
- (Scenarios mentioned but not explored in depth)
- (Questions this synthesis cannot answer)

## References

- inbox/{filename} — {type}, {N} participants/entries
- inbox/{filename} — {type}, {N} participants/entries
```

Note: All insights are `[DRAFT]` and require owner review before use in PRDs or stakeholder communications.
