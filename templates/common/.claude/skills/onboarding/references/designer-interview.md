# Role-Specific Interview — designer

AskUserQuestion batches for the designer role. Used by the onboarding skill (Step 4).

## Batch A (2 questions)

### DS-Q1: Design Tool

- **header:** "Design Tool"
- **question:** "What is your primary design tool?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Figma (Recommended)", description: "Cloud-based collaborative design" }`
  2. `{ label: "Sketch", description: "macOS design tool" }`
  3. `{ label: "Adobe XD", description: "Adobe design and prototyping tool" }`
- **Target:** `rules/config/design-tools.md` → Primary Design Tool
- **Skip default:** `"Figma"`

### DS-Q2: Handoff Tool

- **header:** "Handoff"
- **question:** "How do you hand off designs to engineers?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Figma Inspect (Recommended)", description: "Built-in Figma developer handoff" }`
  2. `{ label: "Zeplin", description: "Dedicated design handoff platform" }`
  3. `{ label: "None — spec docs only", description: "Written spec documents without a handoff tool" }`
- **Target:** `rules/config/design-tools.md` → Handoff Tool
- **Skip default:** `"Figma Inspect"`

## Batch B (2 questions)

### DS-Q3: Design System Documentation

- **header:** "Design System"
- **question:** "Where is your design system documented?"
- **multiSelect:** false
- **options:**
  1. `{ label: "Storybook (Recommended)", description: "Component library documentation" }`
  2. `{ label: "Notion", description: "Notion-based design documentation" }`
  3. `{ label: "Zeroheight", description: "Dedicated design system documentation" }`
  4. `{ label: "Local docs only", description: "docs/design-system/ in this project" }`
- **Target:** `rules/config/design-tools.md` → Design System Documentation
- **Skip default:** Leave as placeholder

### DS-Q4: Token Format

- **header:** "Tokens"
- **question:** "What format do you export design tokens in?"
- **multiSelect:** false
- **options:**
  1. `{ label: "JSON (Recommended)", description: "Standard JSON token format" }`
  2. `{ label: "CSS Variables", description: "CSS custom properties" }`
  3. `{ label: "No tokens yet", description: "Design tokens not yet implemented" }`
- **Target:** `rules/config/design-tools.md` → Token Format
- **Skip default:** `"JSON"`

## Free-Text Follow-ups

### DS-Free: Figma Project URL

After the batch above, ask via follow-up message:
> "Paste your Figma project URL (and component library URL if separate)."

- **Target:** `rules/config/design-tools.md` → Figma → Project URL, Component Library
- **Skip default:** Leave as `{{FIGMA_PROJECT_URL}}`

### DS-Free2: Brand Guidelines

After Figma URL, ask:
> "Do you have brand guidelines? If so, paste the URL or file path."

- **Target:** `rules/config/design-tools.md` → Brand Guidelines → Location
- **Skip default:** Leave as `{{BRAND_GUIDE_URL_OR_PATH}}`
