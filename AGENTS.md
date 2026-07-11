# AGENTS.md — Aurora UI build & contribution contract

This file is the authoritative contract for anyone (human or agent) adding or
changing Aurora UI components. `CLAUDE.md` points here. Read it fully before
writing a component.

## What Aurora UI is

A free, MIT-licensed Phoenix LiveView + Tailwind component kit. 15 families,
brand-neutral, accessible (WCAG 2.2 AA), themeable through CSS custom properties,
and removable. Server-rendered HEEx is the source of truth; JavaScript only
enhances. No component in the core may add JS or CSS to a page that does not
render it.

## Commands

```bash
mix deps.get
mix compile --warnings-as-errors   # warnings are errors
mix test                            # ExUnit + Floki render tests
mix format --check-formatted
mix check                           # format + compile + test + snippet freshness
```

Do **not** run `mix` inside a parallel build task that shares `_build` with a
sibling task — write files only; the integrator compiles once at the end.

## Module conventions

- One family per module: `AuroraUI.Components.<Family>` in
  `lib/aurora_ui/components/<family>.ex`.
- `use Phoenix.Component` and `import AuroraUI.Internal`.
- Function names are snake_case verbs/nouns: `button/1`, `radio_group/1`.
- Every `attr` is typed. Use `values:` for finite variants — never a
  stringly-typed `class`-as-style prop. Provide `attr :rest, :global` and
  forward it; `include:` any needed `phx-*`/form attributes.
- Slots are documented with `doc:` and marked `required:` where mandatory.
- Accessible names, descriptions, error ids, and relationships are explicit and
  deterministic. Generate ids with `AuroraUI.Internal.id/2` when a caller does
  not supply one; never random ids that change across patches for hook targets.
- Compose classes with `AuroraUI.Internal.cx/1` (accepts strings, lists,
  `{class, bool}` tuples). Caller `@rest["class"]` — leave Phoenix's default
  global class merge; do not swallow it.
- Public functions get a `@doc` with a purpose line, a "when not to use" note
  where relevant, and at least one `## Examples` HEEx snippet.

## CSS conventions

- Each family owns exactly one file: `assets/css/components/<family>.css`.
  Never edit another family's CSS file or the token file.
- Class prefix is `aui-`. BEM-ish: `.aui-<block>`, `.aui-<block>__<part>`,
  `.aui-<block>--<modifier>`.
- Reference tokens ONLY (never hard-coded colors/sizes). Colors are RGB channel
  triples used as `rgb(var(--aui-…))` so opacity works: `rgb(var(--aui-action) / 0.5)`.
- Every interactive element uses the shared focus ring via the `.aui-focusable`
  class (already styled in base) — do not re-declare outlines.
- Any animation must have a `@media (prefers-reduced-motion: reduce)` equivalent
  that preserves the state change without large translate/scale motion.
- Support `@media (forced-colors: active)` — rely on system colors, keep borders.

### Token reference (all under `:root`, see assets/css/aurora_ui.css)

Colors (RGB triples): `--aui-canvas --aui-surface --aui-surface-raised
--aui-surface-sunken --aui-surface-overlay --aui-text --aui-text-muted
--aui-text-subtle --aui-text-on-action --aui-border --aui-border-strong
--aui-ring --aui-action --aui-action-hover --aui-action-active
--aui-action-subtle --aui-success(-subtle) --aui-warning(-subtle)
--aui-danger(-subtle) --aui-info(-subtle) --aui-data-1..6`.

Scales: `--aui-radius-{xs,sm,md,lg,xl,full}` · `--aui-space-{1..12}` ·
`--aui-text-{xs,sm,base,lg,xl,2xl}` · `--aui-control-{sm,md,lg}` ·
`--aui-touch-min` (44px) · `--aui-measure` · `--aui-z-{sticky,dropdown,overlay,modal,toast,tooltip}`.

Motion: `--aui-dur-{1..4}` · `--aui-ease-{standard,emphasized,exit}` ·
`--aui-distance-{sm,md,lg}` · `--aui-stagger`. Elevation:
`--aui-shadow-{sm,md,lg,ring}`. Fonts: `--aui-font-{sans,mono}`.

Utility already available: `.aui-sr-only` (visually-hidden text).

## JavaScript / LiveView hook contract

Core hooks are registered as `Aurora<Name>` (see `assets/js/index.js`). A
component that needs client behavior sets `phx-hook="Aurora<Name>"` on a stable
DOM id. The DOM contract between HEEx and hooks:

| Component | `phx-hook` | Key data attributes |
|---|---|---|
| dialog | `AuroraDialog` | `data-aui-dialog`, `data-aui-open`, `[data-aui-dialog-close]` on close controls |
| drawer | `AuroraDrawer` | `data-aui-drawer`, `data-aui-side`, `data-aui-modal` |
| popover | `AuroraPopover` | `data-aui-popover`, `data-aui-anchor`, `data-aui-placement` |
| menu | `AuroraMenu` | `data-aui-menu`, `[role=menuitem]` children |
| tooltip | `AuroraTooltip` | `data-aui-tooltip`, `data-aui-anchor`, `data-aui-placement` |
| tabs | `AuroraTabs` | `[role=tab]`, `[role=tabpanel]`, `data-aui-activation` (`auto`/`manual`) |
| accordion | `AuroraDisclosure` | native `<details>` — hook only handles animation/interruption |
| toast | `AuroraToast` | `data-aui-toast-region`, `data-aui-timeout` |
| reveal | `AuroraReveal` | `data-aui-reveal`, optional `data-aui-stagger` on parent |
| spotlight | `AuroraSpotlight` | `.aui-spotlight` sets `--aui-mx/--aui-my`, `data-aui-spot-active` |
| connection | `AuroraConnectionState` | reflects LiveView socket state to `data-aui-conn` |
| copy | `AuroraCopyButton` | `data-aui-copy` = text or `data-aui-copy-target` selector |
| combobox | `AuroraCombobox` | **lazy** → dynamic-imports `./command.js` |
| command palette | `AuroraCommandPalette` | **lazy** → dynamic-imports `./command.js` |
| scene host | `AuroraSceneHost` | **lazy** → dynamic-imports `./three/scene.js` |
| tilt | `AuroraTilt` | **lazy** → dynamic-imports `./motion.js` |

Every hook: guard against duplicate mount, respect `prefers-reduced-motion`,
clean up listeners/observers/timers/RAF in `destroyed()`, and survive
`updated()` (LiveView patch) without losing open/focus/selection state.

## Component definition of done

1. Every relevant state implemented: default, hover, active, focus-visible,
   selected/checked, loading, empty, success, warning, error, disabled,
   readonly, offline/reconnecting — or documented `not applicable`.
2. Keyboard + touch parity; correct ARIA roles/relationships; visible focus.
3. Light/dark, reduced-motion, forced-colors, RTL, 200–400% zoom safe.
4. A test file `test/aurora_ui/<family>_test.exs` rendering each public
   component and asserting the important semantics (roles, aria wiring, states).
5. No hard-coded colors; tokens only. No console errors. No layout shift on load.

## Prohibited shortcuts

- No `phx-update="ignore"` on a whole interactive component to dodge integration.
- No copying proprietary component markup, animation, or trade dress.
- No email gate on source. No analytics or tracking inside the library.
- No global continuous animation, scroll hijacking, or focus-stealing motion.
