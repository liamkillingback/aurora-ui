# Phase 8 — security & privacy evidence

**Date:** 2026-07-11. Aurora UI is a rendering library: no server, DB, network,
or auth surface of its own. Security relevance is (1) escaping in rendered
output, (2) guidance safety, and (3) supply chain.

## Threat model

| Surface | Threat | Mitigation |
|---|---|---|
| Component output | XSS via unescaped interpolation | All dynamic values interpolated through HEEx (`{...}`), which HTML-escapes. `code_block` interpolates `{@code}` (escaped) — no raw path. `media` sanitizes the `ratio` attr against style injection (tested). |
| Unsafe content slots | Consumer injects raw HTML | Components never call `raw/1` on consumer data; docs never teach `raw` on untrusted input. |
| Copied code | Copy path drops the MIT notice / a11y behavior | Copy recipes preserve the notice header and keep semantics; documented. |
| Docs search / analytics | Tracking or PII leakage | No analytics in the library; docs analytics is cookieless, IP-anonymized, self-hostable, one-flag-disable (ADR-0009). |
| Email forms | PII mishandling | Double opt-in, minimal fields, consent proof, suppression on unsubscribe; lives only in the demo (`Demo.Newsletter`), never the library. |
| Dependency supply chain | Malicious/retired dep | Runtime deps limited to `phoenix_live_view` + `phoenix_html`; `three` is an optional peer. CI runs `mix hex.audit`, `mix deps.audit`, `mix deps.unlock --check-unused`, and a licence allow-list. |
| Demo hosting | Secrets in artifacts | `mix phx.gen.secret` for runtime secrets; nothing committed; secret-scan (gitleaks) in CI. |

## Checks run in CI

- **Secret scan:** gitleaks (`secrets` job).
- **Dependency/licence audit:** `mix hex.audit`, `mix deps.audit`, unused-deps check.
- **Escaping/XSS:** render tests assert escaped output; `media` ratio-injection test.
- **Content-Security-Policy:** the scene uses only same-origin assets and WebGL
  (no `eval`, no remote fetch); `docs/troubleshooting.md` documents the CSP the
  demo sets and how a consumer keeps a strict CSP with the kit.
- **Artifact inventory:** the Hex `:files` allow-list ships only `lib`,
  `priv/static`, `assets/css`, `assets/js`, and docs — no caches, build junk,
  analytics creds, or unrelated PHXTemplates code (verified in phase-09 packaging).

## Safe-guidance audit

Examples do not teach: raw HTML on untrusted input, client-only authorization,
leaked CSRF/secrets, or fragile DOM ownership (`phx-update="ignore"` on whole
components is prohibited in `AGENTS.md`).

**Go/No-go:** No unresolved security issue; no analytics/email in the library.
**Go.**
