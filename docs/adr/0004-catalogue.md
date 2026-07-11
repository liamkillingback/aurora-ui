# ADR 0004 — Component catalogue implementation and hosting

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

We need an interactive catalogue covering every component, state, viewport, and
theme, plus an immersive demo — without adopting a JS component-explorer
(Storybook) that doesn't understand HEEx/LiveView.

## Decision

The catalogue is a **Phoenix LiveView application in `demo/`** that depends on
the library via a path dependency. This doubles as the install proof (ADR-0001)
and lets stories be real LiveViews with real interaction, reconnect, and streams
— not static snapshots.

- Each family has a catalogue route rendering every variant/state with live
  theme, motion-preference, viewport, locale, and direction controls.
- Example code shown on each page is read from compiled, tested snippet modules
  so it cannot drift (enforced by `mix aurora.snippets --check` in CI).
- Hosting: static-friendly server-rendered pages deployed to Fly.io at
  `aurora-ui.phxtemplates.com`. URLs are stable, deep-linkable, canonical, and
  work without client navigation (each route renders fully server-side).
- The immersive constellation lives at a dedicated `/lab` route and never blocks
  or hides docs content (ADR-0007).

## Consequences

- One codebase proves installation, powers docs, and hosts the demo.
- No Storybook/JS-explorer maintenance or HEEx-mismatch risk.

## Alternatives considered

- **Storybook / a JS explorer**: doesn't render HEEx or exercise LiveView.
  Rejected.
- **Static site generator**: can't show real LiveView reconnect/streams.
  Rejected for the lab; acceptable for prose-only pages, which we still render
  server-side in the same app for consistency.
