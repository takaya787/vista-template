# PRD Interview Forms

Defines the fixed interview forms and PRD output format.
Present Form 1–5 one at a time in order, then map answers to the PRD Format section to generate the PRD.
**Translate all questions and examples into the user's language before presenting.**

Display format:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Form N / 5 — {form name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Q1. ...
Q2. ...
Q3. ...
(Leave any item blank to skip it)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Form 1 / 5 — Basic Information

```
Q1. Describe the task you want to automate in one short phrase.
    e.g. "Send weekly sales report to Slack", "Check competitor prices daily"

Q2. What is the goal? (1–2 sentences is fine)
    e.g. "I want to automatically post the Excel report I compile manually each week to Slack"

Q3. Who is currently doing this task?
    e.g. Me, a team member, an external contractor

Q4. How often does it happen, and how long does it take?
    e.g. Every Monday, about 30 minutes; daily, about 10 minutes
```

→ Used in PRD `<context> # Overview` and `# Current State`

---

## Form 2 / 5 — Execution Flow

```
Q1. What triggers the automation?
    e.g. Every Monday at 9 AM / When a new file arrives / Pressing a button manually

Q2. What data or information does it use?
    e.g. An internal Google Spreadsheet, a competitor's website, an internal system screen

Q3. What should it do at the end?
    e.g. Post a message to Slack #sales, save a PDF to a specific folder, send an email
```

→ Used in PRD `<context> # Core Features` and `# User Experience`

---

## Form 3 / 5 — Tools & Systems

```
Q1. What services or apps are involved?
    e.g. Slack, Google Sheets, Notion, Salesforce, kintone, our internal [X] system

Q2. Can you log in to each of those services yourself?
    If any use a company account managed by IT, we may need to coordinate with them.
    e.g. Slack: personal account / Google: company account managed by IT
    (Leave blank if you're not sure — that's fine)

Q3. Do you have any reference URLs or documents?
    e.g. https://api.slack.com/..., a Notion page link
    Paste the URL directly — it will be loaded and referenced.
    (Leave blank if none)
```

→ Used in PRD `<PRD> # Technical Architecture`

---

## Form 4 / 5 — Quality & Error Handling

```
Q1. How should you be notified if something goes wrong?
    e.g. A Slack notification, an email, just keep a log is fine
    (Leave blank if you're not sure — that's fine)

Q2. How will you know it worked correctly?
    e.g. A message appeared in Slack, a file was created in the right folder
    (Leave blank if you're not sure — that's fine)

Q3. Any constraints or concerns to keep in mind?
    e.g. Keep costs low, only works inside the company network, contains personal data
    (Leave blank if none)
```

→ Used in PRD `<PRD> # Risks and Mitigations`

---

## Form 5 / 5 — Scope & Priority

```
Q1. List the things that must be included this time (bullet points).

Q2. Are there things that should be left out or saved for later?
    e.g. Customizing notification message design, supporting multiple languages

Q3. How would you prioritize features? (optional)
    Use three levels: "Must have" / "Nice to have" / "If time allows"
    e.g. Must have: data fetch and aggregation, Nice to have: error alerts, If time allows: attach chart
```

→ Used in PRD `<PRD> # Development Roadmap` and `# Appendix`

---

## PRD Format

Follows the structure of `.taskmaster/templates/example_prd.txt`.
Map interview answers to each section to generate the PRD.

```
<context>
# Overview
[2–3 sentences on the automation goal, problem solved, and target user (Form 1 Q1/Q2)]

# Current State
[Current manual flow and pain points (Form 1 Q2/Q3/Q4)]
- Owner: [who]
- Frequency: [how often / how long it takes]
- Pain point: [what is inefficient]

# Core Features
[Key features of the automation flow as bullet points (Form 2)]
- Trigger: [what kicks off execution]
- Input: [data source / how it is fetched]
- Processing: [transformation / aggregation / decision logic]
- Output: [artifact / destination / storage location]
</context>

<PRD>
# Technical Architecture
[Tech stack and implementation approach (Form 3)]

## Tools & Integrations
| Tool / Service | Purpose | Auth |
|----------------|---------|------|
| [name] | [purpose] | [personal / company account / requires IT] |

## Execution Conditions
- Trigger: [scheduled / event-driven / manual]
- Schedule: [cron expression or description]
- Environment: [local / server / cloud]

# Development Roadmap
[Implementation phases. Do not think about timelines — scope and detail only (Form 5)]

## Phase 0: Environment Setup
- [ ] Install dependencies
- [ ] Configure credentials and test connectivity

## Phase 1: Data Fetch
- [ ] [Implement input data retrieval] (depends on: Phase 0)
- [ ] Validate fetched data

## Phase 2: Processing
- [ ] [Implement main processing logic] (depends on: Phase 1)

## Phase 3: Output & Notifications
- [ ] [Implement output / delivery] (depends on: Phase 2)
- [ ] Implement error notifications

## Phase 4: Operationalization
- [ ] Configure scheduling (depends on: Phase 3)
- [ ] End-to-end smoke test and acceptance test

# Logical Dependency Chain
[Task execution order]
- Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4
- Phase 0: no dependencies (foundation)
- Phase 1: depends on Phase 0
- Phase 2: depends on Phase 1
- Phase 3: depends on Phase 2
- Phase 4: depends on Phase 3

# Risks and Mitigations
[Error handling, constraints, risks (Form 4)]

## Error Handling
| Failure Case | Response | Notification Target |
|--------------|---------|---------------------|
| [API timeout etc.] | [retry / skip / stop] | [destination] |

## Constraints
- [Cost, environment, security constraints etc.]

## Success Criteria
- [What counts as done (Form 4 Q2)]

# Appendix
## Scope
### In Scope
[Form 5 Q1]
- ...

### Out of Scope
[Form 5 Q2]
- ...

## Priority
| Feature | Priority | Notes |
|---------|---------|-------|
| [feature name] | Must have / Nice to have / If time allows | [reason] |

## References
[Reference materials provided in Form 3 Q3]
- [URL]
</PRD>
```
