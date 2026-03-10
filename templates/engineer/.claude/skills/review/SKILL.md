---
name: review
description: Perform a structured code review with severity-tagged findings. Use when the user says "/review", "review this PR", "review this file", "code review", "check this code", "コードレビューして", or pastes a diff. Proactively trigger when the user shares a git diff or mentions a PR number.
---

# Review — Code Review

Perform a structured, severity-tagged code review against the project's coding standards and the four-layer checklist.

## Why This Skill Is Needed

Unstructured review output mixes blocking issues with style preferences, making it hard for the owner to triage. This skill produces a consistent four-layer review with explicit severity tags, clear rationale for each finding, and `[CANNOT ASSESS]` notices where review requires runtime context Claude does not have.

## Input Requirements

| Input | Action |
|-------|--------|
| File path(s) to review | Read file(s) and analyze |
| Git diff (pasted or `git diff` output) | Analyze diff; note context gaps |
| PR number | Use `gh pr diff <n>` to fetch diff; `gh pr view <n>` for description |
| Diff/patch file in `inbox/` | Read and analyze |
| "Review this" with no target | `[REQUIRES INPUT]` — Ask: "Which file, diff, or PR number should I review?" and stop |
| Code with unresolvable dependencies | Continue; tag findings as `[CANNOT ASSESS — needs: <dependency>]` |

## Data Sources

1. **Code under review** — file path, pasted diff, or PR diff
2. **Coding standards** — `rules/convention/coding-standards.md` (four-layer checklist, severity scale)
3. **Tech stack** — `rules/config/tech-stack.md` (project-specific patterns)
4. **Change safety** — `rules/convention/change-safety.md` (security review checklist)

## Steps

### Step 1: Gather Context

- PR number: fetch diff with `gh pr diff <n>` and description with `gh pr view <n>`
- File path: read the file and check `git log -5 --oneline <path>` for recent changes
- Pasted diff: parse directly
- Note imported modules or types that are referenced but not visible

### Step 2: Apply Four-Layer Review

Per `rules/convention/coding-standards.md`:

**Layer 1 — Correctness**: Logic errors, boundary conditions, null handling, race conditions, off-by-one
**Layer 2 — Security**: Run the full checklist from `rules/convention/change-safety.md`. Any failure → `[SECURITY]` `[CRITICAL]`
**Layer 3 — Maintainability**: Naming, function length, complexity, test coverage of changed code
**Layer 4 — Consistency**: Compare against patterns in `rules/config/tech-stack.md`

### Step 3: Assign Severity

| Tag | Meaning | Action required |
|-----|---------|-----------------|
| `[CRITICAL]` | Security issue, data loss risk, will break in production | Must fix before merge |
| `[MAJOR]` | Logic error, missing error handling, broken contract | Should fix before merge |
| `[MINOR]` | Style, naming, improvement opportunity | Fix at discretion |
| `[NIT]` | Formatting, trivial | Optional |
| `[CANNOT ASSESS]` | Requires runtime context or missing file | Owner to verify manually |

### Step 4: Generate Review

Output per the format below. Group by severity descending.

### Step 5: Verdict

- `APPROVE` — No CRITICAL or MAJOR findings
- `REQUEST CHANGES` — One or more CRITICAL or MAJOR findings
- `COMMENT` — All MINOR/NIT/CANNOT ASSESS; owner decides

### Step 6: Save

Save to `docs/reviews/{YYYY-MM-DD}-{pr-or-description}.md`.

## Output Format

```markdown
---
reviewed: <file or PR reference>
date: YYYY-MM-DD
verdict: APPROVE | REQUEST CHANGES | COMMENT
---

## Summary

- Verdict: **APPROVE / REQUEST CHANGES / COMMENT**
- CRITICAL: X | MAJOR: X | MINOR: X | NIT: X | CANNOT ASSESS: X
- （One-line summary of main concern or positive finding）

## Findings

### [CRITICAL] <Short title>
**File**: `path/to/file.ts` line N
**Layer**: Security
**Issue**: ...
**Suggested fix**:
（code suggestion）

---

### [MAJOR] <Short title>
**File**: `path/to/file.ts` line N
**Layer**: Correctness
**Issue**: ...
**Suggested fix**: ...

### [MINOR] <Short title>
...

### [NIT] <Short title>
...

### [CANNOT ASSESS] <Short title>
**Needs**: <what context would resolve this>

## What Looks Good

- （positive observations — well-covered edge cases, clean abstractions, etc.）

## Action Items (Must fix before merge)

1. [CRITICAL] ...
2. [MAJOR] ...
```

Note: This review is a recommendation. The owner makes the final merge decision.
