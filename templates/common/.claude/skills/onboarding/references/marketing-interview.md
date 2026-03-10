# Role-Specific Interview — marketing

AskUserQuestion batches for the marketing role. Used by the onboarding skill (Step 4).

## Batch A (2 questions)

### MK-Q1: Active Channels

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

### MK-Q2: Report Sharing

- **header:** "Sharing"
- **question:** "Where do you share marketing reports?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Markdown only (Recommended)", description: "Keep reports as local markdown files" }`
  2. `{ label: "Notion", description: "Publish reports to Notion pages" }`
  3. `{ label: "Google Sheets", description: "Export KPIs to spreadsheets" }`
- **Target:** `rules/config/integrations.md` → Report Sharing → Primary
- **Skip default:** `"markdown-only"`

## Batch B (2 questions)

### MK-Q3: Analytics Tool

- **header:** "Analytics"
- **question:** "What's your primary analytics tool?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GA4 (Recommended)", description: "Google Analytics 4" }`
  2. `{ label: "Mixpanel", description: "Product analytics platform" }`
  3. `{ label: "Adobe Analytics", description: "Enterprise analytics suite" }`
- **Target:** `rules/config/channels.md` → Analytics → Primary tool
- **Skip default:** `"GA4"`

### MK-Q4: Data Warehouse

- **header:** "Warehouse"
- **question:** "Do you use a data warehouse?"
- **multiSelect:** false
- **options:**
  1. `{ label: "None (Recommended)", description: "No data warehouse — work from CSV exports" }`
  2. `{ label: "BigQuery", description: "Google BigQuery" }`
  3. `{ label: "Snowflake", description: "Snowflake Data Cloud" }`
- **Target:** `rules/config/channels.md` → Analytics → Data warehouse
- **Skip default:** `"None"`

## Free-Text Follow-up

### MK-Free: Notion / Sheets URLs

If MK-Q2 selected Notion or Google Sheets, ask via follow-up message:
> "Please paste your {Notion page URLs / Google Sheet IDs}."

- **Target:** `rules/config/integrations.md` → Notion / Google Sheets sections
- **Skip default:** Leave as placeholder
