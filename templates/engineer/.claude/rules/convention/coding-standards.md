---
paths: "**/*"
---

# Coding Standards

Immutable standards for how code is written and reviewed. These apply regardless of language or framework.
For language-specific and framework-specific rules, see `rules/config/tech-stack.md`.

## Readability Principles

- Code is read far more often than written. Optimize for the reader, not the writer
- Names should reveal intent. If a name requires a comment to explain it, rename first
- Comments explain *why*, not *what*. Remove comments that restate what the code already says clearly
- One function, one responsibility. If describing a function requires "and", it should be split

## Error Handling

- Errors must be handled at the boundary where they can be meaningfully acted on
- Do not silently swallow exceptions. Either handle with recovery logic or re-throw with added context
- User-facing error messages must not expose internal implementation details (stack traces, DB errors, file paths)
- `TODO` and `FIXME` comments must include a ticket reference or they will be treated as tech debt

## Review Severity Scale

| Severity | Label | Meaning | Action |
|----------|-------|---------|--------|
| 1 | `[CRITICAL]` | Data loss, security vulnerability, crash in production path | Must fix before merge |
| 2 | `[MAJOR]` | Logic error, missing error handling, broken contract | Should fix before merge |
| 3 | `[MINOR]` | Readability, naming, non-idiomatic pattern | Fix at discretion |
| 4 | `[NIT]` | Formatting, comment style | Optional |

## Four-Layer Review Checklist

A review MUST address all four layers:

| Layer | What to check |
|-------|--------------|
| Correctness | Logic errors, off-by-one, null/undefined handling, race conditions, boundary conditions |
| Security | Input validation, auth checks, secret exposure, injection vectors |
| Maintainability | Naming, complexity, coupling, test coverage of changed code |
| Consistency | Alignment with patterns established in `rules/config/tech-stack.md` |

A review that omits any layer without explanation is incomplete.

## Non-Negotiable Checks

1. **Error paths** — All errors must be handled or explicitly propagated; silent swallows are `[CRITICAL]`
2. **Boundary conditions** — Empty inputs, zero values, max values, concurrent access
3. **Test coverage** — New behavior without a test is `[MAJOR]` unless the PR explicitly notes why
4. **Secret hygiene** — Any hardcoded credential or key is `[CRITICAL]`
5. **Dependency additions** — New third-party deps require justification

## Scope Discipline

- Fix what is asked. Note (but do not fix) unrelated issues found during the task
- Exception: if an unrelated issue is a security vulnerability, surface it immediately with `[SECURITY]` prefix
