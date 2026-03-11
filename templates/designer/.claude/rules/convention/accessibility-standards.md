---
paths: "**/*"
---

# Accessibility Standards

Single source of truth for all accessibility thresholds applied by design-review, spec-handoff, and design-consistency-audit skills.
No skill or config may override the BLOCKER-level entries below.

## Compliance Target

This template targets **WCAG 2.1 Level AA** as the minimum bar.
Level AAA requirements are surfaced as `[NICE-TO-HAVE]` only and do not affect verdict.

## Contrast Ratio Thresholds

| Context | Minimum ratio | WCAG criterion | Severity if violated |
|---------|--------------|----------------|---------------------|
| Normal text (< 18pt regular / < 14pt bold) | 4.5:1 | AA 1.4.3 | **BLOCKER** |
| Large text (≥ 18pt regular / ≥ 14pt bold) | 3:1 | AA 1.4.3 | **BLOCKER** |
| UI components and graphical objects | 3:1 | AA 1.4.11 | **MAJOR** |
| Decorative elements (non-informational) | exempt | — | N/A |
| Enhanced text contrast (AAA) | 7:1 | AAA 1.4.6 | **NICE-TO-HAVE** |

When assessing contrast from a screenshot, state the token pair being evaluated (e.g., `color.neutral.900` on `color.neutral.0`) before scoring. If exact values are unavailable, tag the finding `[CANNOT ASSESS — token values required]`.

## Touch Target Sizes

| Platform | Minimum size | WCAG criterion | Severity if violated |
|----------|-------------|----------------|---------------------|
| Mobile (iOS / Android) | 44×44 px | AA 2.5.5 | **MAJOR** |
| Web (touch-capable device) | 44×44 px | AA 2.5.5 | **MAJOR** |
| Desktop-only (pointer device, no touch) | 24×24 px | — | **MINOR** |

## Keyboard and Focus

| Requirement | Severity if violated |
|-------------|---------------------|
| All interactive elements reachable by Tab | **BLOCKER** |
| Focus order follows visual reading order | **MAJOR** |
| Focus ring visible with sufficient contrast (3:1 against adjacent color) | **MAJOR** |
| Escape dismisses modals, drawers, and tooltips | **MAJOR** |
| Arrow keys navigate within composite widgets (menus, tabs, radio groups) | **MAJOR** |

### Focus Ring Convention (default — override in spec if component-specific)

| Property | Value |
|----------|-------|
| Style | `2px solid` |
| Color token | `color.focus.ring` |
| Offset | `2px` |

## ARIA and Screen Reader

| Requirement | Severity if violated |
|-------------|---------------------|
| All interactive elements have an accessible name (label, aria-label, or aria-labelledby) | **BLOCKER** |
| State changes announced via aria-live or role transition | **MAJOR** |
| Icons used without accompanying text have `aria-label` or `aria-hidden="true"` | **MAJOR** |
| Error messages linked to their input via `aria-describedby` | **MAJOR** |

## Motion and Animation

| Requirement | WCAG criterion | Severity if violated |
|-------------|----------------|---------------------|
| Provide `prefers-reduced-motion: reduce` fallback for all transitions > 5px or > 200ms | AA 2.3.3 | **MAJOR** |
| Content that flashes more than 3 times/second | AA 2.3.1 | **BLOCKER** |

## Severity Reference for A11Y Findings

When assigning severity in `/design-review` or `/design-consistency-audit`, use this table — do not infer severity independently:

| Finding type | Severity |
|-------------|---------|
| AA contrast violation (text) | **BLOCKER** |
| AA contrast violation (UI component) | **MAJOR** |
| Touch target below minimum (touch device) | **MAJOR** |
| Touch target below minimum (desktop-only) | **MINOR** |
| Missing keyboard access to interactive element | **BLOCKER** |
| Focus ring absent or below contrast threshold | **MAJOR** |
| Missing accessible name | **BLOCKER** |
| State change not announced | **MAJOR** |
| Motion not respecting reduced-motion | **MAJOR** |
| Flashing content | **BLOCKER** |
| AAA violation only | **NICE-TO-HAVE** |

## Relationship to Other Files

- `/design-review` skill: references this file for all `[A11Y]` severity assignments
- `/spec-handoff` skill: references this file for the Accessibility section of component specs
- `/design-consistency-audit` skill: applies contrast and target size checks from this file
- `rules/config/design-tools.md`: may specify project-specific platform targets (web/iOS/Android) that affect touch target thresholds
