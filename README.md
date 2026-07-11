# Aurora UI

**A free, MIT-licensed Phoenix LiveView + Tailwind UI kit.** 15 cohesive,
accessible, themeable component families with complete interaction states,
purposeful motion, and an optional — separately bundled — Three.js experience
layer. Server-rendered HEEx is always the source of truth; JavaScript only
enhances.

> Aurora UI is built and maintained by [PHXTemplates](https://phxtemplates.com).
> The source is genuinely free and will never sit behind an email gate.

[![CI](https://github.com/liamkillingback/aurora-ui/actions/workflows/ci.yml/badge.svg)](https://github.com/liamkillingback/aurora-ui/actions/workflows/ci.yml)
[![Hex.pm](https://img.shields.io/badge/hex-aurora__ui-6e4a7e)](https://hex.pm/packages/aurora_ui)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

---

## Why Aurora UI

- **Accessible by construction.** Every family targets WCAG 2.2 AA — real focus
  management, keyboard + touch parity, reduced-motion equivalents, forced-colors
  support, and restrained live regions. Not bolted on afterward.
- **Themeable without forking.** Everything visual resolves to a `--aui-*` CSS
  custom property. Override the tokens in your own CSS; no recompile, no patched
  source, no PHXTemplates branding leaking into your app.
- **Pay only for what you render.** Core components are plain
  `Phoenix.Component` functions. The command palette, enhanced combobox, advanced
  motion, and Three.js scene are separate JS entry points loaded lazily — a page
  that renders only a button ships none of them.
- **Removable.** Copy a component into your app and delete the dependency, or use
  the Hex package. Either path is supported and documented.

## Install

Add the dependency:

```elixir
# mix.exs
def deps do
  [
    {:aurora_ui, "~> 0.1"}
  ]
end
```

Import the CSS (before your app layer) and register the hooks:

```css
/* assets/css/app.css */
@import "aurora_ui/aurora_ui.css";
```

```js
// assets/js/app.js
import { AuroraHooks } from "aurora_ui"

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { ...AuroraHooks }
})
```

Make the components available in your HTML helpers:

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    use AuroraUI            # imports all families
    # ...your existing imports
  end
end
```

Prefer a tighter surface? Import one family at a time instead:

```elixir
import AuroraUI.Components.Actions
import AuroraUI.Components.Overlay
```

Then render:

```heex
<.button variant="primary">Save changes</.button>

<.dialog id="confirm" open={@open}>
  <:title>Delete project?</:title>
  <:description>This can't be undone.</:description>
  <.button variant="danger" phx-click="delete">Delete</.button>
</.dialog>
```

See the [full docs & component lab](https://aurora-ui.phxtemplates.com) or run
them locally: `cd demo && mix setup && mix phx.server`.

## The 15 families

| # | Family | Highlights |
|---|--------|-----------|
| 1 | Actions | button, icon button, button group, link treatments |
| 2 | Field | input, textarea, label/help/error, prefix/suffix, char count |
| 3 | Choices | checkbox, radio group, switch, segmented control |
| 4 | Selection | native select, accessible enhanced combobox |
| 5 | Navigation | navbar, sidebar, breadcrumbs, pagination, steps |
| 6 | Tabs & disclosure | tabs, accordion |
| 7 | Overlays | dialog, alert dialog, drawer/sheet |
| 8 | Floating | menu, popover, tooltip |
| 9 | Feedback | alert, toast, inline status, LiveView connection state |
| 10 | Data display | card, badge, avatar, stat, description list |
| 11 | Data navigation | table, data grid, filter shell, empty state |
| 12 | Loading/progress | spinner, progress, skeleton, async/streaming |
| 13 | Search/command | search field, results, command palette |
| 14 | Media/content | aspect media, gallery, code block, prose, callout |
| 15 | Experience | reveal/stagger, spotlight, tilt, Three.js scene host |

## Compatibility

| Dependency | Supported |
|---|---|
| Elixir | 1.14 – 1.20 |
| OTP | 25 – 27 |
| Phoenix | 1.7+ |
| Phoenix LiveView | 0.20 and 1.0 |
| Tailwind | 3.4 and 4.x (tokens are framework-agnostic CSS variables) |
| Browsers | last 2 versions of Chrome, Edge, Firefox, Safari (incl. iOS) |

See [`docs/compatibility.md`](docs/compatibility.md) for the full support policy,
deprecation window, and maintenance cadence.

## Documentation

- [Getting started](docs/getting-started.md) · [Tokens & theming](docs/tokens.md)
  · [Motion](docs/motion.md) · [Accessibility](docs/accessibility.md)
  · [LiveView behavior](docs/liveview.md)
- [Component matrix](docs/component-matrix.md) — every family → variants → states → ARIA → tests
- [Architecture decisions](docs/adr/) · [Changelog](CHANGELOG.md) · [Upgrade guide](docs/upgrade.md)

## Contributing

Read [`AGENTS.md`](AGENTS.md) (the component contract) and
[`CONTRIBUTING.md`](CONTRIBUTING.md). Accessibility and security regressions are
triaged ahead of new visual variants. By participating you agree to the
[Code of Conduct](CODE_OF_CONDUCT.md).

## Stay in the loop (optional)

Want new-component announcements, recipes, and accessibility tips?
[Subscribe to the Aurora UI list](https://phxtemplates.com/aurora-ui/subscribe) —
explicit opt-in, one-click unsubscribe, no tracking pixels. The source is free
regardless; the newsletter is a bonus, never a gate.

## License

MIT © 2026 Liam Killingback and the Aurora UI contributors. See [LICENSE](LICENSE)
and third-party attributions in [NOTICE.md](NOTICE.md).
