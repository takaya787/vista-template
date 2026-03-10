# Role-Specific Interview — engineer

AskUserQuestion batches for the engineer role. Used by the onboarding skill (Step 4).

## Batch A (2 questions)

### ENG-Q1: Primary Language

- **header:** "Language"
- **question:** "What is your primary programming language?"
- **multiSelect:** false
- **options:**
  1. `{ label: "TypeScript / JavaScript (Recommended)", description: "Frontend and backend JS ecosystem" }`
  2. `{ label: "Python", description: "Backend, data science, scripting" }`
  3. `{ label: "Go", description: "Systems and backend services" }`
  4. `{ label: "Rust", description: "Systems programming" }`
- **Target:** `rules/config/tech-stack.md` → Primary Language
- **Skip default:** Leave as placeholder

### ENG-Q2: Frontend Framework

- **header:** "Frontend"
- **question:** "What frontend framework do you use?"
- **multiSelect:** false
- **options:**
  1. `{ label: "React / Next.js (Recommended)", description: "React with Next.js for SSR/SSG" }`
  2. `{ label: "Vue / Nuxt", description: "Vue with Nuxt framework" }`
  3. `{ label: "None — backend only", description: "API or CLI project, no frontend" }`
- **Target:** `rules/config/tech-stack.md` → Frontend Framework
- **Skip default:** Leave as placeholder

## Batch B (2 questions)

### ENG-Q3: Branch Strategy

- **header:** "Branches"
- **question:** "What branch strategy do you follow?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GitHub Flow (Recommended)", description: "main + feature branches, PR to main" }`
  2. `{ label: "Git Flow", description: "main + develop + release branches" }`
  3. `{ label: "Trunk-based", description: "Direct commits to main, short-lived branches" }`
- **Target:** `rules/config/repository.md` → Branch Strategy
- **Skip default:** `"GitHub Flow"`

### ENG-Q4: CI Tool

- **header:** "CI/CD"
- **question:** "What CI/CD tool do you use?"
- **multiSelect:** false
- **options:**
  1. `{ label: "GitHub Actions (Recommended)", description: "Integrated GitHub CI/CD" }`
  2. `{ label: "CircleCI", description: "Cloud-based CI/CD platform" }`
  3. `{ label: "None / Local only", description: "No CI configured yet" }`
- **Target:** `rules/config/ci-config.md` → CI Tool
- **Skip default:** `"GitHub Actions"`

## Free-Text Follow-ups

### ENG-Free: Repository URL

After the batch above, ask via follow-up message:
> "What is your GitHub repository URL? (e.g., https://github.com/org/repo)"

- **Target:** `rules/config/repository.md` → Repository URL
- **Skip default:** Leave as `{{REPO_URL}}`

### ENG-Free2: Local Verification Commands

After repository URL, ask:
> "What commands do you run locally to verify changes? (e.g., `npm test`, `npm run lint`)"

- **Target:** `rules/config/ci-config.md` → Local Verification Commands
- **Skip default:** Leave as placeholder
