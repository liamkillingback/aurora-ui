# Accessibility

Aurora UI targets **WCAG 2.2 Level AA** by construction, not as an afterthought.
Accessibility is part of the component
[definition of done](../AGENTS.md#component-definition-of-done): a component that
looks right but fails keyboard or screen-reader users is a bug, and accessibility
regressions are triaged ahead of new visual variants.

This page is also published as an ExDoc extra (see `mix.exs`).

## The commitment

- Server-rendered HEEx is the source of truth; JavaScript only *enhances*. Core
  actions never depend on a hook running, so behavior degrades to working HTML.
- Every component ships complete interaction states, correct ARIA roles and
  relationships, and a single visible, unobscured focus ring.
- We target the four major browsers' last two versions (incl. iOS Safari) — see
  [compatibility.md](compatibility.md).

## Per-concern approach

### Focus visibility (WCAG 2.4.7, 2.4.11 Focus Not Obscured)

A single shared focus ring is applied through the `.aui-focusable` class (and
`[data-aui] :focus-visible`), styled once in the base layer: a
`2px solid rgb(var(--aui-ring))` outline with a `2px` offset. Components never
re-declare outlines. Overlays keep the title, close control, and footer pinned
and scroll only the body, so a focused control can never be pushed off-screen
(Focus Not Obscured).

### Keyboard + touch parity (WCAG 2.1.1, 2.5 Pointer)

Every interaction works with a keyboard and with touch, not just a mouse:

- Native controls (`button`, `input`, `select`, `textarea`, `details`,
  `dialog`) are used wherever possible so platform keyboard behavior comes for
  free — the Choices family, Navigation disclosures, tabs' accordion, and the
  overlays all build on native elements.
- Widget patterns that have no native element (tabs, menu, combobox, grid) get
  roving `tabindex`, arrow/Home/End navigation, typeahead, and Escape from their
  hook, following the WAI-ARIA Authoring Practices.
- Tooltips show on hover **and** focus; nothing depends on hover alone.

### Target size (WCAG 2.5.8 Target Size, Minimum)

The `--aui-touch-min` token is `44px`, and `md`-size controls keep a 44px minimum
touch target. Checkboxes/radios/switches render a generous hit area around the
native control. Small-density variants are provided but the default meets the AA
minimum.

### Reduced motion (WCAG 2.3.3 Animation from Interactions)

`prefers-reduced-motion: reduce` is honored as an *equivalence*: state changes
still happen, but large translate/scale travel collapses to a near-instant change
or a fade. Enforced both globally and at each animation's source, and re-read live
by every hook. See [motion.md](motion.md).

### Forced colors / high contrast (WCAG 1.4.3, 1.4.11)

Under `@media (forced-colors: active)` Aurora drops shadows and relies on system
colors while keeping borders, so structure stays legible. Nothing conveys meaning
by color alone — status, severity, sort direction, and stat trends all carry text
and/or an icon in addition to the token color (e.g. `stat` emits visually-hidden
"increased"/"decreased" text and a caret glyph).

### Live-region restraint (WCAG 4.1.3 Status Messages)

The wrong live-region strategy turns an app into a screen reader that will not
stop talking, so announcements are rationed by "loudness":

- **Static** — `alert/1` is rendered once in place. `info`/`success`/`warning`/`neutral`
  use `role="status"` (polite); `danger` or `assertive` uses `role="alert"`. It
  is not a channel we push into, so it announces once and cannot spam.
- **Streaming** — `toast_group/1` is the *one* streaming live region on the page;
  it owns a single `aria-live` politeness and the hook handles pause-on-hover/focus
  and de-duplication so N toasts don't become N competing regions.
- **Ambient** — `connection_state/1` is a single polite region announced once per
  change; `inline_status/1` has no live region and changes silently.

Result-count announcements (`search_results`, `filter_bar`) use a polite,
visually-hidden region so users hear the count without focus moving.

### Dragging alternatives (WCAG 2.5.7 Dragging Movements)

No core interaction *requires* a drag. Anything that could be a drag has a
keyboard/click path: overlays close via buttons/Escape, filters/chips are removed
with real buttons, and there is no drag-only reorder or slider-only control in
core.

### Names, roles, relationships (WCAG 1.3.1, 4.1.2)

- Form controls: `field/1` derives deterministic ids so the label, `aria-describedby`
  help, and `aria-errormessage` error are programmatically associated; errors use
  `role="alert"`.
- Icon-only controls (`icon_button`, dismiss buttons, remove buttons) always take
  an accessible name; decorative icons/SVGs are `aria-hidden`.
- Landmarks: navigation regions are `<nav aria-label>`; search is `role="search"`;
  the current location is `aria-current` (`page`/`step`), never styling alone.
- Interactive cards stretch a single real `<a>` over the surface and forbid nested
  interactive elements (avoiding the WCAG 2.2 name/role trap).

## Testing matrix

Accessibility is verified across the axes in the
[definition of done](../AGENTS.md#component-definition-of-done):

| Axis | What we check |
|---|---|
| Automated render tests | `test/aurora_ui/<family>_test.exs` asserts roles, ARIA wiring, and state attributes with Floki |
| Keyboard | Tab order, roving focus, arrow/Home/End, Escape, Enter/Space activation |
| Screen readers | Names/roles/relationships; live-region behavior; announcement restraint |
| Reduced motion | Every animation has an equivalent; no motion-only signal |
| Forced colors | Structure legible; borders retained; no color-only meaning |
| Light / dark | Both token sets contrast-validated (`test/theme_contrast`) |
| RTL | Logical properties; steps/drawers/segments mirror correctly |
| Zoom | Usable at 200–400% with no content loss or clipping |

Aggregate accessibility, browser, bundle, and visual-regression evidence lives
under [`evidence/`](evidence/).

## Known limitations

- **CSS anchor positioning** is progressive-enhancement only; until it is
  universal, floating elements are positioned by a small JS fallback
  ([ADR-0006](adr/0006-native-platform-apis.md)). With JS disabled, floating
  panels fall back to their default placement rather than collision-flipping.
- **`data_grid/1`** intentionally opts out of native table reading semantics in
  favor of an application keyboard model, and its roving-focus/edit keyboard hook
  is *your* wiring against the documented `data-aui-grid` contract (not shipped in
  core). Prefer the semantic `table/1` unless cells are edited in place.
- **Combobox / command palette** require their (lazy) hook for the full keyboard
  model; without JS they degrade to a server-filtered text input + list, which is
  operable but without active-descendant highlighting.
- **Three.js scene host** conveys its meaning through the always-present
  `semantic` slot; the 3D layer itself is decorative and never the only source of
  information.

## Safe consumer responsibilities

Aurora gets you most of the way, but some things only you can supply:

- **Real `alt` text.** `media/1`/`avatar/1`/`code_block` cannot invent it —
  provide a meaningful `alt` (or `alt=""` for purely decorative images).
- **Accessible names for icon-only controls** you author, and `label`/`caption`
  values where the component asks for them (`icon_button`, `menu`, `table`,
  `dialog` title, etc.).
- **Don't defeat the platform.** Avoid `phx-update="ignore"` on a whole
  interactive component, don't remove the focus ring, and don't put required
  instructions or an action's only label in a `tooltip`.
- **Heading order & landmarks** in the page you compose around these components.
- **Debounce live search** and keep filters/state in the URL where it aids
  shareability and back/forward behavior.
- **Test with your content** at 200–400% zoom, with a keyboard, and with a screen
  reader — especially any component you copy and modify (see [upgrade.md](upgrade.md)).
