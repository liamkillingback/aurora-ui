# Compatibility & support policy

This is the full support policy for Aurora UI, formalizing
[ADR-0008](adr/0008-versioning-and-support.md). It describes what a version
guarantees, which runtimes and browsers are supported, how long a deprecated API
survives, how security is handled, and the maintenance cadence.

This is a **support/compatibility policy, not a feature-staging plan**: every
capability in the build plan ships in 0.1. Nothing here is a promise of dated
future scope.

## Support matrix

CI runs both boundaries of each range so the edges stay real, not aspirational.

| Dependency | Supported |
|---|---|
| Elixir | 1.14 – 1.20 |
| OTP | 25 – 27 |
| Phoenix | 1.7+ |
| Phoenix LiveView | 0.20 and 1.0 |
| Tailwind | 3.4 and 4.x (optional; tokens are framework-agnostic CSS variables) |
| Browsers | last 2 versions of Chrome, Edge, Firefox, Safari — including iOS Safari |

Notes:

- **Tailwind is optional.** Shipped CSS is plain, framework-agnostic CSS custom
  properties + prefixed classes (see [ADR-0003](adr/0003-tailwind-and-css.md)).
  Aurora works with no Tailwind at all, and with either Tailwind v3.4 or v4.x.
- **LiveView 0.20 and 1.0** are both supported; the `mix.exs` requirement is
  `~> 0.20 or ~> 1.0`.
- **Browser baseline** drives the native-platform decisions in
  [ADR-0006](adr/0006-native-platform-apis.md) (native `<dialog>`, the Popover
  API as a progressive baseline, JS positioning fallback until CSS anchor
  positioning is universal).

## What "the public API" means (SemVer scope)

Aurora UI follows [Semantic Versioning](https://semver.org). The **public API**
is exactly:

1. The documented `AuroraUI.Components.*` function components and their
   attributes and slots.
2. The `--aui-*` CSS custom-property (token) contract in [tokens.md](tokens.md).
3. The registered JavaScript hook names and their DOM contract
   (the `phx-hook` names and `data-aui-*` attributes in
   [`../AGENTS.md`](../AGENTS.md)).

Explicitly **excluded** from SemVer guarantees:

- `AuroraUI.Internal` (shared class/variant/id helpers) — may change without a
  deprecation window.
- Private function components, internal CSS class *implementation* details not
  documented as tokens, and undocumented DOM structure.

Under SemVer, then:

- **MAJOR** — a breaking change to any of the three public surfaces above.
- **MINOR** — additive: new components, attrs, slots, tokens, or hooks; and
  deprecations (with warnings) that do not yet remove anything.
- **PATCH** — backwards-compatible bug fixes.

## Deprecation window

A public API is deprecated for **at least one minor version** before it is
removed:

1. In the minor that deprecates it, the old API keeps working and emits a
   compile-time warning (for Elixir attrs/slots) plus a `CHANGELOG.md` entry and
   an [upgrade note](upgrade.md).
2. Removal happens no earlier than the **next** minor (or a major).
3. Markup-breaking changes ship migration guidance and, where feasible, a codemod
   snippet.

Token renames and hook-name/DOM-contract changes follow the same window — a
removed or renamed `--aui-*` token or `data-aui-*` attribute is a breaking change
and is announced ahead of removal.

When you change a public API in a PR, fill in the **API-change review template**
in [api-inventory.md](api-inventory.md).

## Security response

Handled per [`../SECURITY.md`](../SECURITY.md):

- Report privately (GitHub private advisory, or security@phxtemplates.com with
  "Aurora UI" in the subject) — never in a public issue.
- Acknowledgement target: **≤ 3 business days**.
- Fix or disclosure target: **≤ 30 days**, coordinated with the reporter.
- Security fixes ship for the latest minor line (currently `0.1.x`).

Because Aurora UI is a rendering library with no server/DB/network/auth surface
of its own, security relevance concentrates in **content escaping** (XSS in
rendered output), **guidance** (unsafe patterns taught by docs/examples), and
**supply chain** (dependencies and published-artifact integrity). The
analytics/newsletter adapters are out of scope for the library — they live only
in the demo app (see [privacy.md](privacy.md)).

## Maintenance cadence

Per [ADR-0008](adr/0008-versioning-and-support.md) and the phase-10 maintenance
loop:

- **Scheduled CI** runs dependency, browser, accessibility, and bundle-budget
  checks on a recurring basis, independent of feature work.
- **Patch releases** go out as needed for bug and security fixes.
- **Minor releases** land on a roughly monthly cadence *when there is content* —
  cadence is content-driven, not calendar-mandated.
- Adding any new runtime dependency requires an ADR under [adr/](adr/) and an
  update to [`../NOTICE.md`](../NOTICE.md) in the same PR.

## First-response targets (support, not contract)

From [`../SUPPORT.md`](../SUPPORT.md) — goals for a small maintainer team:

| Item | Target first response |
|---|---|
| Security report | 3 business days |
| Accessibility regression | 5 business days |
| Bug report | 7 business days |
| Feature / component request | 14 business days |

Accessibility and security regressions are triaged **ahead of** new visual
variants.
