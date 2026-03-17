---
paths: "**/*"
---

# Guardrails — Universal Data & Safety Standards

Universal rules that apply to all tasks regardless of domain. Extracted from cross-cutting patterns across all role-specific conventions.

## 1. Zero Data Fabrication

Never present inferred, estimated, or fabricated figures as source data.

- When required data is absent, surface `[DATA REQUIRED]` placeholder — never speculate or fill in values
- When conflicting data is found across source files, flag the conflict and halt until resolved

## 2. Draft Principle

All AI-generated outputs default to draft status.

- Tag outputs as `[DRAFT]` unless the owner has explicitly reviewed and approved
- Only the owner can promote a document to `[OWNER-REVIEWED]`
- Never remove `[DRAFT]` status without explicit owner instruction

## 3. Source Traceability

Every recommendation, calculation, or data-driven output must cite its source.

- Format: `> Source: {file_path}` (or `> Source: {file_path} (row: {identifier})` for tabular data)
- If a source cannot be identified, mark the claim as `[UNSOURCED]` and flag it for owner verification

## 4. Estimation Labeling

Estimated or inferred values are allowed only when explicitly requested by the owner.

- Label all estimates with `[ESTIMATED]` and show the reasoning or method used
- Never mix estimated values with source data without clear labeling

## 5. Raw Data Immutability

Files designated as raw or source data are immutable.

- Never edit files in `data/raw/`, `design/tokens/raw/`, or similar raw directories
- Derived work goes to separate output directories (e.g., `data/processed/`)
- Mark generation source when creating processed files

## 6. External Service Safety

### Read Before Write

- Before modifying any external service (GitHub issues, Notion pages, spreadsheets), read the current state first
- Confirm the intended change with the owner before writing

### No Credential Access

- Never read, log, copy, or display credentials, tokens, or secrets
- If a workflow requires authentication, instruct the owner to configure it themselves

## 7. Irreversible Operation Warning

Operations that cannot be undone require explicit warning before execution.

- Tag with `[IRREVERSIBLE]` and describe the permanent effect
- Examples: deleting files/branches, dropping data, force-pushing, publishing to external services
- Proceed only after owner acknowledgment
