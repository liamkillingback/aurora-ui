# ADR 0005 — JavaScript organization

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

We must decide how much behavior is JavaScript vs server-driven, and how JS is
structured so that unused behavior never enters a consumer bundle.

## Decision

A strict ladder, applied per behavior:

1. **`Phoenix.LiveView.JS` first.** Show/hide, class toggles, simple
   transitions, and server round-trips use `JS` commands in HEEx — no hook.
2. **Colocated component hooks** for behavior that is inherently client-side and
   component-local (focus trap, roving tabindex, positioning, IntersectionObserver).
   Each hook owns a narrow DOM boundary and cleans up fully.
3. **Shared hooks only for genuinely cross-component concerns** (LiveView
   connection state, copy-to-clipboard).
4. **Separate lazy entry points** for heavy/optional behavior — command palette,
   enhanced combobox, advanced tilt, and the Three.js scene — dynamically
   `import()`ed at mount so they are code-split and absent from any bundle that
   doesn't render them.

Hooks are registered under the `Aurora*` namespace (see `AGENTS.md`). Every hook
guards duplicate mounts, respects reduced motion, and survives LiveView patches.

## Consequences

- Core interactivity works with minimal JS; a button page ships ~0 component JS.
- Heavy features are opt-in by rendering, verified by the bundle-composition test
  (ADR-0007, phase-08 evidence).

## Alternatives considered

- **Everything as global hooks**: bloats bundles and couples components.
  Rejected.
- **A client framework (Alpine/Stimulus)**: adds a runtime dependency for
  behavior LiveView + small hooks already cover. Rejected.
