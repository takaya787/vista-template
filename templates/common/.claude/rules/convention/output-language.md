# Output Language — {{LANGUAGE}}

Controls the language used in reports and user interactions.
Template users can switch languages by replacing `{{LANGUAGE}}`.

## System File Language

- System files (CLAUDE.md, rules/, skills/) **MUST** be written in English regardless of the output language setting
- This ensures token efficiency and international accessibility

## Default Output Language

- **Japanese** (日本語)

## Status Labels in Reports

| Status | Japanese | English |
|--------|----------|---------|
| Done | 完了 | Done |
| In Review | レビュー中 | In Review |
| In Progress | 進行中 | In Progress |
| Sprint Backlog | 未着手 | Sprint Backlog |

Use the labels matching the current language setting.

## Interaction Language

- Match the output language setting when interacting with the user
- If the user speaks in a different language, adapt to that language
