# Role-Specific Interview — product-manager

AskUserQuestion batches for the product-manager role. Used by the onboarding skill (Step 4).

## Batch A (2 questions)

### PM-Q1: Prioritization Framework

- **header:** "Prioritization"
- **question:** "What prioritization framework do you use?"
- **multiSelect:** false
- **options:**
  1. `{ label: "RICE (Recommended)", description: "Reach × Impact × Confidence / Effort" }`
  2. `{ label: "ICE", description: "Impact × Confidence × Ease" }`
  3. `{ label: "MoSCoW", description: "Must / Should / Could / Won't" }`
  4. `{ label: "None / Ad-hoc", description: "Flexible prioritization without a fixed framework" }`
- **Target:** `rules/config/roadmap-settings.md` → Prioritization Default
- **Skip default:** `"RICE"`

### PM-Q2: Issue Tracker

- **header:** "Issues"
- **question:** "What tool do you use for issue and task tracking?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GitHub Issues (Recommended)", description: "GitHub native issue tracker" }`
  2. `{ label: "Jira", description: "Atlassian Jira" }`
  3. `{ label: "Linear", description: "Linear issue tracker" }`
  4. `{ label: "Notion", description: "Notion database as task tracker" }`
- **Target:** `rules/config/pm-integrations.md` → Issue Tracker
- **Skip default:** `"GitHub Issues"`

## Batch B (2 questions)

### PM-Q3: Analytics Tool

- **header:** "Analytics"
- **question:** "What analytics tool do you use for product metrics?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GA4 (Recommended)", description: "Google Analytics 4" }`
  2. `{ label: "Mixpanel", description: "Product analytics platform" }`
  3. `{ label: "Amplitude", description: "Digital analytics platform" }`
  4. `{ label: "None", description: "No analytics tool configured yet" }`
- **Target:** `rules/config/pm-integrations.md` → Analytics Tool
- **Skip default:** `"GA4"`

### PM-Q4: OKR Cycle

- **header:** "OKRs"
- **question:** "How often do you set OKRs?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Quarterly (Recommended)", description: "OKRs reset every quarter" }`
  2. `{ label: "Annual", description: "Annual OKRs with quarterly check-ins" }`
  3. `{ label: "None", description: "No OKR process" }`
- **Target:** `rules/config/roadmap-settings.md` → OKR Cycle
- **Skip default:** `"Quarterly"`

## Free-Text Follow-ups

### PM-Free: Roadmap Tool URL

After the batch above, ask via follow-up message:
> "Do you use a roadmap tool (Notion, Productboard, Linear, etc.)? If so, paste the URL."

- **Target:** `rules/config/pm-integrations.md` → Roadmap Tool URL
- **Skip default:** Leave as `{{ROADMAP_URL}}`

### PM-Free2: North Star Metric

After roadmap URL, ask:
> "What is your product's North Star metric? (e.g., Weekly Active Users, Revenue, NPS)"

- **Target:** `rules/config/roadmap-settings.md` → North Star Metric
- **Skip default:** Leave as placeholder
