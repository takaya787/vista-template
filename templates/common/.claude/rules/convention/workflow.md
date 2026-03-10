---
paths: "**/*"
---

# Workflow Rules

## 1. Planning Phase (Plan Mode)

- Run complexity triage per `task-triage.md` before deciding to enter plan mode
- Tasks with **3+ steps** or requiring design decisions **must enter plan mode first**
- Do not start implementation until the plan is confirmed by the user
- Plan must clearly define:
  - Objective (What / Why)
  - Scope of impact (files, layers, systems)
  - Non-goals (what is explicitly out of scope)
  - Implementation steps (broken down into minimal units)
  - Verification steps
- Save plan files to `.ai/plans/` directory
- If a problem arises mid-implementation, **stop immediately and re-plan** (do not force through)
- Document detailed specs upfront to eliminate ambiguity

## 2. Sub-Agent Strategy

- **Actively use sub-agents** to keep the main context window clean
- Delegate research, code exploration, and parallel analysis to sub-agents
- For complex problems, deploy multiple sub-agents to apply more compute
- 1 sub-agent = 1 focused task

## 3. Self-Improvement Loop

- Follow the `memory.md` convention for self-learning and memory management
- During sessions, detect implicit learning from signals: corrections, repetitions, selections, rejections
- Batch-confirm detected learning candidates with the user at task boundaries; record only approved items
- When the same pattern is confirmed twice, promote it to `.claude/rules/config/` (never convention/) and remove from memory/
