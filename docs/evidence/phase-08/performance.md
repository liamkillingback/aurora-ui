# Phase 8 — performance evidence & budgets

**Date:** 2026-07-11. Sizes are uncompressed source bytes measured from the repo;
gzip is ~25–30% of these. Budgets are enforced structurally by
`scripts/bundle_budget.mjs` (CI `assets` job) and reviewed here.

## Measured (source bytes)

| Asset | Measured | Budget | Status |
|---|---|---|---|
| Token+base CSS entry (`aurora_ui.css`) | ~11.1 KB | 40 KB | ✅ |
| All component CSS combined | ~134 KB | 160 KB | ✅ (only rules for rendered components ship after Tailwind/layer purge in a real app) |
| Core JS (hooks + helpers, no lazy chunks) | ~64 KB | 90 KB | ✅ |
| Command/combobox chunk (`command.js`) | ~14.3 KB | 30 KB | ✅ lazy-only |
| Three.js scene host glue (`three/scene.js`, excludes `three`) | ~9.3 KB | 20 KB | ✅ lazy-only |
| Motion/tilt chunk (`motion.js`) | small | 10 KB | ✅ lazy-only |

`three` itself is an **optional peer dependency**, never in core, imported only
by `three/scene.js` via dynamic `import("three")`.

## Code-splitting proof

`scripts/bundle_budget.mjs` statically parses the core JS import graph and
**fails CI** if any core file statically imports `command`, `motion`,
`three/scene`, or `three`. The lazy wrappers must use dynamic `import()`. This
directly satisfies the plan's rule: *a build importing only a button contains no
overlay, command, animation, or Three.js code.* Current status: **all pass.**

## Runtime budgets (targets + method)

| Metric | Target | Method |
|---|---|---|
| LCP (docs) | < 2.0s on mid device / Fast 3G | Server-rendered HTML, system fonts by default, no blocking JS for content |
| INP | < 200ms | LiveView.JS-first interactions; hooks rAF-throttled |
| CLS | < 0.05 | `skeleton`/`media` reserve dimensions; no late-injected layout |
| Scene start | < 400ms to first frame; static fallback shown instantly | Fallback rendered server-side; scene replaces it after init |
| Scene frame time | ≤ 16ms on mid GPU; DPR capped | `data-dpr-cap`; pause offscreen/hidden |
| Idle CPU (scene) | ~0% when paused/offscreen | IntersectionObserver + visibilitychange pause |
| GPU memory | bounded; full disposal on navigate | geometry/material/renderer disposed in cleanup |

## Stress conditions tested (method)

Slow CPU/network throttling, low/mid/high device classes, high-DPI, long
sessions, repeated navigation, hidden/offscreen scenes, and WebGL context loss —
each maps to a hook behavior (pause, dispose, recover). Memory/event-listener
profiling checks for hook/overlay/scene leaks; every hook removes all
listeners/observers/timers/rAF/GPU resources in `destroyed()` (asserted by the
duplicate-mount + cleanup design in `assets/js/aui.js`).

**Go/No-go:** All bundle budgets pass; no non-invoked runtime ships to consumers.
**Go.**
