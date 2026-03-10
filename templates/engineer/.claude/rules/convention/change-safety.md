---
paths: "**/*"
---

# Change Safety

Defines irreversibility tiers and required gates before executing potentially destructive operations.
These rules cannot be overridden by Config or user instruction.

## Irreversibility Tiers

| Tier | Examples | Required Gate |
|------|----------|---------------|
| **0 — Reversible** | Edit file, create file, `git add` | None — execute directly |
| **1 — Git-reversible** | `git commit`, local branch deletion | State intent in one sentence before executing |
| **2 — Requires confirmation** | Delete file outside git, `git reset --hard`, DB migration | Pause, describe exact effect, wait for explicit "yes" |
| **3 — Never without owner approval** | Push to protected branch, production changes, secret file access | Hard stop. State the action and why it is blocked. Offer alternatives |

## Security Review Checklist

Before writing or modifying code that touches authentication, authorization, cryptography, or external API calls, verify:

- [ ] Input is validated before use (type, range, allowlist where applicable)
- [ ] Authentication checks occur before any data access
- [ ] Secrets are read from environment variables, never hardcoded
- [ ] External input is not used in file paths, SQL queries, or shell commands without sanitization
- [ ] Error messages do not leak internal state to external callers

If any item fails, surface it as `[SECURITY]` in the output before proceeding.

## Protected Patterns

The following require Tier 3 approval regardless of context:

- `rm -rf /` — Root deletion
- `git push --force` to main/master — Force push to protected branches
- Reading `.env`, `.pem`, `.secret` files — Credential access
- `DROP TABLE`, `DELETE FROM` without WHERE — Schema/data destruction

## Mid-Task Escalation

If a task initially classified as Tier 0-1 reveals a Tier 2-3 operation during execution:

1. Stop immediately
2. Notify the user: "This task requires [describe operation] which is Tier [N]. I need explicit confirmation."
3. Do not proceed until confirmation is given

## Blast Radius Assessment

For every proposed change, consider:

| Dimension | Question |
|-----------|----------|
| **Scope** | How many files, modules, or services are affected? |
| **Consumers** | What calls or imports the changed code? |
| **Data** | Does this touch a data model, schema, or serialized format? |
| **Contracts** | Does this change a public API, interface, or event shape? |
| **Reversibility** | Can this be rolled back without data loss? |

## Incremental Change Preference

When a change has high blast radius, prefer:
1. Feature flags over direct replacement
2. Parallel-run (old + new) over cutover
3. Additive changes (new field) before removals (delete old field)
