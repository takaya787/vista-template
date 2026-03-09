---
paths:
  - "e2e/**"
  - "playwright.config.ts"
---

# E2E Testing Standards

End-to-end testing conventions for the UI codebase using Playwright.

## Tech Stack

| Item       | Technology              |
| ---------- | ----------------------- |
| Framework  | Playwright              |
| Runner     | `@playwright/test`      |
| Config     | `playwright.config.ts`  |
| Test dir   | `e2e/`                  |

## Directory Structure

```
e2e/
  fixtures/          # Shared test fixtures and setup helpers
  specs/             # Test spec files grouped by feature
    editor.spec.ts
    sidebar.spec.ts
    onboarding.spec.ts
    ...

test-results/        # All test artifacts (gitignored)
  screenshots/       # Manual screenshots from tests
  artifacts/         # Playwright auto-generated artifacts (traces, videos, etc.)
  report/            # HTML report output
```

## Naming Conventions

| Target        | Convention                  | Example                    |
| ------------- | --------------------------- | -------------------------- |
| Spec file     | `<feature>.spec.ts`         | `editor.spec.ts`           |
| Fixture file  | `<name>.fixture.ts`         | `workspace.fixture.ts`     |
| Test describe | Feature name                | `describe("Editor UX")`    |
| Test case     | Numbered + behavior summary | `test("1. Opens file")`    |
| Screenshot    | `NN-description.png`        | `01-workspace.png` (saved to `test-results/screenshots/`) |

## Writing Tests

### Electron API Mocking

Since the app runs on Electron, tests must mock `window.electronAPI` via `page.addInitScript()` before navigation:

```ts
await page.addInitScript({
  content: `
    window.electronAPI = {
      selectFolder: () => Promise.resolve("/mock/project"),
      readDirectory: () => Promise.resolve(mockFiles),
      readFile: (path) => Promise.resolve(mockContents[path] || ""),
    };
  `,
});
await page.goto("/");
```

### Best Practices

- **Do**: Extract shared setup into `e2e/fixtures/` as reusable functions
- **Do**: Use `test.describe()` to group related tests per feature
- **Do**: Take screenshots at key steps for visual review
- **Do**: Use `test.info().annotations` for audit-style metadata
- **Do**: Prefer visible-text or `data-testid` selectors over CSS class selectors
- **Don't**: Use `waitForTimeout()` as a primary wait strategy — prefer `waitForSelector()` or `expect().toBeVisible()`
- **Don't**: Write tests that depend on execution order across files
- **Don't**: Commit screenshots or test-results to the repository

### Selectors Priority

1. `data-testid` attributes (most stable)
2. ARIA roles and labels (`role=button`, `aria-label`)
3. Visible text (`text=Save`)
4. CSS selectors (last resort)

## Running Tests

```bash
# Run all e2e tests (dev server must be running)
pnpm exec playwright test

# Run a specific spec
pnpm exec playwright test e2e/specs/editor.spec.ts

# Run with UI mode for debugging
pnpm exec playwright test --ui

# Run headed (visible browser)
pnpm exec playwright test --headed
```

## Gitignore

All test artifacts are consolidated under a single root directory:

- `test-results/` — gitignored, contains all output
  - `screenshots/` — manual screenshots taken in tests
  - `artifacts/` — Playwright auto-generated output (traces, videos, diffs)
  - `report/` — HTML report

This keeps the project root clean. Do NOT create additional top-level directories for test output.
