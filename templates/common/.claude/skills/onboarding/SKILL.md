---
name: onboarding
description:
  Minimal onboarding that personalizes Claude Code with 3 questions + a first task.
  Triggers automatically when .vista/state/onboarding.json has status "pending".
  Also triggers on "/onboarding", "run onboarding", "set up my profile",
  "configure my preferences". Can be re-run anytime to discover new tasks.
---

# Onboarding

Minimal onboarding that gets the owner productive in under 3 minutes. Collects only essential preferences (language, format, autonomy), then jumps straight into a real task. Workflow automation is built separately via `/workflow-create`.

## Design Principles

1. **3 minutes to value** — Profile setup is 3 questions. Then do real work immediately.
2. **Config is a byproduct** — Settings are discovered through task execution, not questionnaires
3. **Workflows are separate** — After the first task, suggest `/workflow-create` to automate recurring work
4. **No completion state** — Onboarding is never "done"; each session can discover new tasks

## Data Sources

- `.vista/state/onboarding.json` — Onboarding state and discovered tasks
- `.vista/profile/me.json` — Symlink to `~/.vista/profile/me.json` (global owner profile)
- `references/interview-protocol.json` — Structured question definitions (2 phases only)
- `references/task-discovery-guide.md` — Task discovery conversation guide
- `references/config-generation-guide.md` — Config generation rules

## Tone & Style

The owner is likely an AI beginner using Claude Code for the first time:

- **Plain, friendly language** — Avoid technical terms (CLI, config, JSON, schema, git). Say "I'll remember your preference" not "Writing to me.json".
- **Warm and patient** — Celebrate small wins. Never rush the owner.
- **Owner's language** — Default to language in `rules/convention/output-language.md`. Once set in Step 2, switch immediately.

## Input Method: AskUserQuestion

All user input MUST be collected via the `AskUserQuestion` tool.

### Constraints

- **1-4 questions per call** — Group related questions into a single batch
- **2-4 options per question** — "Other" is automatically appended by the tool

## Steps

### Step 1: Welcome + Detect State

1. **Greet the owner** before doing anything else:

   > Hi! I'm Claude, your AI assistant. Let's spend about 3 minutes setting up, then we'll tackle a real task together.

2. Read `.vista/state/onboarding.json` to determine current status
3. Read `.vista/profile/me.json` (symlink → `~/.vista/profile/me.json`)
4. Auto-detect values (do NOT prompt for these):
   - **Name:** `git config user.name`
   - **Email:** `git config user.email`
   - **Timezone:** System timezone
5. Route based on state:
   - `status: "pending"` AND no `name` in profile → proceed to Step 2
   - `status: "pending"` AND `name` exists → skip Step 2, go to Step 3
   - `status: "active"` AND profile complete → skip to Step 3 (prioritize `pendingTasks`)
   - `status: "active"` AND profile incomplete → re-collect missing fields, then Step 3
   - Re-run by user on active environment → follow Re-run Policy in `rules/convention/onboarding.md`

6. Present auto-detected values for confirmation:

   > I detected the following — let me know if anything needs correction:
   > - Email: `{detected}`
   > - Timezone: `{detected}`

### Step 2: Minimal Profile (3 questions)

Collect in a single `AskUserQuestion` call with 3 questions:

1. **Output language** (Japanese / English / Bilingual)
2. **Output format** (bullets / prose / tables / mixed)
3. **Autonomy** (guided / balanced / autonomous)

**Name confirmation:** If `git config user.name` returned a value, confirm conversationally. If not, ask.

Write to `.vista/profile/me.json` immediately after collection.

**Transition message:**

> Nice to meet you, {name}! Your profile is all set. Now let's find something useful to work on.

### Step 3: Task Discovery

See `references/task-discovery-guide.md` for the full guide.

1. Ask the opening question (use `AskUserQuestion` with structured options)
2. After the owner responds, infer task dimensions from their answer
3. If critical dimensions (What, Input, Output) remain unclear, ask exactly **1 follow-up**
4. Confirm the task scope

**Transition message:**

> Got it — let's do this. You can say 'let's stop here' anytime.

### Step 4: Do the Task Together

Execute the discovered task collaboratively.

- Announce what you will do first
- Produce a first draft quickly (under 2 minutes)
- Show the draft and ask for feedback
- Iterate 1-2 rounds

**Scope management:** If too complex, simplify: "Let's start with [smaller piece] today."

**Mid-task exit:** If the owner says "stop", save progress to `onboarding.json` → `pendingTasks`.

**Constraints:**
- Use owner's preferred format and language from `me.json`
- Follow `rules/convention/guardrails.md` for all data handling

### Step 5: Save & Suggest Workflow

After task completion:

1. **Save any learned preferences** to `me.json` (only fields that emerged naturally)
2. **Present what was learned** in plain language:

   > Based on our work together, I picked up the following:
   > - You prefer concise outputs with headers
   > - You work with CSV data in the data/ folder
   >
   > I'll remember these for next time.

3. **Bridge to workflow creation:**

   > This task seems like something you do regularly. Want to save it as an automated workflow so next time you can just say "run weekly report"?
   >
   > You can do this anytime with `/workflow-create`.

4. Update `.vista/state/onboarding.json` — set `status: "active"`

### Step 6: Offer Next Steps

1. Record any additional tasks into `onboarding.json` → `pendingTasks`
2. Brief value summary: "You just created [deliverable]. Next time this should be even faster."
3. Suggest: "Want to tackle another task, or is this good for now?"
4. If done:
   > You can ask me anything — just type naturally. To automate recurring tasks, try `/workflow-create`.

## Re-run Behavior

Follow Re-run Policy in `rules/convention/onboarding.md`.

Display maturity in plain language:
- `seed` → "just getting started"
- `growing` → "well-configured"
- `established` → "fully set up"
