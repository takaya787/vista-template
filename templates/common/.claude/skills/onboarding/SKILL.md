---
name: onboarding
description:
  Task-driven onboarding that personalizes Claude Code by doing real work together.
  Triggers automatically when .vista/state/onboarding.json has status "pending".
  Also triggers on "/onboarding", "run onboarding", "set up my profile",
  "configure my preferences". Can be re-run anytime to discover new tasks.
---

# Onboarding

Task-driven onboarding that personalizes the Claude Code environment by working on a real task with the owner. Instead of collecting settings upfront, configuration emerges as a byproduct of doing actual work together.

## Design Principles

1. **Value in 10 minutes** — The owner should accomplish something useful in the first session. If a task risks exceeding this window, simplify scope rather than abandon it.
2. **3 questions max** — Profile setup asks only name, language, and output format
3. **Config is a byproduct** — Settings are discovered through task execution, not questionnaires
4. **No completion state** — Onboarding is never "done"; each session can discover new tasks and refine config

## Data Sources

- `.vista/state/onboarding.json` — Onboarding state and discovered tasks
- `.vista/profile/me.json` — Symlink to `~/.vista/profile/me.json` (global owner profile)
- `.vista/profile/project.json` — Per-project context (read-only here; set up via `/onboarding-project`)
- `references/interview-protocol.md` — Profile questions and rendering notes
- `references/interview-protocol.json` — Structured question definitions (all phases)
- `references/task-discovery-guide.md` — Task discovery conversation guide
- `references/config-generation-guide.md` — Config generation rules and schemas

## Tone & Style

The owner is likely an AI beginner using Claude Code for the first time. Adopt this interaction style throughout onboarding:

- **Plain, friendly language** — Avoid technical terms (CLI, config, JSON, schema, git). When referencing system actions, describe the effect, not the mechanism (say "I'll remember your preference" not "Writing to me.json").
- **Warm and patient** — Celebrate small wins ("Great, that's your first task done!"). Never rush the owner or assume prior knowledge.
- **Owner's language** — Before language preference is set, default to the language specified in `rules/convention/output-language.md`. Once the owner selects their preference in Step 2, switch immediately. Do not wait until the next session.

## Input Method: AskUserQuestion

All user input MUST be collected via the `AskUserQuestion` tool.

### Constraints

- **1-4 questions per call** — Group related questions into a single batch
- **2-4 options per question** — "Other" is automatically appended by the tool
- **Recommended option** — Place the recommended/default option first with "(Recommended)" suffix

## Steps

### Step 1: Welcome + Detect State

1. **Greet the owner** with a warm welcome message before doing anything else:

   > Hi! I'm Claude, your AI work assistant. Let's spend about 10 minutes getting to know how you work — I'll ask a few quick questions, then we'll tackle a real task together. Let me check a few things about your setup first...

2. Read `.vista/state/onboarding.json` to determine current status
3. Read `.vista/profile/me.json` (symlink → `~/.vista/profile/me.json`) to identify already-filled vs empty fields
   - If the symlink is broken or `~/.vista/profile/me.json` does not exist, treat as `"pending"` and ask the owner to re-run setup
4. Auto-detect values (do NOT prompt the owner for these):
   - **Name:** `git config user.name`
   - **Email:** `git config user.email`
   - **Timezone:** System timezone (on macOS: `systemsetup -gettimezone` or parse `ls -l /etc/localtime`; on Linux: `timedatectl` or `cat /etc/timezone`)
5. Route based on state:
   - `onboarding.json` missing or `status: "pending"` AND global profile has no `name` → proceed to Step 2 (full onboarding)
   - `onboarding.json` missing or `status: "pending"` AND global profile already has `name` → profile exists from another project; skip Step 2 and go to Step 3
   - `status: "active"` AND `me.json` has all required fields → skip to Step 3 (prioritize `pendingTasks`)
   - `status: "active"` AND `me.json` missing or incomplete → re-collect missing profile fields (Step 2), then proceed to Step 3
   - `.vista/` directory exists but `onboarding.json` missing → state may have been reset; suggest re-running onboarding
   - `onboarding.json` exists but is malformed → treat as `"pending"`, log a warning
   - Re-run triggered by user on active environment → follow Re-run Policy in `rules/convention/onboarding.md`

6. Present auto-detected values for confirmation:

   > I detected the following — let me know if anything needs correction:
   >
   > - Email: `{detected}`
   > - Timezone: `{detected}`

   If the owner flags a value as incorrect, ask for the correct value conversationally (free-text). Update `me.json` with the corrected value.

### Step 2: Minimal Profile

Collect the owner's profile in two steps. See `references/interview-protocol.md` for exact question definitions. Create `.vista/profile/` directory if it does not exist.

**Step 2a: Name confirmation**

- If `git config user.name` returned a value, confirm it conversationally: "I found your name: {name}. Should I use this, or would you prefer something different?" This avoids the AskUserQuestion tool constraint tension for a simple confirmation.
- If the owner wants a different name, ask: "What should I call you?"
- If detection failed, ask conversationally: "What should I call you?"

See `references/interview-protocol.md` Q1 for full details.

**Step 2b: Language + Format (single AskUserQuestion call)**

Collect 2 questions in one call:

1. **Output language** (Japanese / English / Bilingual)
2. **Output format** (bullets / prose / tables / mixed)

Write the profile to `.vista/profile/me.json` immediately after collection.

**Transition message** after profile is saved:

> Nice to meet you, {name}! Your profile is all set. Now let's find something useful to work on together.

If `.vista/profile/project.json` does not exist, also suggest:

> For even better assistance, you can run `/onboarding-project` to set up your project context — this helps me understand your team, company, and current work.

### Step 3: Task Discovery

Transition to task discovery. See `references/task-discovery-guide.md` for the full guide.

1. Ask the opening question as defined in `references/task-discovery-guide.md` (use `AskUserQuestion` with the structured options)
2. After the owner responds, infer as many of the 5 dimensions as possible from their answer
3. If critical dimensions (What, Input, Output) remain unclear, ask exactly 1 follow-up question targeting the most ambiguous dimension. Infer the rest. **The 1-question limit is absolute** — it takes priority over dimension coverage.
4. Confirm the task scope using the confirmation format defined in `references/task-discovery-guide.md`

**Transition message** after task confirmation (merge with mid-task exit note from Step 4):

> Got it — let's do this. You can say 'let's stop here' anytime. I'll start by [first action] and show you a draft.

### Step 4: Do the Task Together

Execute the discovered task collaboratively with the owner.

**Execution approach:**

- Announce what you will do first so the owner knows what to expect
- Produce a first draft or partial result quickly (aim for under 2 minutes)
- Show the draft to the owner and ask for feedback before refining
- Iterate based on feedback — expect 1-2 rounds of revision

**Scope management:**

- If the task is too complex for the 10-minute onboarding window, simplify scope: "This is a big task — let's start with [smaller piece] today and save the rest for next time."
- Completing a small task is always better than starting a large one

**Mid-task exit:**

- The owner can stop at any point. If they say "stop", "let's stop here", or similar, save progress gracefully and move to Step 6.
- Mention the exit option in the transition message (e.g., "Got it — let's do this. You can say 'let's stop here' anytime. I'll start by [first action] and show you a draft.")
- When saving progress: record the task description and any partial output to `onboarding.json` → `pendingTasks` with context, so it can be resumed in a future session.

**Constraints:**

- Use the owner's preferred output format and language from `me.json`
- When the task requires information not in the profile, ask for it just-in-time
- When the task requires data or service access you cannot reach, ask the owner to provide the data directly — do not fabricate or simulate it
- When the task references external services, follow service detection rules in `references/config-generation-guide.md`
- Follow `rules/convention/guardrails.md` for all data handling (no fabrication, source traceability, draft principle)

### Step 5: Extract & Save Config

After task completion, extract configuration learned during execution. See `references/config-generation-guide.md` for detailed rules.

**Present the changeset in plain language, not file paths:**

Frame it as "Here's what I learned from our session" with natural language bullets. The owner confirms the _meaning_, not the _storage locations_. File operations happen silently after confirmation.

Example:

> Based on our work together, I picked up the following:
>
> - You prefer concise bullet-point outputs in Japanese
> - You create a weekly marketing report from Google Sheets every Monday
> - Your team reviews reports via Slack
>
> I'll save these so I remember next time. Anything I should change?

For the role definition, present it naturally: "I'd describe my role as: 'An assistant helping you with weekly progress reports.' Does that feel right?"

**Write sequence** (after owner confirms):

See `references/config-generation-guide.md` for detailed write rules. Create any missing directories before writing. If a write fails, log a warning and continue with remaining writes.

1. `.vista/profile/me.json` — any new fields discovered (writes persist globally via symlink to `~/.vista/profile/me.json`)
2. `rules/config/` — any service-specific config generated
3. `CLAUDE.md` — apply profile to project's CLAUDE.md per the "Applying Profile to CLAUDE.md" policy in `rules/convention/onboarding.md`
4. `.vista/state/onboarding.json` — update last (confirms successful write)

### Step 6: Offer Next Steps

1. Record any additional tasks the owner mentioned but did not execute into `onboarding.json` → `pendingTasks`
2. Provide a brief value summary: "You just created [deliverable] in [time]. Next time, this should be even faster since I know your preferences."
3. Suggest: "Want to tackle another task, or is this good for now?"
4. If the owner declines, summarize what was learned (in plain language, not technical terms) and provide practical next-step guidance:
   > You can ask me anything — just type naturally. For example, "help me draft a status update" or "summarize this data." No special commands needed. You can also run `/onboarding` anytime to discover new tasks.

## Re-run Behavior

For re-run behavior on an already-active environment, follow the Re-run Policy defined in `rules/convention/onboarding.md`.

When displaying maturity level to the owner, use plain language instead of internal labels:

- `seed` → "just getting started"
- `growing` → "well-configured"
- `established` → "fully set up"
