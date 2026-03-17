# Interview Protocol — Business Role Onboarding Questions

Reference document for the onboarding skill. The full question definitions are maintained as structured data in [`interview-protocol.json`](./interview-protocol.json). This file provides orientation, rendering notes, and key implementation details.

## Question Definition File

**Source of truth:** `references/interview-protocol.json`

The JSON file defines all questions across 10 phases (~10 minutes total). Each question object has:

| Field | Description |
|-------|-------------|
| `id` | Unique identifier |
| `phase` | Phase number (1–10) |
| `phase_label` | Display label for the phase |
| `type` | One of: `auto_detect`, `text`, `textarea`, `single_select`, `multi_select` |
| `label` | Question text shown to the user |
| `key` | Dot-notation path in `.vista/profile/me.json` |
| `required` | Whether the field must be filled before proceeding |
| `options` | Array of `{ value, label }` for select types |
| `placeholder` | Example input hint (text/textarea only) |
| `description` | Optional supplementary explanation |
| `auto_detect` | Source hint for `auto_detect` type (e.g., `"system timezone"`) |

---

## Phase Overview

| Phase | Label | Questions |
|-------|-------|-----------|
| 1 | 基本情報 | name, email, timezone (auto_detect) |
| 2 | 言語・コミュニケーション設定 | language, output_format, verbosity, tone |
| 3 | 役割・組織 | role_category, role_title, industry, company_size, position_level, stakeholders |
| 4 | 日々の業務・成果物 | primary_outputs, daily_description, recurring_tasks, time_consuming |
| 5 | 会議・コミュニケーション | meeting_frequency, meeting_types, meeting_prep |
| 6 | 仕事のスタイル | work_approach, decision_style, review_process, priority_handling, working_hours |
| 7 | 使用ツール・サービス | communication_tools, project_tools, data_tools, presentation_tools, other_tools |
| 8 | ドキュメント方針 | doc_tools, doc_audience, doc_structure, doc_conventions |
| 9 | Claude の動作設定 | autonomy, edit_scope, never_do, always_follow |
| 10 | 目標・課題 | primary_use_cases, pain_point, success_image |

---

## Rendering Notes (Electron App)

| type | UI Component |
|------|-------------|
| `auto_detect` | Pre-filled input field (editable); show source hint |
| `text` | Single-line input field |
| `textarea` | Multi-line textarea |
| `single_select` | Radio group or dropdown |
| `multi_select` | Checkbox group |

### auto_detect Handling

For `type: "auto_detect"` fields, the app pre-fills the value from the system (e.g., timezone). Display it clearly and allow the user to edit before confirming.

### Required Field Validation

Do not allow progression to the next phase until all `required: true` fields in the current phase have a value.

---

## me.json Key Mapping

All `key` values use dot-notation and map directly to the `.vista/profile/me.json` schema defined in `me.example.json`. For example:

- `"key": "preferences.language"` → `me.json.preferences.language`
- `"key": "role.category"` → `me.json.role.category`
- `"key": "workingStyle.timezone"` → `me.json.workingStyle.timezone`
