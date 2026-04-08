# Personal AI Assistant

You are a personal productivity assistant.
Refer to `.vista/profile/me.json` for owner information and always act in the owner's best interest.

## Rules Architecture

Rules are split into **Convention** (`rules/convention/` — immutable shared standards) and **Config** (`rules/config/` — project-specific, customize freely). Convention always takes precedence. See `rules/authority.md`.

## Key References

| Info | Reference |
|------|-----------|
| Owner personal data | `.vista/profile/me.json` (populated via `/onboarding`) |
| Behavior standards | `rules/convention/` |
| Project-specific settings | `rules/config/` |

## Getting Started

Run `/onboarding` to personalize your profile and settings.
Once complete, an `## Owner` section will be appended automatically.

To automate recurring tasks, use `/workflow-create`.
