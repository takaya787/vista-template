---
name: spec-handoff
description: Generate a complete component spec document for engineer handoff. Use when the user says "/spec-handoff", "handoffドキュメント作って", "コンポーネント仕様書", "spec this component", "エンジニアに渡す仕様", or "write a component spec". Proactively trigger when design-review output contains a pre-handoff stage assessment.
---

# Spec Handoff — Component Specification

Generate a complete, engineer-ready component specification document covering all states, props, interactions, accessibility, and responsive behavior.

## Why This Skill Is Needed

The spec document is the primary contract between design and engineering. Vague handoffs produce implementation drift, extra back-and-forth, and QA rework. This skill enforces a complete coverage checklist — every state, every edge case, every accessibility requirement — so engineers can implement without needing to re-open Figma for answers.

## Input Requirements

| Input | Action |
|-------|--------|
| Component name + Figma frame URL | Proceed — use URL as citation, ask user to describe or paste the spec |
| Screenshot(s) in `design/inbox/` | Read images, infer spec content from visual analysis |
| Pasted design spec or notes | Parse directly |
| Existing design review in `docs/design-review/` | Pull context from review findings tagged `[SPEC]` |
| "Spec this" with no component named | `[REQUIRES INPUT]` — Ask: "Which component? Please provide the name and either a Figma URL, screenshot in design/inbox/, or pasted description." and stop |

## Data Sources

1. **Review materials** — `design/inbox/` screenshots or pasted text
2. **Existing design reviews** — `docs/design-review/` for `[SPEC]` findings relevant to this component
3. **Existing specs** — `design/specs/{component-name}/` for prior versions (check for version history)
4. **Design tokens** — `design/tokens/processed/` for exact token values to reference in specs
5. **Design tools config** — `rules/config/design-tools.md` for Figma project URL and handoff tool

## Steps

### Step 1: Establish Component Identity

Confirm with the user:
- Component name (canonical, matches Figma component name if possible)
- Parent product area or design system tier (Foundation / Pattern / Feature)
- Figma frame URL (if available)
- Target platform(s): web / iOS / Android / all
- Engineer assignee or squad (if known — for `assignee` frontmatter)

### Step 2: Audit Existing Specs

Check `design/specs/{component-name}/` for prior versions.
If a prior version exists, note the previous date and increment version. If this is the first spec, version is `v1`.

### Step 3: Extract Spec Content

Analyze provided materials and populate every section of the spec. For any section where information is genuinely unavailable, use `[SPEC REQUIRED: {description of what is needed]` — never omit a section silently or invent values.

Apply coverage checklist:

**States**
- [ ] Default / resting
- [ ] Hover
- [ ] Focused (keyboard)
- [ ] Active / pressed
- [ ] Disabled
- [ ] Loading (if async)
- [ ] Empty (if data-driven)
- [ ] Error
- [ ] Success / confirmation
- Any component-specific states (e.g., selected, expanded, checked)

**Props / API**
- All configurable properties with type, allowed values, and default
- Required vs. optional clearly marked
- Deprecated props labeled `[DEPRECATED]` with migration path

**Interactions**
- Click / tap behavior
- Keyboard navigation: Tab order, Enter/Space/Escape/Arrow key behavior
- Drag or swipe (if applicable)
- Animation: trigger, duration, easing, reduced-motion fallback

**Content**
- Character limits for all text elements
- Overflow behavior (truncation rule, tooltip, wrap)
- Placeholder / empty text
- Localization notes (RTL behavior, string expansion budget)

**Responsive Behavior**
- Breakpoint behavior: what changes at each breakpoint
- Touch target minimum sizes on mobile
- Layout shift rules (stacking, collapsing, hiding)

**Accessibility**
- ARIA role, `aria-label` / `aria-labelledby` pattern
- Screen reader announcement text for state changes
- Minimum contrast ratio (reference `color.{token}` from tokens)
- Focus ring specification (color, offset, width)
- Motion: reduced-motion behavior

**Edge Cases**
- Maximum content length overflow
- Zero / empty state
- Network error or timeout behavior
- Concurrent interaction (e.g., clicking while loading)

### Step 4: Reference Tokens

For every color, spacing, radius, shadow, or typography value in the spec:
- Reference the token name from `design/tokens/processed/` rather than raw hex or pixel values
- Format: `{token.name}` (e.g., `color.primary.500`, `spacing.sm`)
- If no processed token file exists, use `[TOKEN REQUIRED: {description}]`

### Step 5: Write Engineer Notes

Add a dedicated section for implementation guidance that a designer would not naturally include but an engineer needs:
- Which existing component(s) this is built on (if composable)
- Known implementation risks or tricky interactions
- QA checklist items (what to verify in browser / device)
- Links to related components in design system documentation (`rules/config/design-tools.md`)

### Step 6: Save

Save to `design/specs/{component-name}/{YYYY-MM-DD}.md`.
If a prior version exists, do not delete it — both files persist as version history.

Confirm save path with the user and note the Figma link and version in the confirmation message.

## Output Format

```markdown
---
component: <ComponentName>
version: v1 | v2 | ...
date: YYYY-MM-DD
figma: <Figma frame URL or [NOT PROVIDED]>
platform: web | ios | android | all
tier: foundation | pattern | feature
assignee: <engineer name or squad, or [NOT ASSIGNED]>
status: draft | ready-for-dev | in-review
---

## Overview

<One paragraph: what this component is, what user need it serves, and where it appears in the product.>

## States

| State | Description | Visual Reference |
|-------|-------------|-----------------|
| default | ... | Figma frame / section |
| hover | ... | |
| focused | ... | |
| active | ... | |
| disabled | ... | |
| loading | ... | |
| empty | ... | |
| error | ... | |
| success | ... | |

> Add component-specific states below the table as needed.

## Props / API

| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `variant` | `"primary" \| "secondary" \| "ghost"` | `"primary"` | No | Visual style |
| `label` | `string` | — | Yes | Button label text |
| `disabled` | `boolean` | `false` | No | Disables interaction |
| `loading` | `boolean` | `false` | No | Shows loading state |
| `onClick` | `() => void` | — | No | Click handler |

> [SPEC REQUIRED: ...] for any prop not yet defined.

## Interactions

### Mouse / Touch
- Click / tap: <describe behavior>
- Long press: <describe or "n/a">

### Keyboard
| Key | Behavior |
|-----|----------|
| Tab | Moves focus to next interactive element |
| Enter / Space | Triggers action |
| Escape | <describe or "n/a"> |
| Arrow keys | <describe or "n/a"> |

### Animation
| Property | Value | Easing | Reduced-motion fallback |
|----------|-------|--------|------------------------|
| <property> | <duration> ms | <easing> | Instant / no animation |

## Content

| Element | Max length | Overflow behavior |
|---------|-----------|-------------------|
| Label | <N> chars | Truncate with ellipsis + tooltip |
| Sublabel | <N> chars | Wrap to 2 lines max, then truncate |

**Localization**: <RTL notes, string expansion budget as % or chars>

## Responsive Behavior

| Breakpoint | Behavior |
|-----------|---------|
| Mobile (<768px) | <describe layout / size changes> |
| Tablet (768–1024px) | <describe> |
| Desktop (>1024px) | <describe> |

Minimum touch target: 44×44px on mobile.

## Accessibility

| Attribute | Value |
|-----------|-------|
| ARIA role | `button` |
| `aria-label` | Set to `label` prop value when no visible text |
| `aria-disabled` | Set to `"true"` when `disabled` is true |
| Screen reader: state change | Announce "<state description>" on transition |
| Focus ring | 2px solid `color.focus.ring`, offset 2px |
| Contrast (text on bg) | `color.primary.500` on `color.neutral.0` — 4.5:1 minimum |

## Tokens Used

| Property | Token | Fallback (do not use in code) |
|----------|-------|-------------------------------|
| Background | `color.primary.500` | — |
| Text | `color.neutral.0` | — |
| Border radius | `radius.sm` | — |
| Padding (vertical) | `spacing.sm` | — |
| Padding (horizontal) | `spacing.md` | — |
| Font size | `typography.body.md` | — |
| Shadow | `shadow.card` | — |

> Do not hardcode hex or px values. Always reference tokens.

## Edge Cases

| Scenario | Expected behavior |
|----------|-----------------|
| Label exceeds max length | Truncate at <N> chars, show full text in tooltip on hover |
| Loading + clicked again | Second click is ignored; loading persists until resolved |
| Network error | Transition to error state; surface `[SPEC REQUIRED: error message copy]` |
| <Other edge case> | <Behavior> |

## Engineer Notes

- **Built on**: `<BaseComponent>` or "standalone"
- **Known risks**: <any interaction or rendering edge case the engineer should know>
- **QA checklist**:
  - [ ] All states render correctly at all breakpoints
  - [ ] Keyboard navigation follows spec
  - [ ] Screen reader announces state changes correctly
  - [ ] Reduced-motion preference respected
  - [ ] Tokens match — no hardcoded values in implementation
  - [ ] Touch target is minimum 44×44px on mobile
- **Related components**: See `{{DESIGN_SYSTEM_DOC_URL}}` for <ComponentA>, <ComponentB>
- **Handoff tool**: See `rules/config/design-tools.md` → Handoff / Spec Tool

## Changelog

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| v1 | YYYY-MM-DD | <designer name> | Initial spec |
```
