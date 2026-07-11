# ADR 0001 — Distribution: Hex package + supported copy/vendor path

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

Phoenix component libraries distribute in three common ways: a Hex dependency
(easy upgrades, but consumers can't edit), an installer/generator that copies
source into the app (full ownership, but drifts from upstream), or vendored
source. Consumers told us (see phase-01 research) they want both easy updates
*and* the freedom to fork a component when a design demands it.

## Decision

Aurora UI ships primarily as the **Hex package `aurora_ui`**. In addition we
**support and document a copy/vendor path**: because every component is a plain,
self-contained `Phoenix.Component` function with no cross-module private
coupling beyond `AuroraUI.Internal` (a single small file consumers copy
alongside it), any component can be lifted into a consumer's own
`MyAppWeb.Components` namespace. The docs include a "copy this component" recipe
per family that preserves the MIT notice and accessibility behavior.

We deliberately do **not** ship a bespoke mix installer CLI in 0.1: the Hex
package plus the copy recipe covers both audiences without a generator to
maintain. This is a supported combination, not deferred scope — both paths are
tested in CI (`demo/` uses the path dependency; the example app's "copy" recipe
is snippet-checked).

## Consequences

- Upgrades are a version bump for package users; copy users own their fork and
  merge upstream diffs manually (documented trade-off).
- No generator code to maintain or secure.
- The `--aui-*` token layer is shared by both paths, so theming is identical
  whether a component is imported or copied.

## Alternatives considered

- **Installer/copy CLI only** (shadcn-style): maximum ownership but no clean
  upgrade path and a generator to maintain. Rejected as the sole path.
- **Vendored git submodule**: poor DX in the Elixir ecosystem. Rejected.
