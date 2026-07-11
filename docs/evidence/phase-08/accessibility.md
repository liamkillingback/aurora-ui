# Phase 8 — accessibility evidence & statement

**Standard:** WCAG 2.2 Level AA. **Scope:** the 15 component families, the docs
catalogue, and representative recipes. **Date:** 2026-07-11.

## Automated results

- **Token contrast linter** (`test/aurora_ui/theme_contrast_test.exs`, runs in
  CI): parses the shipped light/dark tokens and asserts text pairs ≥ 4.5:1,
  state/action/status colors ≥ 3:1 (SC 1.4.11), and structural borders ≥ 1.5:1.
  **Pass** in both themes.
- **Render-level semantics tests** (`test/aurora_ui/*_test.exs`, 180+ assertions):
  every family asserts its load-bearing semantics — roles, `aria-*` wiring,
  name/description association, `aria-sort`, `aria-live` politeness, `role=dialog/
  alertdialog/menu/tooltip/grid/progressbar`, focusable close controls, etc.
  **Pass.**
- **axe-core catalogue smoke** (CI `a11y` job) runs against every lab story and
  each recipe page; zero critical/serious violations is the gate.

## Manual test matrix

| Concern (WCAG 2.2 SC) | Approach | Result |
|---|---|---|
| Keyboard-only operation (2.1.1) | Every interactive component reachable + operable; menus/tabs use roving tabindex; overlays trap and restore focus | Pass |
| No keyboard trap (2.1.2) | Escape + focus-return verified on dialog/drawer/menu/popover | Pass |
| Focus visible (2.4.7) | Single shared `.aui-focusable` ring, 2px + offset, on every control | Pass |
| Focus not obscured (2.4.11 AA, new in 2.2) | Overlays scroll their own content; sticky headers don't cover focused controls | Pass |
| Target size 24×24 min (2.5.8, new in 2.2) | Controls default to ≥44px (`--aui-touch-min`); icon buttons meet min | Pass |
| Dragging alternatives (2.5.7, new in 2.2) | No component requires dragging; where examples show reordering, a button alternative is provided | Pass (by design) |
| Reduced motion (2.3.3) | Global reduced-motion equivalents + per-component gating; scenes render static | Pass |
| Forced colors / high contrast | `forced-colors` media handling; borders retained, shadows dropped | Pass |
| Text spacing (1.4.12) | Components use relative units; no clipping at increased spacing | Pass |
| Reflow / 200–400% zoom (1.4.10) | Logical properties, wrapping, scroll containers for wide content | Pass |
| Contrast (1.4.3 / 1.4.11) | Token linter + manual spot checks | Pass |
| Name/Role/Value (4.1.2) | Native elements first (`<dialog>`, native inputs, `<table>`) | Pass |
| Status messages (4.1.3) | Toast/alert/connection use restrained polite/assertive regions | Pass |
| Accessible authentication (3.3.8, new in 2.2) | Example auth form supports paste + password managers; no cognitive-function test | Pass (example) |

## Screen-reader review

Walked the overlay, menu, tabs, combobox, table, toast, and command-palette
families with keyboard + screen-reader semantics review. Findings folded into the
components (e.g. combobox `aria-activedescendant`, toast politeness split,
table `aria-sort`). Live regions are restrained — streaming/reconnect/toast do
not create announcement noise (verified in `feedback` and `command`).

## Restrained live regions

The kit uses exactly three live-region tiers (documented in
`AuroraUI.Components.Feedback` moduledoc): static `alert` (announce once), one
streaming `toast_group` region, and an ambient connection indicator. No component
announces on every keystroke; result counts debounce.

## Known limitations

- **Combobox / command palette** deliver full behavior only with JavaScript
  enabled; without JS they degrade to a native input + server-filtered list
  (still operable, less rich). Documented in `docs/accessibility.md`.
- **`data_grid`** is an application-grid pattern whose editing keyboard model
  requires the consumer to wire the `AuroraDataGrid` hook; the semantic `table`
  is the accessible default and needs no JS.
- **Three.js scene** is `aria-hidden`; its information is always mirrored in the
  `semantic` slot. No functionality is scene-only.

## Consumer responsibilities

Documented in `docs/accessibility.md`: provide meaningful `alt`/labels, keep
copy readable, don't nest interactives inside an interactive card, don't move
required instructions into a tooltip, and preserve the shipped focus ring.

**Go/No-go:** No unresolved critical/high accessibility issue. **Go.**
