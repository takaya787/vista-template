---
paths: "**/*"
---

# Self-Learning & Memory Policy

Manage knowledge in two layers: **Auto Memory** (cross-session) and **Project Rules** (permanent conventions).
Minimize user burden. The AI handles all learning, classification, and organization.

## Auto Memory (`memory/`)

- `MEMORY.md` is auto-injected into every conversation. Strictly keep under 200 lines
- Split into topic files and reference them via pointers from MEMORY.md
- Write topic files in Do/Don't format to clarify behavioral guidelines
- Do not record: session-specific state, unverified guesses, duplicates of rules/, volatile information

## Signal-Based Learning

Detect learning opportunities from the following signals, even without the user explicitly saying "remember this":

| Signal | Detection Method | Example |
|--------|-----------------|---------|
| **Correction** | User corrects AI output | "Show it by category" → output format preference |
| **Repetition** | Same instruction appears 2+ times | Always says "in Japanese" → language setting |
| **Selection** | User picks one of multiple options | Chose option B → decision criteria |
| **Rejection** | User rejects a proposal | "That's not needed" → do-not-do list |

Do not save detected learning candidates immediately; record them only after the **confirmation loop**.

## Confirmation Loop (Learn → Confirm → Commit)

Batch-confirm detected learning candidates at one of these concrete moments:
1. **After a task is marked complete** — user says "done", "ok", "looks good" after an AI action
2. **When the user asks an unrelated new question** — natural conversation boundary
3. **When the user explicitly says "remember this" or "save this"**

Prompt format: "I noticed some patterns from today's session: [list]. May I record them?"

Record only user-approved insights in memory/. The AI handles classification and storage location. Only ask the user for Yes/No.

## Memory Review

Prevent accumulation of stale or contradictory knowledge:

- When requested by the user, present a current memory summary for confirmation
- Delete items deemed unnecessary

## Promotion to Rules

- When the same pattern is confirmed twice, promote it to `.claude/rules/config/` as a project-specific learned rule
- Convention files (`rules/convention/`) are immutable shared standards — NEVER modify them via the promotion process
- Follow `rule-conventions.md` format: add YAML frontmatter with `paths: "**/*"` for behavioral rules
- Suggested approach: accumulate promoted items in `rules/config/learned-preferences.md` to prevent file proliferation
- Remove promoted knowledge from `memory/` to prevent duplication

## Promotion Counter

Track promotion candidates in `memory/MEMORY.md` under a `## Learning Candidates` section:

```
## Learning Candidates
<!-- Format: [COUNT/2] description — detected YYYY-MM-DD -->
<!-- Promote to rules/config/learned-preferences.md when COUNT reaches 2 -->
```

When COUNT reaches 2, initiate promotion immediately at the next task boundary.
