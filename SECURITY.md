# Security Policy

## Supported versions

Security fixes are released for the latest minor version line. Aurora UI is a
rendering library with no server, database, network, or authentication surface
of its own, so most security relevance is in **guidance** (teaching safe HEEx)
and **supply chain** (dependencies, published artifacts).

| Version | Supported |
|---------|-----------|
| 0.1.x   | ✅ |

## Reporting a vulnerability

Please report privately. Do **not** open a public GitHub issue for a
vulnerability.

- Preferred: GitHub → **Security → Report a vulnerability** (private advisory).
- Or email **security@phxtemplates.com** with "Aurora UI" in the subject.

Include: affected version, a description, reproduction steps, and impact. We aim
to acknowledge within **3 business days** and to ship or disclose a fix or
mitigation within **30 days**, coordinating disclosure with you.

## Scope

In scope:

- XSS / content-escaping issues in any component's rendered output.
- Unsafe patterns actively taught by our docs or examples (e.g. raw HTML,
  client-only authorization, leaked CSRF).
- Dependency vulnerabilities in the shipped package (`lib`, `assets`, `priv`).
- Integrity of published Hex/npm artifacts and documentation hosting.

Out of scope:

- Vulnerabilities in a consumer application's own code.
- The optional analytics/newsletter adapters, which live only in the demo app
  and are never part of the library package (report those to PHXTemplates).

## Our commitments

- The library ships **no** analytics, tracking, or telemetry.
- Published artifacts are built reproducibly with checksums where the registry
  supports it; see [`docs/adr/0009-analytics-and-email.md`](docs/adr/0009-analytics-and-email.md)
  and the release process in [`CHANGELOG.md`](CHANGELOG.md).
