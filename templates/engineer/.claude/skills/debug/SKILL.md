---
name: debug
description: Investigate a bug from logs, stack traces, or reproduction steps. Use when the user says "/debug", "investigate this bug", "why is this failing", "debug this error", "バグを調査して", or pastes a stack trace or error log. Proactively trigger when files exist in `inbox/` or the user shares an error message.
---

# Debug — Bug Investigation

Investigate a bug systematically using a hypothesis-first approach. Outputs a structured bug report with root cause, fix, and prevention.

## Why This Skill Is Needed

Ad-hoc debugging expands scope indefinitely. This skill constrains investigation to a hypothesis, prevents reading unrelated code, and forces explicit reasoning before suggesting a fix. Without structure, an AI investigator tends to read everything and conclude nothing actionable.

## Input Requirements

| Input | Action |
|-------|--------|
| Stack trace | Extract error type, origin file, and line; form hypothesis before reading code |
| Log output | Find first ERROR/FATAL/WARN entry; trace forward from there |
| Reproduction steps in `inbox/` | Read file; execute or simulate to observe actual vs expected |
| "It doesn't work" with no detail | `[REQUIRES INPUT]` — Ask: "What is the error message, stack trace, or unexpected behavior?" and stop |
| Error that cannot be reproduced locally | `[CANNOT REPRODUCE]` — Document hypothesis, list manual verification steps, do not guess a fix |

## Data Sources

1. **Bug report** — stack trace, log, or file in `inbox/`
2. **Source files** — only those relevant to the hypothesis
3. **Tech stack** — `rules/config/tech-stack.md` for runtime and framework context
4. **Change safety** — `rules/convention/change-safety.md` before proposing any fix

## Steps

### Step 1: Classify Input

Determine the input type and extract the minimal signal:

- **Stack trace**: Take the topmost application frame (skip framework internals). Extract: error type, message, file, line.
- **Log**: Find the first ERROR or FATAL. Note the timestamp and any preceding WARNs.
- **Reproduction steps**: Identify the trigger action and the expected vs actual outcome.

If classification is impossible due to missing information, emit `[REQUIRES INPUT]` and stop.

### Step 2: Form Hypothesis Before Reading Code

State the hypothesis in one sentence before opening any file.

> Example: "The null pointer at `UserService.ts:42` suggests `user` is not validated before `.profile` is accessed."

Rules:
- Read only files named in the stack trace or directly related to the hypothesis
- If the hypothesis is disproven, state the new hypothesis explicitly before expanding scope
- Do not read more than 5 files before reformulating the hypothesis

### Step 3: Locate Root Cause

Navigate from the symptom to the origin:

1. Read the failing file at the identified line
2. Trace the data flow back to where the unexpected value enters
3. Check boundary conditions: null/undefined, empty input, off-by-one, async timing
4. Check recent changes: `git log -5 --oneline <file>` to surface regressions

### Step 4: Assess Fix Safety

Before proposing a fix, apply Blast Radius Assessment from `rules/convention/change-safety.md`:

| Dimension | Question |
|-----------|----------|
| Scope | How many files does the fix touch? |
| Consumers | What calls or imports the affected code? |
| Data | Does the fix alter data handling or serialization? |
| Reversibility | Can the fix be rolled back without side effects? |

If the fix requires a Tier 2+ operation (per `change-safety.md`), stop and surface this before proceeding.

### Step 5: Propose Fix

Provide the minimal fix that addresses the root cause. Do not refactor unrelated code in the same change.

If the root cause cannot be confirmed from available context, tag the fix as `[UNVERIFIED FIX — requires: {what is needed to confirm}]`.

### Step 6: Save Report

Save to `docs/bugs/{YYYY-MM-DD}-{slug}.md`. Move or link the original `inbox/` file if applicable.

## Output Format

```markdown
---
bug: <short slug>
date: YYYY-MM-DD
status: Root cause identified | Hypothesis only | Cannot reproduce
severity: [CRITICAL] | [MAJOR] | [MINOR]
---

## Summary

- **Symptom**: (one sentence describing what the user observed)
- **Root cause**: (one sentence stating the confirmed or hypothesized cause)
- **Status**: Root cause identified / Hypothesis only / Cannot reproduce

## Reproduction

| Step | Detail |
|------|--------|
| Trigger | (action that causes the bug) |
| Expected | (what should happen) |
| Actual | (what actually happens) |
| Environment | (runtime, version, branch if known) |

## Root Cause Analysis

(Explanation of the failure path. Reference specific file:line. Use `[INFERRED]` for conclusions not directly confirmed by reading source code.)

## Fix

(Minimal code change to address the root cause. If unverified: tag as `[UNVERIFIED FIX — requires: ...]`)

```language
// before
...

// after
...
```

## Prevention

- (What test would catch this regression?)
- (What convention or rule would prevent recurrence?)

## Related

- Inbox source: `inbox/<filename>` (if applicable)
- Related ADR: (if architectural context applies)
```

Note: All fixes are recommendations. The owner makes the final decision before applying changes.
