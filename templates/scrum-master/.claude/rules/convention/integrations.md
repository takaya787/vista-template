---
paths: "**/*"
---

# External Service Conventions

Defines connection methods for external services as conventions.
Follow these rules when adding a new service.

## Connection Methods

| Service | Method | Auth | Script |
|---------|--------|------|--------|
| GitHub | `gh` CLI | `gh auth login` | — |
| Notion | Playwright (Browser) | `scripts/notion-login.mjs` | `scripts/notion-fetch.mjs` |

## Conventions

### GitHub
- All GitHub operations go through the `gh` CLI
- GraphQL API via `gh api graphql`
- Authentication must be configured via `gh auth login`

### Notion
- When Notion API is blocked by org restrictions, use Playwright for browser automation
- Session state is saved in `.notion-auth.json` (gitignored)
- Login: `node scripts/notion-login.mjs`
- Fetch page: `node scripts/notion-fetch.mjs <url>`
- Check session: `node scripts/notion-login.mjs --check`

### When Adding a New Service
1. Add an access script to `scripts/`
2. Add an entry to the table above
3. Add required permissions to `.claude/settings.local.json`
4. Add usage instructions to the Useful Commands section of `CLAUDE.md`
5. If the service requires per-user account info (ID, username, etc.), add the field to `.vista/profile/me.json` (see `rules/convention/onboarding.md`)
