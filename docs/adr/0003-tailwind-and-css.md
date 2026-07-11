# ADR 0003 — Tailwind integration, CSS layers, and the token contract

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

Aurora UI must work with Tailwind 3.4 and 4.x, must not collide with consumer
classes, must let consumers theme without recompiling, and must let consumer
styles win predictably.

## Decision

1. **Shipped CSS is framework-agnostic.** `assets/css/aurora_ui.css` is plain
   CSS using custom properties and a small set of prefixed component classes. It
   does **not** require Tailwind to be present. Tailwind consumers get an
   optional preset that maps `--aui-*` tokens to Tailwind theme keys
   (`docs/tokens.md`), but the components themselves never depend on Tailwind
   utility classes being generated.
2. **Cascade layers.** All Aurora CSS is authored inside named `@layer`s:
   `aui.reset, aui.tokens, aui.base, aui.components, aui.utilities`. Consumers
   import Aurora *before* their own styles; unlayered consumer CSS and the
   consumer's Tailwind `utilities` layer both win over `aui.components` by the
   cascade-layer precedence rules. This is how a consumer overrides any
   component style without `!important`.
3. **Class prefix.** Every component class is prefixed `aui-` (BEM-ish), so
   there is no collision with Tailwind utilities or consumer classes. Consumers
   pass their own classes via the standard Phoenix global `class` attribute,
   which merges after the component's base classes.
4. **Token contract.** The public theming API is the set of `--aui-*` custom
   properties documented in `docs/tokens.md`. Colors are stored as space-
   separated RGB channel triples so `rgb(var(--aui-x) / <alpha>)` works.
5. **Content scanning.** Because shipped styles are static CSS (not utilities),
   Tailwind's `content` purge does not remove Aurora styles. If a consumer *also*
   uses Aurora's optional Tailwind preset with utility-based recipes, they add
   `deps/aurora_ui/lib/**/*.ex` to their `content` globs (documented).

## Consequences

- No Tailwind version lock-in; works with v3 and v4.
- Deterministic override story via cascade layers.
- Slightly larger shipped CSS than a pure-utility approach, bounded by the CSS
  budget in `docs/evidence/phase-08/performance.md`.

## Alternatives considered

- **Utility-class components** (classes baked into HEEx): forces a Tailwind
  version and a purge config, and makes theming a find-replace. Rejected.
