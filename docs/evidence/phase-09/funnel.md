# Phase 9 — ethical conversion funnel

**Principle:** the source is genuinely free and MIT-licensed. Nothing here gates
it. Email is opt-in; premium CTAs are restrained and honest. Implements ADR-0009.

## Open source, no gate

- Repo, docs, install commands, and the component lab are fully public with no
  email wall (Operating-rules requirement).
- README states plainly: "The source is free regardless; the newsletter is a
  bonus, never a gate."

## Email signup (opt-in only)

- **Consent:** double opt-in. Stored fields: email, consent timestamp, source
  tag. Nothing else.
- **Unsubscribe:** one click, in every email; suppression list prevents silent
  re-add.
- **Provider:** integrated in `Demo.Newsletter` (demo app only) — never in the
  library package.
- **Placement:** footer of docs + a single non-blocking README link. Never
  interrupts component use; never implies the free kit is incomplete.

## Onboarding sequence (after opt-in)

A short, useful sequence — help first, sell last:

1. **Install help** — get the kit into a clean Phoenix app; common pitfalls.
2. **Theming** — override `--aui-*` tokens for your brand in ~12 variables.
3. **LiveView interaction recipe** — a real dialog + form + toast flow.
4. **Accessibility recipe** — building an accessible data table + filters.
5. **Advanced experience recipe** — reveal/spotlight and the scene host, with
   the reduced-motion story.
6. **A restrained premium introduction** — one email: "If you want production
   Phoenix starters built on this design language, here's PHXTemplates." Easy to
   ignore; unsubscribing keeps full kit access.

## Premium CTAs

- Appear only at natural points — e.g. the end of a complete application recipe —
  as a quiet card, not a modal or nag.
- Copy never says or implies the free kit is limited.
- Referral links to the commerce template and Unlimited Access carry a
  `?ref=aurora-ui&src=<page>` **tag only** — no personal data in URLs.

## Privacy / data governance

Per `docs/privacy.md`: cookieless aggregate analytics (12-month retention),
email leads retained until unsubscribe then suppressed, consent proof stored,
export/deletion on request, PII boundaries enforced (no component content or
consumer app data ever collected).

## KPIs (privacy-safe)

Measured without collecting component content or personal application data:

- Unique docs users; install-doc completion; approved copy/install events
  (aggregate); GitHub stars/forks/watchers; example usage; issues/PRs; returning
  users; email opt-in rate; tutorial engagement; premium referral conversion.
- Component search terms with no result, and documentation failure points, to
  guide the roadmap.
- Reviewed at 7, 30, and 90 days; roadmap prioritized by observed demand,
  accessibility risk, maintenance cost, and premium relevance.

**Go/No-go:** funnel is opt-in, transparent, privacy-respecting, and never gates
the source. **Go.**
