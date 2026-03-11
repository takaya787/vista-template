# Interview Protocol — AskUserQuestion Batches

Reference document for the onboarding skill. Defines question batches formatted for the `AskUserQuestion` tool. Each batch contains 1-4 questions with 2-4 options each. "Other" is automatically appended by the tool for free-text input.

## Table of Contents

1. [Auto-Detected Fields](#auto-detected-fields)
2. [Batch 1: Core Profile](#batch-1-core-profile)
3. [Batch 2: Working Style](#batch-2-working-style)
4. [Role-Specific Interview Files](#role-specific-interview-files)

---

## Auto-Detected Fields

These fields are auto-detected and presented for confirmation (not via AskUserQuestion). If detection fails, ask via follow-up message.

| Field | Detection Method | Target |
|-------|-----------------|--------|
| GitHub username | `gh api user --jq '.login'` | `.vista/profile/me.json` → `github` |
| Email | `git config user.email` | `.vista/profile/me.json` → `email` |
| Timezone | System timezone (set by setup.sh) | `.vista/profile/me.json` → `workingStyle.timezone` |

---

## Batch 1: Core Profile

All roles. Present as a single `AskUserQuestion` call.

### Q1: Position / Title

- **header:** "Position"
- **question:** "What's your current role or title?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Scrum Master", description: "Agile team facilitation and sprint management" }`
  2. `{ label: "Product Manager", description: "Roadmap, prioritization, stakeholder management" }`
  3. `{ label: "Marketing Manager", description: "Campaigns, analytics, content strategy" }`
- **Target:** `.vista/profile/me.json` → `position`
- **Skip default:** Infer from role argument (e.g., "Scrum Master" for scrum-master)

### Q2: Team

- **header:** "Team"
- **question:** "Which team or department are you on?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Engineering", description: "Software development team" }`
  2. `{ label: "Product", description: "Product management and design" }`
  3. `{ label: "Marketing", description: "Growth, content, and brand" }`
  4. `{ label: "Operations", description: "Business operations and support" }`
- **Target:** `.vista/profile/me.json` → `team`
- **Skip default:** `null`

### Q3: Tech Stack (technical roles only)

- **Applies to:** designer, product-manager
- **header:** "Tech Stack"
- **question:** "What are your primary technologies?"
- **multiSelect:** true
- **options:**
  1. `{ label: "TypeScript / JavaScript", description: "Frontend and backend JS ecosystem" }`
  2. `{ label: "Python", description: "Backend, data science, scripting" }`
  3. `{ label: "React / Next.js", description: "Frontend framework" }`
  4. `{ label: "Go / Rust", description: "Systems and backend" }`
- **Target:** `.vista/profile/me.json` → `techStack`
- **Skip default:** `[]`

---

## Batch 2: Working Style

All roles. Present as a single `AskUserQuestion` call (3 questions).

### Q1: Communication Style

- **header:** "Comms"
- **question:** "How do you prefer to communicate with your team?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Async Slack (Recommended)", description: "Slack messages, respond when available" }`
  2. `{ label: "Real-time huddles", description: "Quick voice/video calls for discussions" }`
  3. `{ label: "Email", description: "Formal written communication" }`
  4. `{ label: "Mixed", description: "Slack for quick items, huddles for complex topics" }`
- **Target:** `.vista/profile/me.json` → `workingStyle.communication`
- **Skip default:** `"Slack async-first"`

### Q2: Output Language

- **header:** "Language"
- **question:** "Which language should I use for reports and communication?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Japanese (Recommended)", description: "日本語で出力" }`
  2. `{ label: "English", description: "Output in English" }`
  3. `{ label: "Bilingual", description: "Use both depending on context" }`
- **Target:** `.vista/profile/me.json` → `preferences.language`
- **Skip default:** `"ja"`

### Q3: Output Format

- **header:** "Format"
- **question:** "How do you prefer reports and outputs to be formatted?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Concise bullets (Recommended)", description: "Short, scannable bullet points" }`
  2. `{ label: "Detailed prose", description: "Full explanatory paragraphs" }`
  3. `{ label: "Tables & data", description: "Structured tables with metrics" }`
  4. `{ label: "Mixed", description: "Bullets for summaries, detail for analysis" }`
- **Target:** `.vista/profile/me.json` → `preferences.outputFormat`
- **Skip default:** `"Concise bullet points"`

---

## Role-Specific Interview Files

Role-specific questions (formerly Batch 3) are maintained in separate files per role. Load the appropriate file based on `.vista/state/setup.json` → `role`.

| Role | File |
|------|------|
| scrum-master | `references/scrum-master-interview.md` |
| marketing | `references/marketing-interview.md` |
| product-manager | `references/product-manager-interview.md` |
| designer | `references/designer-interview.md` |
| investor-relations | `references/investor-relations-interview.md` |
