# Role-Specific Interview — investor-relations

AskUserQuestion batches for the investor-relations role. Used by the onboarding skill (Step 4).

## Batch A (2 questions)

### IR-Q1: Fiscal Year End

- **header:** "Fiscal Year"
- **question:** "When does your fiscal year end?"
- **multiSelect:** false
- **options:**
  1. `{ label: "December (Recommended)", description: "Calendar year — FY ends Dec 31" }`
  2. `{ label: "March", description: "Japanese fiscal year — FY ends Mar 31" }`
  3. `{ label: "June", description: "FY ends Jun 30" }`
  4. `{ label: "September", description: "FY ends Sep 30" }`
- **Target:** `rules/config/ir-calendar.md` → Fiscal Year End
- **Skip default:** `"December"`

### IR-Q2: Reporting Frequency

- **header:** "Reporting"
- **question:** "How often do you publish financial reports?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Quarterly (Recommended)", description: "Q1–Q4 reports + annual" }`
  2. `{ label: "Semi-annual", description: "H1 + H2 reports + annual" }`
  3. `{ label: "Annual only", description: "Annual report only" }`
- **Target:** `rules/config/ir-calendar.md` → Reporting Frequency
- **Skip default:** `"Quarterly"`

## Batch B (2 questions)

### IR-Q3: Primary Metrics

- **header:** "Metrics"
- **question:** "What are your primary financial metrics? (select all that apply)"
- **multiSelect:** true
- **options:**
  1. `{ label: "Revenue / Net Sales", description: "Top-line revenue figure" }`
  2. `{ label: "ARR / MRR", description: "Annual / Monthly Recurring Revenue" }`
  3. `{ label: "Operating Income", description: "EBIT or operating profit" }`
  4. `{ label: "Free Cash Flow", description: "Operating cash flow minus capex" }`
- **Target:** `rules/config/reporting-standards.md` → Key Metrics
- **Skip default:** `["Revenue / Net Sales"]`

### IR-Q4: Number Format

- **header:** "Format"
- **question:** "What number format do you use in reports?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Millions JPY (Recommended)", description: "e.g., ¥1,234M" }`
  2. `{ label: "Millions USD", description: "e.g., $1,234M" }`
  3. `{ label: "Billions JPY", description: "e.g., ¥1.2B" }`
  4. `{ label: "Thousands USD", description: "e.g., $1,234K" }`
- **Target:** `rules/config/reporting-standards.md` → Number Format
- **Skip default:** `"Millions JPY"`

## Free-Text Follow-ups

### IR-Free: Quiet Period Dates

After the batch above, ask via follow-up message:
> "When are your quiet periods? (e.g., 'Last 2 weeks of each quarter')"

- **Target:** `rules/config/ir-calendar.md` → Quiet Periods
- **Skip default:** Leave as `{{QUIET_PERIOD_DEFINITION}}`

### IR-Free2: Disclosure Calendar

After quiet period dates, ask:
> "Do you have a scheduled earnings release date? (e.g., 'Q1 results on May 15')"

- **Target:** `rules/config/ir-calendar.md` → Disclosure Schedule
- **Skip default:** Leave as placeholder
