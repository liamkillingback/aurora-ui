# ADR 0008 — Release identification, compatibility, deprecation, support

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

Consumers need to know what "a version" guarantees, how long a deprecated API
survives, which browsers/runtimes are supported, and the maintenance cadence —
without us inventing staged/roadmap product scope.

## Decision

- **SemVer.** The public API (documented `AuroraUI.Components.*` attrs/slots, the
  `--aui-*` token contract, and the registered hook names/DOM contract) follows
  Semantic Versioning. Internal modules (`AuroraUI.Internal`) are excluded.
- **Compatibility matrix** (also in README): Elixir 1.14–1.20, OTP 25–27, Phoenix
  1.7+, LiveView 0.20 & 1.0, Tailwind 3.4 & 4.x, last 2 versions of the four
  major browsers incl. iOS Safari. CI runs both matrix boundaries.
- **Deprecation window.** A public API is deprecated for at least **one minor
  version** (with compile-time warnings and a changelog + upgrade note) before
  removal in a subsequent minor/major. Markup-breaking changes ship migration
  guidance and, where feasible, a codemod snippet.
- **Security response:** per `SECURITY.md` (ack ≤3 business days, fix/disclose
  ≤30 days).
- **Maintenance cadence:** dependency/browser/a11y/bundle checks on a scheduled
  CI run (phase-10); patch releases as needed, minors on a roughly monthly
  cadence when there is content.

This is a support/compatibility policy, not a feature-staging plan: every
capability in the build plan ships in 0.1.

## Consequences

- Predictable upgrades and clear expectations.
- CI cost of testing two matrix boundaries (accepted).

## Alternatives considered

- **CalVer / rolling**: weaker breaking-change signal for a component API.
  Rejected.
