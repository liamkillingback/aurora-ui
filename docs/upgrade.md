# Upgrading Aurora UI

Aurora UI is designed for boring, predictable upgrades. This page explains how
upgrades work for the two supported distribution paths, how to read the
changelog, how deprecations are signalled, and the trade-off if you fork a
component.

See [ADR-0001](adr/0001-distribution.md) and
[ADR-0002](adr/0002-source-ownership.md) for the decisions behind this, and
[compatibility.md](compatibility.md) for the SemVer scope and deprecation window.

## The two paths (ADR-0002)

Aurora UI supports two ownership models, and you can mix them per component.

### Package path (the default)

You depend on the packaged `aurora_ui` modules and own only:

1. your **theme** — the `--aui-*` overrides in your CSS, and
2. your **composition** — how you arrange the components.

Upgrading is a version bump plus a changelog read:

```bash
mix deps.update aurora_ui
```

Because the package **never generates or writes into your source**, there is no
file-collision risk and no "did the generator overwrite my edits?" class of bug.
Your theme overrides live in a consumer-owned CSS layer that always wins over
`aui.components` ([ADR-0003](adr/0003-tailwind-and-css.md)), so an upgrade cannot
silently override your theme.

### Copy / fork path (documented and supported)

When you need to change a component's *markup* (not just its theme), copy the
family module into your app:

1. Copy `deps/aurora_ui/lib/aurora_ui/components/<family>.ex` into your app's
   component namespace (e.g. `MyAppWeb.Components.<Family>`).
2. Rename the module.
3. Keep `AuroraUI.Internal` available — either depend on it, or inline the two
   or three small helpers you actually use (`cx/1`, `variant/3`, `id/2`).
4. Preserve the MIT notice and the accessibility behavior (focus, ARIA, states).

Each family's "copy this component" recipe walks through this and is
snippet-checked in CI so it stays correct. At that point **you own that file and
opt out of upstream changes for it** — see the trade-off below.

Aurora deliberately does **not** ship a bespoke mix installer/generator in 0.1
([ADR-0001](adr/0001-distribution.md)): the Hex package plus the copy recipe
covers both audiences with no generator to maintain or secure.

## Reading the changelog

[`../CHANGELOG.md`](../CHANGELOG.md) follows *Keep a Changelog* and the project
uses [SemVer](https://semver.org). The changelog restates the public API surface
(documented `AuroraUI.Components.*` attrs/slots, the `--aui-*` token contract, and
the hook names/DOM contract) so you can scan an upgrade quickly:

- **PATCH** (`0.1.0 → 0.1.1`) — backwards-compatible bug fixes. Update freely.
- **MINOR** (`0.1.x → 0.2.0`) — additive (new components/attrs/slots/tokens/hooks)
  and any *new* deprecations. Old APIs still work; read the "Deprecated" section.
- **MAJOR** — a breaking change to the public surface. Read the "Removed"/"Changed"
  sections and any migration guidance.

Internal modules (`AuroraUI.Internal`) are excluded from SemVer and may change
without a deprecation window — do not build against them directly (if you copied
helpers, you own your copy).

## Deprecation warnings

Per [ADR-0008](adr/0008-versioning-and-support.md), a public API is deprecated for
**at least one minor version** before removal:

1. The minor that deprecates it keeps it working and emits a **compile-time
   warning** (for Elixir attrs/slots) plus a `CHANGELOG.md` entry and an upgrade
   note. So after `mix deps.update`, run `mix compile` and read the warnings.
2. Removal happens no earlier than the next minor (or a major).
3. Markup-breaking changes ship migration guidance and, where feasible, a codemod
   snippet.

Token renames and hook-name/DOM-contract changes follow the same window — a
removed/renamed `--aui-*` token or `data-aui-*` attribute is breaking and is
announced ahead of time.

### Suggested upgrade routine

```bash
mix deps.update aurora_ui
mix compile               # read any deprecation warnings
# review CHANGELOG.md for the versions you crossed
mix test                  # your own suite
```

## The copy/fork trade-off

Copying a component buys **full markup ownership** at the cost of **manual
upstream merges**:

| | Package path | Copied component |
|---|---|---|
| Upgrade effort | `mix deps.update` + changelog read | Manually merge upstream diffs into your fork |
| Bug/a11y fixes | Delivered automatically | You must port them yourself |
| Markup freedom | Theme + composition only | Full control of the HEEx |
| Collision risk | None (package never writes your source) | You own the file; no collision, but no auto-updates |

Because forking is **localized to one file per component**, it is an explicit,
contained decision — copy only the components you truly need to diverge, and keep
everything else on the package path so it keeps improving for free. Theming is
identical on both paths (the shared `--aui-*` token layer), so a copied component
still responds to your theme.

When you copy and modify, re-run the accessibility responsibilities in
[accessibility.md](accessibility.md#safe-consumer-responsibilities) against your
version — you now own its focus, ARIA, and state behavior.
