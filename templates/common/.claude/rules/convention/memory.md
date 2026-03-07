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

1. When learning signals are detected during a session, note them internally
2. At session boundaries (e.g., task completion), batch-confirm with the user:
   - "I learned some things from today's conversation: ... May I record them?"
3. Record only user-approved insights in memory/
4. The AI handles classification and storage location decisions. Only ask the user for Yes/No

## Memory Review

Prevent accumulation of stale or contradictory knowledge:

- When requested by the user, present a current memory summary for confirmation
- Delete items deemed unnecessary

## Promotion to Rules

- When the same pattern is confirmed twice, promote it to `.claude/rules/`
- Remove promoted knowledge from memory/ to prevent duplication
