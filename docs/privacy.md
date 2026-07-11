# Privacy

Aurora UI is built so that using it puts **zero** privacy surface in your app.
This page documents the data practices behind the project, formalizing
[ADR-0009](adr/0009-analytics-and-email.md).

## The library contains no analytics, telemetry, or email code

The `aurora_ui` package — everything under `lib`, `assets`, and `priv` that ships
to you — contains **no** analytics, tracking, telemetry, or email integration.
The components make no network calls of their own. This is verified by a test
that greps the shipped package for network/analytics calls (phase-08 evidence),
and it is a prohibited shortcut to add any
([`../AGENTS.md`](../AGENTS.md#prohibited-shortcuts)).

So: rendering an Aurora component never phones home, sets no cookies, and sends no
data anywhere. Any measurement described below happens **only in the documentation
demo app**, never in the library you install.

## Docs-only, privacy-first analytics

The `demo/` app (the docs, component lab, and example app) uses a
privacy-first analytics adapter to understand whether the free kit helps people:

- **Cookieless** and **IP-anonymized**.
- **Self-hostable** (a Plausible-compatible interface).
- Records only **aggregate** page/interaction events — never component content,
  never your application data, never personal identifiers.
- Isolated behind `Demo.Analytics` and disabled with a single config flag; the
  docs remain fully functional with it off.

Google Analytics (cookies, PII, third-party sharing) was explicitly rejected
([ADR-0009](adr/0009-analytics-and-email.md)).

## Email is explicit, double opt-in

The optional newsletter (linked from the docs and the README) is a bonus, never a
gate on the source:

- **Double opt-in** — you confirm via a link before you are ever added.
- **Minimal storage** — only your email, a consent timestamp, and a source tag.
- **One-click unsubscribe**.
- **No personal data in referral URLs** — nothing identifying is leaked in links.
- Provider integration lives in `Demo.Newsletter`, never in the library.

## Retention, deletion, suppression, and consent proof

| Data | Retention / handling |
|---|---|
| Analytics aggregates | Retained **12 months**, then discarded. Aggregate only — not tied to a person. |
| Email leads | Retained until you unsubscribe. On unsubscribe the address is **suppressed** (recorded as opted-out), **not silently re-added** by a later import. |
| Consent proof | A **timestamp + source tag** is stored with each lead, so consent is provable. |
| Export / deletion | Data export and deletion are available **on request**. |

## PII boundaries

- The library handles **no** PII — it renders markup you provide.
- The demo analytics never captures PII (cookieless, IP-anonymized, aggregate).
- The newsletter captures the minimum PII (email + consent metadata) and nothing
  from your usage of the components.
- Vulnerability reports about the analytics/newsletter adapters go to
  PHXTemplates, not the library security process — they are out of scope for the
  package ([`../SECURITY.md`](../SECURITY.md)).

The net effect is an honest, GDPR/consent-friendly funnel: measurement stays in
the demo, the source is genuinely free and never email-gated, and your users'
data never touches Aurora UI.
