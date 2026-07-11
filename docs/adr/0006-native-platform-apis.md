# ADR 0006 — Native platform APIs evaluation

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

Modern browsers ship primitives that can replace library code: the `<dialog>`
element, the Popover API, CSS anchor positioning, the View Transition API,
scroll-driven animations, and the Web Animations API. We evaluated each against
our browser support matrix (last 2 versions of Chrome/Edge/Firefox/Safari) for
support, accessibility, and bundle cost.

## Decision

| API | Decision | Rationale |
|-----|----------|-----------|
| `<dialog>` + `showModal()` | **Adopt** as the base for `dialog`/`alert_dialog`. | Broad support, native focus trap + top layer + inert background; we enhance focus-return and scroll-lock in the `AuroraDialog` hook. |
| Popover API (`popover` attr) | **Adopt as progressive baseline** for `popover`, with a JS fallback for positioning/older Safari. | Good top-layer + light-dismiss; anchor positioning still maturing. |
| CSS anchor positioning | **Progressive enhancement only.** | Not yet in Firefox/Safari stable; we compute positions in JS (collision flip) and let anchor-positioning take over where supported. |
| View Transitions | **Progressive enhancement** for overview↔detail in `/lab` and route patches. | Chromium-only cross-document today; must never be required. Gated on support + reduced-motion. |
| Scroll-driven animations | **Avoid in core**; only used decoratively in the docs where supported, always with a reduced-motion/no-support fallback. | Uneven support; easy to misuse. |
| Web Animations API | **Use inside hooks** for interruptible open/close (disclosure, drawer) where CSS transitions can't express interruption cleanly. | Well supported; good cleanup story. |

Every positioning dependency and its bundle cost is documented on the relevant
component page.

## Consequences

- We inherit accessibility and correctness from the platform where it's ready.
- We carry a small JS positioning fallback until anchor positioning is universal,
  revisited per the maintenance loop (phase-10).

## Alternatives considered

- **Polyfilling anchor positioning / View Transitions**: too heavy for the
  benefit today. Rejected.
