# Interview Protocol — Minimal Profile Questions

Reference document for the onboarding skill. Defines the minimal set of questions to collect during onboarding. All user input is collected via the `AskUserQuestion` tool.

## Auto-Detected Fields

These fields are detected automatically and do not require user input.

| Field | Detection Method | Target |
|-------|-----------------|--------|
| Name | `git config user.name` | `.vista/profile/me.json` → `name` |
| Email | `git config user.email` | `.vista/profile/me.json` → `email` |
| Timezone | macOS: `systemsetup -gettimezone` or `ls -l /etc/localtime`; Linux: `timedatectl` or `cat /etc/timezone` | `.vista/profile/me.json` → `workingStyle.timezone` |

### Confirmation of auto-detected values

Present auto-detected values for confirmation (not via AskUserQuestion):
> I detected the following — let me know if anything needs correction:
> - Email: `{detected}`
> - Timezone: `{detected}`

If detection fails for email, ask via free-text follow-up.

---

## Profile Questions

### Q1: Name (conversational confirmation)

Name is collected via auto-detection and conversational confirmation, not via AskUserQuestion. This avoids the tool's option constraints for a simple yes/no confirmation.

**If name detected from git:**
- Confirm conversationally: "I found your name: {detected_name}. Should I use this, or would you prefer something different?"
- If the owner confirms, use the detected name
- If the owner wants a different name, ask: "What should I call you?"
- **Target:** `.vista/profile/me.json` → `name`

**If name not detected:**
- Ask conversationally: "What should I call you?" (free-text)
- **Target:** `.vista/profile/me.json` → `name`

### Q2 + Q3: Language & Format (single AskUserQuestion call)

Bundle these two questions into one AskUserQuestion call after name is confirmed.

### Q2: Output Language

- **header:** "Language"
- **question:** "Which language should I use for outputs and communication?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Japanese (Recommended)", description: "日本語で出力" }`
  2. `{ label: "English", description: "Output in English" }`
  3. `{ label: "Bilingual", description: "Use both depending on context" }`
- **Target:** `.vista/profile/me.json` → `preferences.language`

### Q3: Output Format

- **header:** "Format"
- **question:** "How do you prefer outputs to be formatted?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Concise bullets (Recommended)", description: "Short, scannable bullet points" }`
  2. `{ label: "Detailed prose", description: "Full explanatory paragraphs" }`
  3. `{ label: "Tables & data", description: "Structured tables with metrics" }`
  4. `{ label: "Mixed", description: "Bullets for summaries, detail for analysis" }`
- **Target:** `.vista/profile/me.json` → `preferences.outputFormat`

---

## Label-to-Value Mapping

When writing to `me.json`, map option labels to stored values:

| Question | Label | Stored Value |
|----------|-------|-------------|
| Language | Japanese (Recommended) | `ja` |
| Language | English | `en` |
| Language | Bilingual | `bilingual` |
| Format | Concise bullets (Recommended) | `bullets` |
| Format | Detailed prose | `prose` |
| Format | Tables & data | `tables` |
| Format | Mixed | `mixed` |
