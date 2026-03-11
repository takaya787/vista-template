---
name: design-token-update
description: Process a token export, diff against the current processed set, apply changes, and write a changelog entry. Use when the user says "/design-token-update", "トークンを更新して", "新しいトークンファイルを取り込んで", "update tokens", "process token export", or "sync tokens from Figma". Proactively trigger when a new file appears in design/tokens/raw/.
---

# Design Token Update

Process a new raw token export, diff against the current processed set, generate updated output files, and write a dated changelog entry.

## Why This Skill Is Needed

Token updates are high-blast-radius changes: a single rename or value change can break dozens of components simultaneously. This skill enforces a diff-first workflow — no token is silently overwritten. Every addition, change, and deprecation is surfaced explicitly and logged in the design system changelog before any processed file is updated.

## Input Requirements

| Input | Action |
|-------|--------|
| New file in `design/tokens/raw/` | Process — read raw file and proceed |
| User pastes token JSON | Write to `design/tokens/raw/{category}-{YYYY-MM-DD}.json` first, then proceed |
| Figma Tokens Plugin export path | Read the file and proceed |
| "Update tokens" with no file | `[REQUIRES INPUT]` — Ask: "Please export the latest tokens from Figma Tokens Plugin and drop the JSON file into design/tokens/raw/, or paste the JSON here." and stop |

## Data Sources

1. **New raw export** — `design/tokens/raw/` (the file to process)
2. **Current processed tokens** — `design/tokens/processed/` (baseline for diffing)
3. **Token naming convention** — `rules/convention/design-artifacts.md` (naming rules)
4. **Design system changelog** — `docs/design-system/changelog.md` (append new entry)
5. **Existing component specs** — `design/specs/` (identify which specs reference changed tokens)

## Steps

### Step 1: Locate New Raw File

Scan `design/tokens/raw/` for files dated today (`{category}-{YYYY-MM-DD}.{ext}`).
If multiple new files exist, process each category separately in order: color → typography → spacing → radius → shadow → other.

### Step 2: Validate Raw File

Before processing, check:
- [ ] File follows naming convention: `{category}-{YYYY-MM-DD}.json`
- [ ] JSON is valid and parseable
- [ ] Token names follow `{category}.{tier}.{variant}` pattern
- [ ] No values are empty strings or null (flag any as `[INVALID TOKEN]`)

If validation fails, surface errors and stop:
`[TOKEN VALIDATION FAILED] {filename}: {error description}. Fix the source file before processing.`

Raw files are immutable — never edit files in `design/tokens/raw/`.

### Step 3: Diff Against Current Processed Set

Compare the new raw file against the current `design/tokens/processed/` file for the same category.

Categorize every change:

| Change type | Definition |
|-------------|-----------|
| ADDED | Token exists in new file, not in current processed |
| CHANGED | Token exists in both; value has changed |
| DEPRECATED | Token exists in current processed, not in new file |
| RENAMED | Token name changed but value is the same (detect by value matching) |
| UNCHANGED | Token exists in both with identical value — omit from diff output |

Surface the diff to the user before making any changes:

```
Token Diff — {category} — {YYYY-MM-DD}

ADDED (N):
  + color.primary.600  →  #1A56DB

CHANGED (N):
  ~ color.primary.500  #1C64F2 → #1A56DB

DEPRECATED (N):
  - color.brand.legacy  (was #1C64F2)

RENAMED (N):
  color.grey.100 → color.neutral.100  (value unchanged: #F9FAFB)
```

If there are zero changes, report: "No changes detected between new raw file and current processed tokens. No files updated."
Stop after reporting — do not write any files if nothing changed.

### Step 4: Confirm Before Writing

For any DEPRECATED or RENAMED tokens, pause and ask the user to confirm:

`[CONFIRMATION REQUIRED] {N} tokens will be deprecated or renamed. These changes may break components that reference them. Type "confirm" to proceed, or "cancel" to stop.`

Do not proceed until explicit confirmation is received.
ADDED and CHANGED tokens do not require separate confirmation — they are included in the overall diff shown in Step 3.

#### RENAMED + DEPRECATED Simultaneously

If a token appears as both RENAMED (old name → new name) and DEPRECATED (old name removed):
- Treat it as **RENAMED only**. Deprecation is implied by the rename — do not create a separate DEPRECATED entry for the old name.
- In the changelog, use the `#### Renamed` section and append: `"Old name deprecated — do not use."`
- Do not produce a duplicate entry in `#### Deprecated` for the same token.

#### Processing Order (when multiple change types coexist)

Apply changes in this strict order to avoid reference conflicts:

1. **RENAMED** — update key references first so subsequent steps use the new names
2. **ADDED** — add new tokens to the processed set
3. **CHANGED** — update values for existing tokens
4. **DEPRECATED** — mark and wrap in deprecation comment last (after all renames are resolved)

### Step 5: Generate Processed Output Files

After confirmation, write to `design/tokens/processed/`:

**JSON** (`design/tokens/processed/{category}.json`):
- Flat key-value structure: `{ "color.primary.500": "#1A56DB" }`
- Include a `_meta` block at the top:
  ```json
  {
    "_meta": {
      "generatedAt": "YYYY-MM-DD",
      "sourceFile": "design/tokens/raw/{filename}",
      "version": "N"
    }
  }
  ```

**CSS Custom Properties** (`design/tokens/processed/{category}.css`):
- Output as `:root { --color-primary-500: #1A56DB; }`
- Convert `.` to `-` in token names for CSS variable syntax
- Wrap deprecated tokens in a comment: `/* DEPRECATED: use color.primary.500 */`

### Step 6: Identify Affected Specs

Scan `design/specs/` for any spec documents that reference changed or deprecated token names.
List them in the changelog entry so the designer knows which specs need updating.

### Step 7: Write Changelog Entry

Append a new entry to `docs/design-system/changelog.md` following the convention in `rules/convention/design-system-changelog.md`.

### Step 8: Confirm and Summarize

Output a summary:

```
Token Update Complete — {YYYY-MM-DD}

Files written:
  design/tokens/processed/{category}.json
  design/tokens/processed/{category}.css

Changes:
  Added: N | Changed: N | Deprecated: N | Renamed: N

Specs referencing changed tokens:
  design/specs/{component-name}/{date}.md — references {token.name}

Changelog entry added to docs/design-system/changelog.md

Next steps:
  1. Notify engineers of deprecated tokens — see changelog for migration guide
  2. Update affected component specs listed above
  3. Update Storybook / design system docs if applicable
```
