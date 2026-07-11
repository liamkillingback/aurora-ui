# Dependency inventory

Every dependency Aurora UI ships, bundles, or relies on — with its license and
purpose — plus the docs-only assets used by the demo. This is the detailed
companion to [`../NOTICE.md`](../NOTICE.md) and is kept aligned with it; any new
runtime dependency requires an ADR under [adr/](adr/) and an update to both files
in the same PR ([ADR-0006](adr/0006-native-platform-apis.md),
[`../AGENTS.md`](../AGENTS.md)).

Aurora UI is engineered for the **smallest possible dependency and attribution
surface**: the shipped Hex package has only two hard runtime dependencies, and
they are the Phoenix rendering stack it produces markup for. Everything else is
either an *optional* JS peer, tooling that never ships to consumers, or an asset
used only by the documentation demo.

## Runtime dependencies of the library (`aurora_ui` Hex package)

Source of truth: [`../mix.exs`](../mix.exs) `deps/0`.

| Dependency | Version req | License | Ships to consumers? | Why |
|---|---|---|---|---|
| `phoenix_live_view` | `~> 0.20 or ~> 1.0` | MIT | Yes | The rendering / LiveView runtime Aurora UI produces markup and hooks for. |
| `phoenix_html` | `~> 3.3 or ~> 4.0` | MIT | Yes | Safe HTML rendering primitives (escaping, form helpers). |

That is the entire hard runtime surface. The library ships **no** fonts, icon
fonts, images, analytics, or tracking code
([ADR-0009](adr/0009-analytics-and-email.md); verified by a
network/analytics grep test in phase-08). Component examples reference the
consumer's own icon set.

## Optional peer dependency (JavaScript — Experience family only)

| Package | License | Bundled into core? | Notes |
|---|---|---|---|
| `three` | MIT | **No** | Imported only by `assets/js/three/scene.js`, reached solely through the lazy `AuroraSceneHost` hook when a `scene_host/1` renders and WebGL is available. Declared an **optional peer dependency**; a bundle-composition test asserts `import three` never appears in core ([ADR-0007](adr/0007-threejs.md)). |

Consumers who never render a scene host pay nothing for Three.js — no bytes, no
peer install required.

## Dev / docs / test tooling (never shipped to consumers)

All scoped to non-`:prod` environments in [`../mix.exs`](../mix.exs); excluded
from the published package `files` list.

| Dependency | Version req | Scope | License | Purpose |
|---|---|---|---|---|
| `jason` | `~> 1.2` | `:dev, :test, :docs` | Apache-2.0 | JSON encode/decode for tooling and tests. |
| `floki` | `>= 0.30.0` | `:test` | MIT | HTML parsing for the render tests that assert roles/ARIA/state. |
| `ex_doc` | `~> 0.31` | `:docs` (runtime: false) | Apache-2.0 | Generates the ExDoc HTML documentation. |
| `makeup_elixir` | `~> 0.16` | `:docs` (runtime: false) | BSD-2-Clause | Elixir syntax highlighting in generated docs. |
| `makeup_eex` | `~> 0.1` | `:docs` (runtime: false) | BSD-2-Clause | HEEx/EEx syntax highlighting in generated docs. |

These build/verify/document the library; none are dependencies of the consumer's
application.

## Documentation & demo assets (not part of the library package)

Used only by the `demo/` app (docs, component lab, example app — see
[ADR-0004](adr/0004-catalogue.md)). Consumers may substitute their own.

| Asset | License | Purpose |
|---|---|---|
| Inter typeface | SIL Open Font License 1.1 | Docs UI font; consumers may use system fonts (the `--aui-font-sans` default is a system stack). |
| JetBrains Mono | SIL Open Font License 1.1 | Docs code/mono font (mirrors the `--aui-font-mono` default stack). |
| Lucide icons | ISC | Redistributable icon set used in docs examples only; the library ships no icons. |
| Makeup / Makeup EEx | BSD-2-Clause | Syntax highlighting in generated ExDoc/docs (also listed as docs tooling above). |

The demo app additionally contains the isolated `Demo.Analytics`
(cookieless, self-hostable, Plausible-compatible) and `Demo.Newsletter`
adapters, which are **never** part of the library package and are out of scope for
library security reports — see [privacy.md](privacy.md) and
[ADR-0009](adr/0009-analytics-and-email.md).

## How this stays accurate

- CI runs a dependency + license audit (`mix hex.audit`, `mix deps.audit`, and a
  license allow-list check) on every push — see
  [`../.github/workflows/ci.yml`](../.github/workflows/ci.yml).
- A bundle-composition test asserts the lazy entry points
  (`command`, `motion`, `three`) stay out of the core JS bundle
  ([ADR-0005](adr/0005-javascript-organization.md),
  [ADR-0007](adr/0007-threejs.md); phase-08 evidence).
- Adding any runtime dependency requires an ADR and a synchronized update to
  [`../NOTICE.md`](../NOTICE.md) and this file.
