---
paths: "**/*"
---

# Testing Standards

Immutable standards for test structure, naming, and coverage expectations.
For project-specific test runner and commands, see `rules/config/tech-stack.md` and `rules/config/ci-config.md`.

## Test Pyramid

| Layer | Scope | Target speed | When required |
|-------|-------|-------------|--------------|
| Unit | Single function or class in isolation | < 100ms per test | All business logic, error paths, edge cases |
| Integration | Module boundary — DB, external API, filesystem | < 5s per test | Repository layer, adapters, external calls |
| E2E | Full user flow through the system | Minutes | Critical user paths only; not required for every feature |

Write more unit tests than integration tests. Write more integration tests than E2E tests.

## Naming Convention

Pattern: `<subject>_<condition>_<expected outcome>`

Examples:
- `calculateTotal_withEmptyCart_returnsZero`
- `UserService_whenEmailIsDuplicate_throwsConflictError`
- `fetchOrder_whenNetworkFails_retriesOnce`

If the test framework uses `describe`/`it` blocks, express the same structure as:
```
describe('<Subject>') {
  it('<condition> → <expected outcome>')
}
```

## Mocking Policy

- Mock at the **boundary** of the unit under test, not inside it
- Never mock the class or function you are testing
- Mock external I/O (DB, HTTP, filesystem, time) and nothing else
- If setting up a mock requires more code than the test itself, the production code is likely over-coupled — note this as a `[MINOR]` finding

## What to Test

- **Test behavior, not implementation** — if the test breaks on a refactor that does not change observable behavior, the test is wrong
- **Test error paths explicitly** — every `catch` block and every early return should have at least one test
- **Test boundary conditions** — empty input, zero, null, maximum values, concurrent access

## What Not to Test

- Framework internals and third-party libraries
- Private methods directly — test through the public interface
- Getters and setters with no logic
- Code that is already covered by integration tests at a higher level

## Coverage Expectations

Coverage percentage is a proxy metric, not a goal. Apply risk-based judgment:

| Code type | Expected coverage approach |
|-----------|--------------------------|
| Business logic, domain rules | All branches, including error paths |
| Repository / DB layer | Integration tests; unit tests for query-building logic |
| Controller / handler layer | Integration or E2E; not unit tests |
| Pure utility functions | All inputs, including edge cases |
| Framework configuration | Not tested |

A test that inflates coverage without verifying behavior (e.g., calling a function and asserting it did not throw) is worth less than no test.

## When Writing Tests for Existing Code

1. Read the function under test and identify all observable behaviors
2. Write one test per behavior, not one test per line
3. Do not add tests for behaviors that are already covered — check existing test files first
4. If a function is untestable (no dependency injection, global state, static calls), note this as `[MINOR]` tech debt before adding a workaround

## Claude-Specific Rules

- Follow the existing test style in the project — do not introduce a second testing pattern
- If no test file exists for the changed module, create one; do not add tests to unrelated test files
- After writing tests, verify they fail when the production code is intentionally broken (if possible via code inspection)
- New test files must be placed adjacent to the production file or in the project's established test directory, per `rules/config/tech-stack.md`
