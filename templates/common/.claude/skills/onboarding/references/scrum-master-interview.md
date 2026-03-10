# Role-Specific Interview — scrum-master

AskUserQuestion batch and follow-up prompts for the scrum-master role. Used by the onboarding skill (Step 4).

## Batch (3 questions)

### SM-Q1: Sprint Duration

- **header:** "Sprint"
- **question:** "How long are your sprints?"
- **multiSelect:** false
- **options:**
  1. `{ label: "1 week (Recommended)", description: "Short iterations, fast feedback" }`
  2. `{ label: "2 weeks", description: "Standard agile sprint length" }`
  3. `{ label: "3 weeks", description: "Longer sprints for larger deliverables" }`
- **Target:** `rules/config/sprint-settings.md` → Duration
- **Skip default:** `"1 week"`

### SM-Q2: Sprint Start Day

- **header:** "Start day"
- **question:** "What day do your sprints start?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Monday (Recommended)", description: "Start of business week" }`
  2. `{ label: "Tuesday", description: "Day after Monday sync" }`
  3. `{ label: "Wednesday", description: "Mid-week start" }`
- **Target:** `rules/config/sprint-settings.md` → Start day
- **Skip default:** `"Monday"`

### SM-Q3: Reporting Frequency

- **header:** "Reports"
- **question:** "How often do you want status reports?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Weekly (Recommended)", description: "End-of-week summary" }`
  2. `{ label: "Daily standup", description: "Daily progress updates" }`
  3. `{ label: "Per sprint", description: "Report at sprint boundaries only" }`
- **Target:** `memory/MEMORY.md` → Workflow Notes
- **Skip default:** `"Weekly"`

## Free-Text Follow-ups

### SM-Free: Notion Pages

After the batch above, ask via follow-up message (not AskUserQuestion — URLs are free-text):
> "Do you use Notion for standup or sprint tracking? If so, paste the page URLs."

- **Target:** `rules/config/notion-pages.md` → Page URLs
- **Skip default:** Leave as placeholder

### SM-Free2: Team Members

After Notion URLs, collect team member information for `docs/team.md` via conversational follow-up.

- **Target:** `docs/team.md` → Team member table rows
- **Skip default:** Leave placeholder row intact

---

## Team Member Collection

### Trigger Condition

Run this collection when ALL of the following are true:

1. Role is `scrum-master` (from `.vista/state/setup.json`)
2. `docs/team.md` exists
3. The table contains only the placeholder row (`<!-- Add team members here -->`) or is otherwise empty

If the table already has real member rows, skip to [Re-run Behavior](#re-run-behavior).

### Collection Method

Use **conversational follow-up** (NOT AskUserQuestion). Team member data is multi-row structured input that doesn't fit the multiple-choice format.

#### Prompt

Present the following message to the user:

> Let's set up your team roster. Please list your team members in any format — I'll parse it into the table.
>
> I need: **Name**, **GitHub username**, **Role**, and **Team** for each person.
>
> Example:
> ```
> Tanaka @tanaka-dev Engineer Frontend
> Sato @sato PM Product
> ```
>
> You can also paste a table, comma-separated list, or free-form text. Type "skip" to leave the table empty for now.

### Parsing Rules

1. Accept any reasonable format: free text, CSV, table, one-per-line, JSON
2. Extract four fields per member:
   - **Name** — Display name (required)
   - **GitHub** — GitHub username, strip leading `@` for storage (optional, use `-` if missing)
   - **Role** — Job title or function (optional, use `-` if missing)
   - **Team** — Team or department name (optional, use `-` if missing)
3. After parsing, display the result table and ask for confirmation:
   > Here's what I parsed:
   >
   > | Name | GitHub | Role | Team |
   > |------|--------|------|------|
   > | Tanaka | tanaka-dev | Engineer | Frontend |
   > | Sato | sato | PM | Product |
   >
   > Does this look correct? I can add, remove, or edit any entries.
4. Apply only after the user confirms

### Target File Update

Replace the placeholder row in `docs/team.md` with the confirmed member rows:

```markdown
# Team

| Name | GitHub | Role | Team |
|------|--------|------|------|
| Tanaka | tanaka-dev | Engineer | Frontend |
| Sato | sato | PM | Product |
```

Keep the H1 heading and table header intact. Only replace the body rows.

### Skip Behavior

If the user types "skip" or declines:

- Leave `docs/team.md` unchanged (placeholder row stays)
- Record `"SM-Free2"` in `skippedQuestions` in `.vista/state/onboarding.json`

### Re-run Behavior

When onboarding is re-run and `docs/team.md` already has real member rows:

1. Display the current table contents
2. Ask: "Your team roster already has entries. Would you like to update it?"
3. If yes, allow adding, removing, or editing members
4. If no, skip without changes
