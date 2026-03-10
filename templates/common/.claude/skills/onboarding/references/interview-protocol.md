# Interview Protocol — Role-Specific Question Bank

Reference document for the onboarding skill. Contains the full set of questions organized by category and role, with skip defaults and configuration targets.

## Table of Contents

1. [Core Profile Questions](#core-profile-questions)
2. [Working Style Questions](#working-style-questions)
3. [Role-Specific Questions](#role-specific-questions)
   - [scrum-master](#scrum-master)
   - [marketing](#marketing)
   - [engineer](#engineer)
   - [product-manager](#product-manager)
   - [designer](#designer)
   - [investor-relations](#investor-relations)

---

## Core Profile Questions

All roles share these questions. Ask in order.

### CP-1: Name

- **Question:** "What should I call you?"
- **Purpose:** Personalize all interactions
- **Target:** `.vista/profile/me.json` → `name`
- **Skip default:** Use system username (`whoami`)

### CP-2: Position / Title

- **Question:** "What's your current role or title?"
- **Purpose:** Tailor communication style and task suggestions
- **Target:** `.vista/profile/me.json` → `position`
- **Skip default:** Infer from role argument (e.g., "Scrum Master" for scrum-master)

### CP-3: Team

- **Question:** "Which team or department are you on?"
- **Purpose:** Context for team-related features
- **Target:** `.vista/profile/me.json` → `team`
- **Skip default:** `null` (omit from me.json)

### CP-4: Email

- **Question:** "What's your work email? (used for commit attribution, etc.)"
- **Purpose:** Git config, notifications
- **Target:** `.vista/profile/me.json` → `email`
- **Skip default:** Auto-detect from `git config user.email`

### CP-5: Slack ID

- **Question:** "What's your Slack member ID? (You can find it in your Slack profile → '...' → 'Copy member ID')"
- **Purpose:** Mention formatting in reports
- **Target:** `.vista/profile/me.json` → `slackId`
- **Skip default:** `null` (omit from me.json)

### CP-6: Tech Stack (technical roles only)

- **Applies to:** engineer, designer, product-manager
- **Question:** "What are your primary technologies? (e.g., TypeScript, React, Python)"
- **Purpose:** Tailor code suggestions and review style
- **Target:** `.vista/profile/me.json` → `techStack`
- **Skip default:** `[]`

### CP-7: Focus Areas (technical roles only)

- **Applies to:** engineer, designer, product-manager
- **Question:** "What are you currently focused on? (e.g., API improvements, performance)"
- **Purpose:** Prioritize relevant suggestions
- **Target:** `.vista/profile/me.json` → `focusAreas`
- **Skip default:** `[]`

---

## Working Style Questions

All roles share these questions.

### WS-1: Communication Style

- **Question:** "How do you prefer to communicate with your team? (e.g., async Slack, real-time huddles, email)"
- **Purpose:** Match AI communication recommendations
- **Target:** `.vista/profile/me.json` → `workingStyle.communication`
- **Skip default:** `"Slack async-first"`

### WS-2: Working Hours

- **Question:** "What are your typical working hours? (e.g., 10:00-19:00)"
- **Purpose:** Schedule-aware suggestions
- **Target:** `.vista/profile/me.json` → `workingStyle.workingHours`
- **Skip default:** `"09:00-18:00"`

### WS-3: Timezone

- **Question:** "What timezone are you in?"
- **Purpose:** Time calculations, deadline awareness
- **Target:** `.vista/profile/me.json` → `workingStyle.timezone`
- **Auto-detect:** Use system timezone. Confirm: "I detected your timezone as {tz}. Is that correct?"
- **Skip default:** System timezone

### WS-4: Output Language

- **Question:** "Which language should I use for reports and communication? (default: Japanese)"
- **Purpose:** Set output language preference
- **Target:** `.vista/profile/me.json` → `preferences.language`
- **Skip default:** `"ja"`

### WS-5: Output Format

- **Question:** "Do you prefer concise bullet points or detailed prose for reports?"
- **Purpose:** Match output style to preference
- **Target:** `.vista/profile/me.json` → `preferences.outputFormat`
- **Skip default:** `"Concise bullet points"`

### WS-6: Notes

- **Question:** "Anything else I should know about how you work? (e.g., 'Friday afternoons are review focus time')"
- **Purpose:** Catch-all for personal workflow context
- **Target:** `.vista/profile/me.json` → `notes`
- **Skip default:** `null` (omit from me.json)

---

## Role-Specific Questions

### scrum-master

#### SM-1: Sprint Duration

- **Question:** "How long are your sprints? (e.g., 1 week, 2 weeks)"
- **Purpose:** Sprint calculation and planning skill
- **Target:** `rules/config/sprint-settings.md` → Duration
- **Skip default:** `"1 week"` (template default)

#### SM-2: Sprint Start Day

- **Question:** "What day do your sprints start?"
- **Purpose:** Sprint boundary calculations
- **Target:** `rules/config/sprint-settings.md` → Start day
- **Skip default:** `"Monday"` (template default)

#### SM-3: Notion Pages

- **Question:** "Do you use Notion for standup or sprint tracking? If so, what are the page URLs?"
- **Purpose:** Notion integration for planning skill
- **Target:** `rules/config/notion-pages.md` → Page URLs
- **Skip default:** Leave as placeholder

#### SM-4: Reporting Frequency

- **Question:** "How often do you want status reports? (e.g., daily standup, weekly)"
- **Purpose:** Proactive report scheduling in memory
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Weekly"`

---

### marketing

#### MK-1: Active Channels

- **Question:** "Which advertising/marketing channels are you currently active on? (e.g., Google Ads, Meta Ads, SEO, Email)"
- **Purpose:** Configure channel checklist
- **Target:** `rules/config/channels.md` → Paid/Owned checkboxes
- **Skip default:** Leave all unchecked

#### MK-2: Analytics Tool

- **Question:** "What's your primary analytics tool? (e.g., GA4, Mixpanel)"
- **Purpose:** Data source conventions
- **Target:** `rules/config/channels.md` → Analytics → Primary tool
- **Skip default:** `"GA4"`

#### MK-3: Data Warehouse

- **Question:** "Do you use a data warehouse? (e.g., BigQuery, None)"
- **Purpose:** Data pipeline configuration
- **Target:** `rules/config/channels.md` → Analytics → Data warehouse
- **Skip default:** `"None"`

#### MK-4: Report Sharing

- **Question:** "Where do you share reports? (Notion / Google Sheets / Markdown only)"
- **Purpose:** Output format for reports
- **Target:** `rules/config/integrations.md` → Report Sharing → Primary
- **Skip default:** `"markdown-only"`

#### MK-5: Notion Pages

- **Question:** "If using Notion, what are your report page URLs?"
- **Condition:** Only ask if MK-4 answer includes Notion
- **Purpose:** Notion integration
- **Target:** `rules/config/integrations.md` → Notion section
- **Skip default:** Leave as placeholder

#### MK-6: Google Sheets

- **Question:** "If using Google Sheets, what are your Sheet IDs?"
- **Condition:** Only ask if MK-4 answer includes Sheets
- **Purpose:** Sheets integration
- **Target:** `rules/config/integrations.md` → Google Sheets section
- **Skip default:** Leave as placeholder

---

### engineer

#### EN-1: Code Review Style

- **Question:** "How do you prefer code reviews? (e.g., thorough line-by-line, high-level architecture focus, quick sanity check)"
- **Purpose:** Tailor review assistance
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Thorough"`

#### EN-2: Documentation Preference

- **Question:** "How much documentation do you like? (e.g., minimal inline comments, detailed docstrings, ADRs for decisions)"
- **Purpose:** Match documentation output
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Minimal — only where logic isn't self-evident"`

#### EN-3: Testing Approach

- **Question:** "What's your testing philosophy? (e.g., TDD, write tests after, integration-first)"
- **Purpose:** Align test generation behavior
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Write tests after implementation"`

#### EN-4: Branch Strategy

- **Question:** "What branching strategy does your team use? (e.g., GitHub Flow, Git Flow, trunk-based)"
- **Purpose:** Git workflow alignment
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"GitHub Flow"`

---

### product-manager

#### PM-1: Prioritization Framework

- **Question:** "What prioritization framework do you use? (e.g., RICE, MoSCoW, Impact/Effort)"
- **Purpose:** Align task prioritization suggestions
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `"Impact/Effort"`

#### PM-2: Stakeholder Communication

- **Question:** "How do you share updates with stakeholders? (e.g., weekly email, Notion page, Slack channel)"
- **Purpose:** Output format for status updates
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Slack channel"`

---

### designer

#### DS-1: Design Tools

- **Question:** "What design tools do you use? (e.g., Figma, Sketch, Adobe XD)"
- **Purpose:** Asset and handoff conventions
- **Target:** `.vista/profile/me.json` → `techStack`
- **Skip default:** `["Figma"]`

#### DS-2: Design System

- **Question:** "Does your team have a design system or component library?"
- **Purpose:** Reference for consistency checks
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `null`

---

### investor-relations

#### IR-1: Reporting Cadence

- **Question:** "What's your IR reporting cadence? (e.g., quarterly, monthly)"
- **Purpose:** Schedule-aware report generation
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Quarterly"`

#### IR-2: KPI Framework

- **Question:** "What are your primary KPIs? (e.g., ARR, MRR, CAC, LTV)"
- **Purpose:** Focus report generation on relevant metrics
- **Target:** `memory/MEMORY.md` → Owner Preferences
- **Skip default:** `null` (ask again in future session)
