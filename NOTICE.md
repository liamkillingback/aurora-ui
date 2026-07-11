# Third-party notices

Aurora UI is MIT-licensed. It is designed to carry the smallest possible
dependency and attribution surface. This file lists everything third-party that
Aurora UI ships, bundles, or relies on at runtime, and the assets used only by
the documentation demo.

## Runtime dependencies of the library (`aurora_ui` Hex package)

| Dependency | License | Why |
|------------|---------|-----|
| `phoenix_live_view` | MIT | The rendering/LiveView runtime Aurora UI produces markup for. |
| `phoenix_html` | MIT | Safe HTML rendering primitives. |

Aurora UI ships **no** fonts, icon fonts, images, analytics, or tracking code in
the library package. Component examples reference the consumer's own icon set;
the docs use a redistributable icon set (below) purely for illustration.

## Optional peer dependency (JavaScript, Experience family only)

| Package | License | Notes |
|---------|---------|-------|
| `three` | MIT | Only imported by `aurora_ui/three` when a `scene_host` is rendered and WebGL is available. Declared as an optional peer dependency; never bundled into core. |

## Documentation & demo assets (not part of the library package)

| Asset | License | Notes |
|-------|---------|-------|
| Inter typeface | SIL Open Font License 1.1 | Docs UI font; consumers may substitute system fonts. |
| JetBrains Mono | SIL Open Font License 1.1 | Docs code/mono font. |
| Lucide icons | ISC | Redistributable icon set used in docs examples. |
| Makeup / Makeup EEx | BSD-2-Clause | Syntax highlighting in generated ExDoc/docs. |

## How we keep this accurate

- CI runs a dependency + licence audit (`mix hex.audit`, `mix deps.audit`, and a
  licence allow-list check) on every push; see
  [`.github/workflows/ci.yml`](.github/workflows/ci.yml).
- The full machine-generated inventory lives in
  [`docs/dependency-inventory.md`](docs/dependency-inventory.md).
- Adding any new runtime dependency requires an ADR under
  [`docs/adr/`](docs/adr/) and an update to this file in the same PR.
