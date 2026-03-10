# Interview Protocol — AskUserQuestion Batches

Reference document for the onboarding skill. Defines question batches formatted for the `AskUserQuestion` tool. Each batch contains 1-4 questions with 2-4 options each. "Other" is automatically appended by the tool for free-text input.

## Table of Contents

1. [Auto-Detected Fields](#auto-detected-fields)
2. [Batch 1: Core Profile](#batch-1-core-profile)
3. [Batch 2: Working Style](#batch-2-working-style)
4. [Batch 3: Role-Specific](#batch-3-role-specific)
   - [scrum-master](#scrum-master)
   - [marketing](#marketing)
   - [engineer](#engineer)
   - [product-manager](#product-manager)
   - [designer](#designer)
   - [investor-relations](#investor-relations)

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
  2. `{ label: "Software Engineer", description: "Development, code review, architecture" }`
  3. `{ label: "Product Manager", description: "Roadmap, prioritization, stakeholder management" }`
  4. `{ label: "Marketing Manager", description: "Campaigns, analytics, content strategy" }`
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

- **Applies to:** engineer, designer, product-manager
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

## Batch 3: Role-Specific

Present role-specific questions based on `.vista/state/setup.json` → `role`.

### scrum-master

Single `AskUserQuestion` call (3 questions).

#### SM-Q1: Sprint Duration

- **header:** "Sprint"
- **question:** "How long are your sprints?"
- **multiSelect:** false
- **options:**
  1. `{ label: "1 week (Recommended)", description: "Short iterations, fast feedback" }`
  2. `{ label: "2 weeks", description: "Standard agile sprint length" }`
  3. `{ label: "3 weeks", description: "Longer sprints for larger deliverables" }`
- **Target:** `rules/config/sprint-settings.md` → Duration
- **Skip default:** `"1 week"`

#### SM-Q2: Sprint Start Day

- **header:** "Start day"
- **question:** "What day do your sprints start?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Monday (Recommended)", description: "Start of business week" }`
  2. `{ label: "Tuesday", description: "Day after Monday sync" }`
  3. `{ label: "Wednesday", description: "Mid-week start" }`
- **Target:** `rules/config/sprint-settings.md` → Start day
- **Skip default:** `"Monday"`

#### SM-Q3: Reporting Frequency

- **header:** "Reports"
- **question:** "How often do you want status reports?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Weekly (Recommended)", description: "End-of-week summary" }`
  2. `{ label: "Daily standup", description: "Daily progress updates" }`
  3. `{ label: "Per sprint", description: "Report at sprint boundaries only" }`
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Weekly"`

#### SM-Free: Notion Pages

After the batch above, ask via follow-up message (not AskUserQuestion — URLs are free-text):
> "Do you use Notion for standup or sprint tracking? If so, paste the page URLs."

- **Target:** `rules/config/notion-pages.md` → Page URLs
- **Skip default:** Leave as placeholder

---

### marketing

First `AskUserQuestion` call (2 questions).

#### MK-Q1: Active Channels

- **header:** "Channels"
- **question:** "Which marketing channels are you currently active on?"
- **multiSelect:** true
- **options:**
  1. `{ label: "Google Search Ads", description: "Paid search campaigns" }`
  2. `{ label: "Meta Ads", description: "Facebook / Instagram advertising" }`
  3. `{ label: "SEO / Blog", description: "Organic content and search optimization" }`
  4. `{ label: "Email Newsletter", description: "Email marketing campaigns" }`
- **Target:** `rules/config/channels.md` → Paid/Owned checkboxes
- **Skip default:** Leave all unchecked

#### MK-Q2: Report Sharing

- **header:** "Sharing"
- **question:** "Where do you share marketing reports?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Markdown only (Recommended)", description: "Keep reports as local markdown files" }`
  2. `{ label: "Notion", description: "Publish reports to Notion pages" }`
  3. `{ label: "Google Sheets", description: "Export KPIs to spreadsheets" }`
- **Target:** `rules/config/integrations.md` → Report Sharing → Primary
- **Skip default:** `"markdown-only"`

Second `AskUserQuestion` call (2 questions).

#### MK-Q3: Analytics Tool

- **header:** "Analytics"
- **question:** "What's your primary analytics tool?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GA4 (Recommended)", description: "Google Analytics 4" }`
  2. `{ label: "Mixpanel", description: "Product analytics platform" }`
  3. `{ label: "Adobe Analytics", description: "Enterprise analytics suite" }`
- **Target:** `rules/config/channels.md` → Analytics → Primary tool
- **Skip default:** `"GA4"`

#### MK-Q4: Data Warehouse

- **header:** "Warehouse"
- **question:** "Do you use a data warehouse?"
- **multiSelect:** false
- **options:**
  1. `{ label: "None (Recommended)", description: "No data warehouse — work from CSV exports" }`
  2. `{ label: "BigQuery", description: "Google BigQuery" }`
  3. `{ label: "Snowflake", description: "Snowflake Data Cloud" }`
- **Target:** `rules/config/channels.md` → Analytics → Data warehouse
- **Skip default:** `"None"`

#### MK-Free: Notion / Sheets URLs

If MK-Q2 selected Notion or Google Sheets, ask via follow-up message:
> "Please paste your {Notion page URLs / Google Sheet IDs}."

- **Target:** `rules/config/integrations.md` → Notion / Google Sheets sections
- **Skip default:** Leave as placeholder

---

### engineer

Single `AskUserQuestion` call (4 questions).

#### EN-Q1: Code Review Style

- **header:** "Review"
- **question:** "How do you prefer code reviews?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Thorough (Recommended)", description: "Line-by-line review with detailed feedback" }`
  2. `{ label: "Architecture focus", description: "High-level design and pattern review" }`
  3. `{ label: "Quick sanity check", description: "Fast pass for obvious issues only" }`
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Thorough"`

#### EN-Q2: Documentation Preference

- **header:** "Docs"
- **question:** "How much documentation do you prefer?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Minimal (Recommended)", description: "Comments only where logic isn't self-evident" }`
  2. `{ label: "Detailed docstrings", description: "Full documentation on public APIs and functions" }`
  3. `{ label: "ADRs for decisions", description: "Architecture Decision Records for major choices" }`
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Minimal — only where logic isn't self-evident"`

#### EN-Q3: Testing Approach

- **header:** "Testing"
- **question:** "What's your testing approach?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Tests after (Recommended)", description: "Write tests after implementation" }`
  2. `{ label: "TDD", description: "Test-driven development — tests first" }`
  3. `{ label: "Integration-first", description: "Focus on integration and E2E tests" }`
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Write tests after implementation"`

#### EN-Q4: Branch Strategy

- **header:** "Branching"
- **question:** "What branching strategy does your team use?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GitHub Flow (Recommended)", description: "Feature branches + PRs to main" }`
  2. `{ label: "Git Flow", description: "develop/release/hotfix branches" }`
  3. `{ label: "Trunk-based", description: "Short-lived branches, frequent merges to main" }`
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"GitHub Flow"`

---

### product-manager

Single `AskUserQuestion` call (2 questions).

#### PM-Q1: Prioritization Framework

- **header:** "Priority"
- **question:** "What prioritization framework do you use?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Impact/Effort (Recommended)", description: "2x2 matrix of impact vs effort" }`
  2. `{ label: "RICE", description: "Reach, Impact, Confidence, Effort scoring" }`
  3. `{ label: "MoSCoW", description: "Must/Should/Could/Won't categorization" }`
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Impact/Effort"`

#### PM-Q2: Stakeholder Communication

- **header:** "Updates"
- **question:** "How do you share updates with stakeholders?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Slack channel (Recommended)", description: "Post updates to a dedicated channel" }`
  2. `{ label: "Weekly email", description: "Scheduled email digest" }`
  3. `{ label: "Notion page", description: "Living document updated regularly" }`
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Slack channel"`

---

### designer

Single `AskUserQuestion` call (2 questions).

#### DS-Q1: Design Tools

- **header:** "Tools"
- **question:** "What design tools do you use?"
- **multiSelect:** true
- **options:**
  1. `{ label: "Figma (Recommended)", description: "Collaborative interface design" }`
  2. `{ label: "Sketch", description: "macOS design tool" }`
  3. `{ label: "Adobe XD", description: "Adobe prototyping tool" }`
  4. `{ label: "Canva", description: "Quick visual design" }`
- **Target:** `.vista/profile/me.json` → `techStack`
- **Skip default:** `["Figma"]`

#### DS-Q2: Design System

- **header:** "System"
- **question:** "Does your team have a design system or component library?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Yes — documented", description: "Maintained design system with documentation" }`
  2. `{ label: "Yes — informal", description: "Shared components but not fully documented" }`
  3. `{ label: "No", description: "No shared design system yet" }`
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `null`

---

### investor-relations

Single `AskUserQuestion` call (2 questions).

#### IR-Q1: Reporting Cadence

- **header:** "Cadence"
- **question:** "What's your IR reporting cadence?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Quarterly (Recommended)", description: "Standard quarterly reporting cycle" }`
  2. `{ label: "Monthly", description: "Monthly investor updates" }`
  3. `{ label: "Semi-annual", description: "Twice a year reporting" }`
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Quarterly"`

#### IR-Q2: KPI Framework

- **header:** "KPIs"
- **question:** "What are your primary KPIs?"
- **multiSelect:** true
- **options:**
  1. `{ label: "ARR / MRR", description: "Revenue metrics" }`
  2. `{ label: "CAC / LTV", description: "Customer acquisition and lifetime value" }`
  3. `{ label: "Churn / NRR", description: "Retention metrics" }`
  4. `{ label: "Burn rate / Runway", description: "Cash flow metrics" }`
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `null` (ask again in future session)
