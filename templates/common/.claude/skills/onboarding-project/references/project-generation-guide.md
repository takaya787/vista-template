# Project Generation Guide

Rules for generating `.vista/profile/project.json` and `.vista/profile/project.md` from the project interview.

## When to Generate

- **First time:** Handled by the Electron app after the owner completes the project interview (at least Phase 1–2 and `currentInitiatives` required questions answered). The app writes `project.json`, generates `project.md`, and updates `CLAUDE.md`.
- **Update:** When the owner requests to update project details via `/onboarding-project`, Claude collects only the changed fields and regenerates `project.md`.

## No Auto-Detection

This profile is for business users, not developers. There are no files to auto-detect from (no package.json, Cargo.toml, etc.). All fields are collected via the Electron app UI.

## Field Mapping — JSON → project.md

| JSON key | project.md section | Notes |
|----------|--------------------|-------|
| `company.name` | H1 title: `# 業務コンテキスト: {name}` | Required |
| `company.description` | Blockquote under title | Required |
| `company.industry` | 基本情報 table | Use label from Industry Labels table |
| `myWork.domain` | 基本情報 table | Required |
| `currentInitiatives` | 基本情報 table | Required |
| `myWork.products` | 担当業務 section | Required |
| `myWork.keyMetrics` | 担当業務 section | Omit line if missing |
| `stakeholders.internal` | 関係者 section | Omit section if both stakeholder fields missing |
| `stakeholders.external` | 関係者 section | Omit if missing |
| `businessTerms` | 業界・社内用語 section | Omit section if missing |
| `neverDo` | Claude への制約・禁止事項 section | Omit section if missing |
| `references` | 参考資料 section | Omit section if empty or missing; render each item as a list entry |

## Industry Label Lookup

| value | label |
|-------|-------|
| `tech` | IT・テクノロジー・SaaS |
| `finance` | 金融・保険・フィンテック |
| `retail_ec` | 小売・EC・消費財 |
| `manufacturing` | 製造・メーカー |
| `healthcare` | 医療・ヘルスケア・製薬 |
| `consulting` | コンサルティング・専門サービス |
| `media_ad` | メディア・エンタメ・広告 |
| `real_estate` | 不動産・建設 |
| `education` | 教育・人材 |
| `government` | 行政・公共・NPO |

## project.md Template

Generate `.vista/profile/project.md` using this structure:

```markdown
# 業務コンテキスト: {company.name}

> {company.description}

## 基本情報

| 項目 | 内容 |
|------|------|
| 業界 | {company.industry_label} |
| 担当部署・役割 | {myWork.domain} |
| 現在の重点課題 | {currentInitiatives} |

## 担当業務

**担当商品・サービス・業務:**
{myWork.products}

**主要指標（KPI）:**
{myWork.keyMetrics}

## 関係者

- **社内:** {stakeholders.internal}
- **社外:** {stakeholders.external}

## 業界・社内用語

{businessTerms}

## Claude への制約・禁止事項

{neverDo}

## 参考資料

{references — render each item as: "- [{label}]({value})" for url type, "- {label}: `{value}`" for file type}

---
_Generated from `.vista/profile/project.json` on {YYYY-MM-DD}. Update via `/onboarding-project`._
```

Omit sections entirely when their corresponding fields are not present in `project.json`. Do not render empty sections or placeholder text.

## Write Sequence (App responsibility for initial setup)

On first setup, the Electron app:

1. **`.vista/profile/project.json`** — Write the raw JSON with `isOnboardingCompleted: true`.
2. **Run `claude -p "/apply-project-profile"`** — This one-shot command generates all remaining files:
   - `.vista/profile/project.md` — generated from project.json using the template below
   - `CLAUDE.md` — Key References row added
   - `rules/config/always.md` — active load instruction appended

This mirrors the `apply-profile` pattern for `me.json`.

## Update Behavior (Claude responsibility)

When the owner re-runs `/onboarding-project` on an existing `project.json`:

1. Read the existing `project.json` and display current values:
   > "現在の業務コンテキスト（{company.name}）:
   > - 担当: {myWork.domain}
   > - 現在の重点課題: {currentInitiatives}
   >
   > 更新したい項目はありますか？"
2. Collect only the fields the owner wants to change via `AskUserQuestion` (do not re-ask all questions)
3. Merge the updated fields into the existing JSON (do not overwrite unchanged fields)
4. Regenerate `project.md` from the merged JSON
5. Do NOT update `CLAUDE.md` or `isOnboardingCompleted` on updates — they are already set

## Learning During Sessions

If Claude learns new context not in `project.json` during a work session (e.g., a new stakeholder mentioned, a constraint revealed, a term explained), offer to update `project.json` at the end of the session and regenerate `project.md`.

Present discovered fields in plain language:
> "今日の作業で、{field}を把握しました。プロジェクトプロフィールに追加してもよいですか？"
