# Owner Profile — me.json

`me.json` is the owner's personal profile, created by `scripts/setup.sh` during initial setup.

## Usage

- When owner information is needed, read `me.json` in the project root
- If `me.json` does not exist, inform the user to run `scripts/setup.sh` and do NOT attempt to create it

## Continuous Updates

`me.json` is a living document. When new services or integrations are added to the project (per `rules/convention/integrations.md`), add the owner's account or configuration fields to `me.json`.

- Before adding a field, confirm with the user: "May I add `fieldName` to me.json?"
- Keep the JSON flat where possible; use nested objects only for grouped settings (e.g., `workingStyle`, `preferences`)
- Trigger: whenever a new service is registered in `integrations.md` and it requires per-user account info (ID, username, token reference, etc.)

## Reference Priority

1. `me.json` — primary source for owner identity and per-user settings
2. `docs/members/{github}.md` — supplementary profile data
3. `docs/team.md` — team roster
