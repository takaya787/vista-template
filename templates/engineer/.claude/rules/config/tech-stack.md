---
paths: "**/*"
---

# Tech Stack

Project-specific language, framework, and tooling configuration.
For language-agnostic coding standards, see `rules/convention/coding-standards.md`.

## Languages

| Role | Language | Version |
|------|----------|---------|
| Backend | `{{BACKEND_LANGUAGE}}` | `{{BACKEND_VERSION}}` |
| Frontend | `{{FRONTEND_LANGUAGE}}` | `{{FRONTEND_VERSION}}` |
| Infrastructure | `{{INFRA_LANGUAGE}}` | — |

## Frameworks & Libraries

| Layer | Tool | Notes |
|-------|------|-------|
| Web framework | `{{WEB_FRAMEWORK}}` | |
| ORM / DB client | `{{ORM}}` | |
| Test runner | `{{TEST_RUNNER}}` | |
| Linter | `{{LINTER}}` | Config at `{{LINTER_CONFIG_PATH}}` |
| Formatter | `{{FORMATTER}}` | |

## Project-Specific Conventions

<!-- Add conventions that extend coding-standards.md for this project's stack -->
<!-- Examples: -->
<!-- - Use `zod` for all runtime validation at API boundaries -->
<!-- - Prefer `async/await` over promise chains -->
<!-- - All DB queries go through the repository layer, never directly in handlers -->

## Dependency Management

| Key | Value |
|-----|-------|
| Package manager | `{{PACKAGE_MANAGER}}` |
| Lockfile | `{{LOCKFILE}}` |
| Add command | `{{ADD_COMMAND}}` |

- Always commit lockfile changes together with the dependency change
- Do not add dependencies without checking if existing libraries already cover the need
