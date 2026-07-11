# ADR 0009 — Analytics and email integration with consent

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

We want to measure whether the free kit helps people and to offer opt-in updates,
without putting any tracking in the library or gating the source.

## Decision

- **The library contains no analytics, telemetry, or email code.** Verified by a
  test that greps the shipped package for network/analytics calls (phase-08).
- **Docs-only, privacy-first analytics.** The `demo/` app uses a
  cookieless, IP-anonymized, self-hostable analytics adapter
  (Plausible-compatible interface) recording only aggregate page/interaction
  events — never component content or consumer application data. It is isolated
  behind `Demo.Analytics` and can be disabled with one config flag; the docs
  remain fully functional without it.
- **Email is explicit opt-in.** The newsletter form (docs + README link) uses
  double opt-in, stores only email + consent timestamp + source tag, offers
  one-click unsubscribe, and never puts personal data in referral URLs. Provider
  integration lives in `Demo.Newsletter`, never in the library.
- **Retention & PII boundaries.** Analytics aggregates retained 12 months;
  email leads retained until unsubscribe, then suppressed (not silently
  re-added). Consent proof (timestamp + source) is stored with each lead. Data
  export/deletion on request. Documented in `docs/privacy.md`.

## Consequences

- Zero privacy surface in the library; measurement stays in the demo.
- The funnel is honest and legally clean (GDPR/consent-friendly).

## Alternatives considered

- **Google Analytics in docs**: cookies + PII + third-party sharing. Rejected.
- **Email-gated downloads**: violates the "source is never gated" rule. Rejected.
