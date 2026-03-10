---
paths: "**/*"
---

# CI/CD Config

Project-specific CI pipeline and environment configuration.

## Local Verification Commands

Run these before proposing a PR. Claude should run these after any code change.

| Check | Command |
|-------|---------|
| Tests | `{{TEST_COMMAND}}` |
| Lint | `{{LINT_COMMAND}}` |
| Type check | `{{TYPECHECK_COMMAND}}` |
| Build | `{{BUILD_COMMAND}}` |

## CI System

| Key | Value |
|-----|-------|
| Platform | `{{CI_PLATFORM}}` (e.g., GitHub Actions, CircleCI) |
| Config file | `{{CI_CONFIG_PATH}}` |
| Status check URL | `{{CI_STATUS_URL}}` |

## Environments

| Environment | Branch trigger | Purpose |
|-------------|----------------|---------|
| Development | `{{DEV_BRANCH}}` | Local / PR preview |
| Staging | `{{STAGING_BRANCH}}` | QA and acceptance testing |
| Production | `{{PROD_BRANCH}}` | Live traffic |

- Claude MUST NOT execute deployment commands targeting Staging or Production
- Deployment to non-local environments requires Tier 3 approval per `rules/convention/change-safety.md`
