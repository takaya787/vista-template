---
name: pr-description
description: Draft a pull request description. Use when the user says "/pr-description", "write a PR description", "draft the PR", "PRの説明を書いて", or after completing an implementation task. Proactively suggest after a series of commits on a feature branch.
---

# PR Description — Pull Request Draft

Draft a structured pull request description based on the diff, commit history, or task context.

## Why This Skill Is Needed

PR descriptions written under time pressure omit context that reviewers need to evaluate changes safely. A good description reduces review round-trips by explaining what changed, why, and how to verify it. This skill produces a consistent, reviewer-friendly PR description that references project conventions and surfaces any reviewer attention points.

## Input Requirements

| Input | Action |
|-------|--------|
| Current branch with commits | Run `git diff main...HEAD` and `git log main...HEAD --oneline` to build context |
| PR number (existing PR) | Fetch with `gh pr view <n>` and `gh pr diff <n>` |
| Pasted diff or description of changes | Use directly |
| File path(s) changed | Read files; infer intent from changes |
| "Write a PR" with no context | `[REQUIRES INPUT]` — Ask: "Which branch or changes should I describe?" and stop |

## Data Sources

1. **Diff and commits** — `git diff main...HEAD`, `git log main...HEAD --oneline`
2. **Repository config** — `rules/config/repository.md` for PR template path, title format, and reviewer policy
3. **Tech stack** — `rules/config/tech-stack.md` for test runner commands (used in Testing section)
4. **CI config** — `rules/config/ci-config.md` for local verification commands

## Steps

### Step 1: Gather Diff and Commit Context

```bash
git diff main...HEAD
git log main...HEAD --oneline
```

If a PR number is given, use `gh pr diff <n>` and `gh pr view <n>` instead.

Identify:
- Files changed and their roles (business logic, tests, config, docs)
- The primary intent of the change (new feature, bug fix, refactor, dependency update)
- Any files that are security-adjacent (auth, crypto, external API calls, DB schema)

### Step 2: Check for PR Template

Check `rules/config/repository.md` for `{{PR_TEMPLATE_PATH}}`. If a template path is defined, read it and populate its sections. If no template is defined, use the standard format below.

### Step 3: Draft Description

Populate each section. For any section where context is insufficient, insert `[SECTION REQUIRED — provide: {what is needed}]` rather than leaving it blank or guessing.

### Step 4: Apply Title Convention

Check `rules/config/repository.md` for `{{COMMIT_FORMAT}}`. Apply the same convention to the PR title.

Common formats:
- Conventional Commits: `feat(scope): short description`
- Issue reference: append `closes #<n>` if an issue is linked

### Step 5: Flag Reviewer Attention Points

Surface proactively:
- Security-adjacent changes (tag with `[SECURITY REVIEW REQUESTED]`)
- Changes with high blast radius (many callers, data model changes)
- Intentional deviations from coding standards with justification
- Items that could not be tested locally and require reviewer verification

### Step 6: Output

Present the draft for owner review. Do not push or create the PR — the owner reviews and submits.

## Output Format

```markdown
## Title

`<title following commit convention from rules/config/repository.md>`

---

## What

(1-3 sentences describing what this PR changes. State the observable behavior change, not the implementation.)

## Why

(1-3 sentences explaining the motivation. Reference the issue number or business context.)

## Changes

- `path/to/file.ts` — (one line describing the change and its purpose)
- `path/to/test.ts` — (added/updated tests for ...)
- (list key files only; omit lockfiles, generated files, and trivial changes)

## Testing

| Check | Command | Result |
|-------|---------|--------|
| Tests | `<from ci-config.md>` | Passing / [UNVERIFIED] |
| Lint | `<from ci-config.md>` | Passing / [UNVERIFIED] |
| Type check | `<from ci-config.md>` | Passing / [UNVERIFIED] |

(Describe any manual testing performed and the scenarios covered.)

## Reviewer Notes

- (Anything the reviewer should pay special attention to)
- (Intentional tradeoffs or deviations from convention, with justification)
- [SECURITY REVIEW REQUESTED] (if applicable — describe what changed and why it needs security focus)

## Related

- Closes #<issue-number> (if applicable)
- ADR: `docs/adr/<NNN>-<title>.md` (if an architectural decision was made)
- Depends on: #<pr-number> (if applicable)
```

Note: This draft is a starting point. The owner should review and adjust before submitting.
