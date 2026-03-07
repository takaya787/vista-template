---
paths: "**/*"
---

# Task Triage — Complexity Assessment

Automatically assess task complexity before execution. Run this triage on every incoming task.

## Scoring Signals

| Signal | Low (0pt) | High (1pt) |
|--------|-----------|------------|
| Step count | 1–2 actions | 3+ steps |
| Blast radius | 1 file / command | 2+ files / systems |
| Uncertainty | Approach is clear | Design decisions required |
| Irreversibility | Fully reversible | External writes / deletions / schema changes |

## Classification

| Total Score | Classification | Behavior |
|-------------|----------------|----------|
| 0pt | **Simple** | Declare in one sentence, then execute immediately. No task list needed |
| 1pt+ | **PLAN** | Enter plan mode, create task list, get user approval before execution |

## Simple Mode

- State what you will do in one sentence, then execute
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

When upgrading from Simple → PLAN:

1. Notify the user of the re-classification and reason
2. Pause execution
3. Enter PLAN mode and follow the PLAN workflow above
