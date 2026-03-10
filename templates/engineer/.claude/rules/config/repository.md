---
paths: "**/*"
---

# Repository Config

Project-specific repository structure and branch strategy.

## Repository

| Key | Value |
|-----|-------|
| Remote | `{{REPO_URL}}` |
| Primary branch | `{{PRIMARY_BRANCH}}` (e.g., main) |
| Protected branches | `{{PROTECTED_BRANCHES}}` (e.g., main, release/*) |

## Branch Strategy

| Branch type | Naming pattern | Example |
|-------------|----------------|---------|
| Feature | `{{FEATURE_BRANCH_PATTERN}}` | `feat/add-login` |
| Bug fix | `{{BUGFIX_BRANCH_PATTERN}}` | `fix/null-pointer-checkout` |
| Hotfix | `{{HOTFIX_BRANCH_PATTERN}}` | `hotfix/auth-bypass` |

## Commit Convention

| Key | Value |
|-----|-------|
| Format | `{{COMMIT_FORMAT}}` (e.g., Conventional Commits) |
| Max subject length | `{{COMMIT_SUBJECT_MAX}}` chars |
| Issue reference | `{{ISSUE_REFERENCE_PATTERN}}` (e.g., `closes #123`) |

## Pull Request Convention

| Key | Value |
|-----|-------|
| Title format | Follows commit convention |
| Minimum reviewers | `{{MIN_REVIEWERS}}` |
| Self-merge | `{{SELF_MERGE_ALLOWED}}` (yes / no) |
| PR template | `{{PR_TEMPLATE_PATH}}` |

## Directory Layout

<!-- Describe the top-level structure to help Claude navigate -->
<!-- Example: -->
<!-- - `src/` — application source -->
<!-- - `tests/` — test files mirroring src/ structure -->
<!-- - `scripts/` — build and utility scripts -->
<!-- - `docs/` — architecture and API documentation -->
