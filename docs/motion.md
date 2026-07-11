# Motion

Motion in Aurora UI is purposeful and small. It communicates state changes and
spatial relationships; it never demands attention, hijacks scrolling, or moves
focus. Every animation has a reduced-motion equivalent that preserves the state
change without large travel.

## Named motion tokens

All motion resolves to tokens (see [tokens.md](tokens.md)), so timing and easing
stay consistent and are overridable in one place.

### Durations

| Token | Value | Use |
|---|---|---|
| `--aui-dur-1` | `120ms` | Micro-interactions: hover, press |
| `--aui-dur-2` | `180ms` | Small enter/exit (menus, tooltips) |
| `--aui-dur-3` | `240ms` | Overlays (dialog, drawer, popover) |
| `--aui-dur-4` | `360ms` | Emphasis / spatial moves |

### Easings

| Token | Curve | Use |
|---|---|---|
| `--aui-ease-standard` | `cubic-bezier(0.2, 0, 0, 1)` | Default for most transitions |
| `--aui-ease-emphasized` | `cubic-bezier(0.2, 0, 0, 1.2)` | Slight overshoot for arrivals |
| `--aui-ease-exit` | `cubic-bezier(0.4, 0, 1, 1)` | Accelerating exits |

### Distances

| Token | Value |
|---|---|
| `--aui-distance-sm` | `4px` |
| `--aui-distance-md` | `8px` |
| `--aui-distance-lg` | `16px` |

Travel is deliberately short — motion is feedback, not spectacle.

### Stagger

| Token | Value |
|---|---|
| `--aui-stagger` | `40ms` |

`reveal/1` (with `stagger`) and `stagger/1` hand each direct child a `--aui-i`
index; `motion.css` offsets each child's transition by `index * --aui-stagger`.

## The reduced-motion equivalence principle

Reduced motion is an **equivalence**, not merely "slower." When
`prefers-reduced-motion: reduce` is set, a transition must still convey the same
state change — it just drops the large translate/scale travel and collapses to a
near-instant state change or a plain opacity fade.

This is enforced at two levels:

1. **Global backstop** — a top-level `@media (prefers-reduced-motion: reduce)`
   block in [`aurora_ui.css`](../assets/css/aurora_ui.css) caps
   `animation-duration`/`transition-duration` to `0.001ms`, forces
   `animation-iteration-count: 1`, and sets `scroll-behavior: auto` for
   everything under `[data-aui]`.
2. **At the source** — per [`../AGENTS.md`](../AGENTS.md), every component-level
   animation is *additionally* gated on reduced motion in its own CSS, and every
   hook re-reads `prefers-reduced-motion` live (the JS helper `prefersReducedMotion()`
   is not cached, since the OS setting can change while the page is open).

Concretely: the checkbox check still appears (as a dash/tick state change) but
does not "draw"; the switch thumb snaps rather than sliding; a drawer appears in
place rather than sweeping in; the spinner **slows down rather than stopping**,
so it never reads as frozen; `reveal`/`stagger` collapse to a plain fade with
`0ms` stagger.

## The "avoid" list

Per [ADR-0005](adr/0005-javascript-organization.md), [ADR-0006](adr/0006-native-platform-apis.md),
and the prohibited-shortcuts section of [`../AGENTS.md`](../AGENTS.md), Aurora UI
core never does the following:

- **No continuous / ambient global animation.** Nothing loops forever competing
  for attention. Decorative continuous effects (spotlight glow, tilt) are
  pointer-driven, sit behind content, never intercept pointer events, and are
  disabled entirely under reduced motion.
- **No scroll hijacking.** Scroll-driven animations are avoided in core; they are
  used only decoratively in the docs where supported, always with a
  no-support/reduced-motion fallback.
- **No focus-moving animation.** Motion never relocates keyboard focus or steals
  it. The connection-state indicator, toasts, and reveals all announce/appear
  without moving focus.
- **No motion as the only signal.** A state that animates is also expressed by a
  non-motion cue (text, icon, ARIA state), so it is legible with motion off and
  under forced colors.

## How motion is driven: `Phoenix.LiveView.JS` + Experience helpers

Following the JS ladder in [ADR-0005](adr/0005-javascript-organization.md),
motion prefers the lightest mechanism that works:

1. **CSS transitions/keyframes** gated on tokens and reduced motion — the default
   for hover/press/enter/exit.
2. **`Phoenix.LiveView.JS`** for show/hide, class toggles, and simple transitions
   triggered from HEEx — no hook required.
3. **Colocated hooks** for motion that must be *interrupted* cleanly (drawer,
   disclosure open/close), which use the Web Animations API inside the hook so a
   user toggling mid-animation is handled correctly, and play exit transitions
   *before* the element is removed so they never race LiveView DOM patching.

The **Experience** family exposes named enter transitions as `Phoenix.LiveView.JS`
helpers you attach to `phx-mounted` (or any JS command), so consumers get
consistent motion without hand-rolling class choreography:

```heex
<div phx-mounted={AuroraUI.Components.Experience.fade_in()}>…</div>
<div phx-mounted={AuroraUI.Components.Experience.slide_up()}>…</div>
<div phx-mounted={AuroraUI.Components.Experience.scale_in(to: "#panel", time: 240)}>…</div>
```

Each applies an `.aui-anim*` class that drives a keyframe defined in
`motion.css`. Reduced motion is handled entirely in CSS (the
`prefers-reduced-motion: reduce` block caps duration and drops travel to a plain
fade), so the helpers need no runtime branching. Options:

- `:to` — a selector to target instead of the bound element.
- `:time` — how long (ms) the animation class stays applied (default `200`).

For scroll-reveal and pointer effects, use the Experience components directly —
`reveal/1`, `stagger/1`, `spotlight/1`, `tilt/1` — all of which are progressive
enhancements that keep content fully visible and usable without JS. See the
[component matrix](component-matrix.md) and
[`AuroraUI.Components.Experience`](../lib/aurora_ui/components/experience.ex).
