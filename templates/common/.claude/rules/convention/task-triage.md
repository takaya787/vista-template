---
paths: "**/*"
---

# Task Triage — Complexity Assessment

Automatically assess task complexity before execution. Run this triage on every incoming task.

## Scoring Signals

Score the task on 3 signals (Irreversibility is a safety gate, not a score signal):

| Signal | Low (0pt) | High (1pt) |
|--------|-----------|------------|
| Step count | 1–2 actions | 3+ steps |
| Blast radius | 1 file / command | 2+ files / systems |
| Uncertainty | Approach is clear | Design decisions required |

## Irreversibility Safety Gate

Irreversibility is **not a score signal** — it is a mandatory warning applied regardless of score:

- If the operation involves external writes, deletions, or schema changes, prepend a one-line warning before executing
- Format: `"[IRREVERSIBLE] This will permanently {action}. Proceeding unless you say stop."`
- Do **not** escalate Simple or Confirm tasks to PLAN mode solely because they are irreversible

## Classification

| Total Score | Classification | Behavior |
|-------------|----------------|----------|
| 0pt | **Simple** | Declare in one sentence, then execute immediately. No task list needed |
| 1pt | **Confirm** | State the plan in 2-3 sentences and list affected files, wait for "ok" before executing |
| 2pt+ | **PLAN** | Enter plan mode, create task list, get user approval before execution |

## Simple Mode

- State what you will do in one sentence, then execute
- No `EnterPlanMode`, no `TaskCreate`

## Confirm Mode

- Summarize the approach in 2-3 sentences and list affected files or systems
- Wait for explicit user confirmation ("ok", "yes", "go ahead") before executing
- No `EnterPlanMode`, no `TaskCreate`

## PLAN Mode

1. Call `EnterPlanMode`
2. Explore the codebase to understand the impact scope
3. Use `TaskCreate` to create each step as a task
4. Use `TaskUpdate` with `addBlockedBy` / `addBlocks` to define dependencies between tasks
   - Sequential tasks (e.g., DB migration → API implementation → tests) must have `blockedBy`
   - Parallelizable tasks should have no dependencies
5. Save a plan document to `.ai/plans/` with: Objective / Scope / Non-goals / Steps / Verification
6. Request user approval
7. After approval, execute tasks in dependency order (start with tasks whose `blockedBy` is resolved), updating status via `TaskUpdate`

## Mid-Task Re-Triage

Re-evaluate when any of these occur during execution:

- Scope expands beyond the original assessment
- Unexpected design decisions arise
- Irreversible operations are discovered

When upgrading from Simple/Confirm → PLAN:

1. Notify the user of the re-classification and reason
2. Pause execution
3. Enter PLAN mode and follow the PLAN workflow above
