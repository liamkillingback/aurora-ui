# Getting started

Aurora UI is a free, MIT-licensed Phoenix LiveView + Tailwind component kit: 15
component families rendered as plain `Phoenix.Component` functions, themed
through CSS custom properties, and enhanced (never replaced) by a small set of
LiveView hooks. This page takes you from an empty Phoenix app to your first
rendered component.

If you only read one other document, read [`../AGENTS.md`](../AGENTS.md) — it is
the authoritative contract for how the components behave.

## Prerequisites

Aurora UI targets a standard Phoenix + LiveView stack. See
[compatibility.md](compatibility.md) for the full matrix; the short version:

| Dependency | Supported |
|---|---|
| Elixir | 1.14 – 1.20 |
| OTP | 25 – 27 |
| Phoenix | 1.7+ |
| Phoenix LiveView | 0.20 and 1.0 |
| Tailwind | 3.4 and 4.x (optional — tokens are framework-agnostic CSS variables) |
| Browsers | last 2 versions of Chrome, Edge, Firefox, Safari (incl. iOS) |

Tailwind is **not required**: Aurora UI ships framework-agnostic CSS. If you use
Tailwind you get an optional preset (see [tokens.md](tokens.md)), but the
components never depend on Tailwind utilities being generated.

## 1. Add the dependency

```elixir
# mix.exs
def deps do
  [
    {:aurora_ui, "~> 0.1"}
  ]
end
```

```bash
mix deps.get
```

## 2. Import the CSS

Import Aurora UI's stylesheet **before** your own app layer, so your styles win
predictably by the cascade-layer rules (see
[ADR-0003](adr/0003-tailwind-and-css.md)):

```css
/* assets/css/app.css */
@import "aurora_ui/aurora_ui.css";

/* ...your own styles come after... */
```

The stylesheet is authored in named cascade layers
(`aui.reset, aui.tokens, aui.base, aui.components, aui.utilities`). Unlayered
consumer CSS and your Tailwind `utilities` layer both beat `aui.components`, so
you can override any component style without `!important`.

## 3. Register the JavaScript hooks

The core hooks are exported as `AuroraHooks` from the package's JS entry point.
Spread them into your `LiveSocket`:

```js
// assets/js/app.js
import { AuroraHooks } from "aurora_ui"

const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: { ...AuroraHooks }
})
```

`AuroraHooks` registers the core hooks (`AuroraDialog`, `AuroraDrawer`,
`AuroraPopover`, `AuroraMenu`, `AuroraTooltip`, `AuroraTabs`,
`AuroraDisclosure`, `AuroraToast`, `AuroraReveal`, `AuroraSpotlight`,
`AuroraConnectionState`, `AuroraCopyButton`) plus lazy wrappers
(`AuroraCombobox`, `AuroraCommandPalette`, `AuroraSceneHost`, `AuroraTilt`) whose
real implementations are code-split and imported only when the matching
component is rendered. A page that renders only a button ships no component JS.
See [liveview.md](liveview.md) for the full hook model.

## 4. Make the components available

The most common path is to import every family in your web module's
`html_helpers/0`:

```elixir
# lib/my_app_web.ex
defp html_helpers do
  quote do
    use AuroraUI            # imports all 15 families
    # ...your existing imports
  end
end
```

Prefer a tighter surface? Import one family at a time instead:

```elixir
import AuroraUI.Components.Actions
import AuroraUI.Components.Overlay
```

Every `AuroraUI.Components.*` module is a normal `Phoenix.Component`, so you can
import exactly the families you use.

## 5. Render your first component

```heex
<.button variant="primary">Save changes</.button>

<.dialog id="confirm" open={@open} on_close={JS.push("close")}>
  <:title>Delete project?</:title>
  <:description>This can't be undone.</:description>
  <:footer>
    <.button variant="ghost" data-aui-dialog-close>Cancel</.button>
    <.button variant="danger" phx-click="delete">Delete</.button>
  </:footer>
</.dialog>
```

To pick up Aurora's canvas/text/font defaults on a region, add `data-aui-root`
to a wrapping element (e.g. your `<body>` or layout root). Individual components
carry their own styles regardless.

## Where to go next

- [tokens.md](tokens.md) — the complete `--aui-*` token reference and how to
  theme without forking.
- [accessibility.md](accessibility.md) — the WCAG 2.2 AA commitment and per-concern approach.
- [motion.md](motion.md) — named durations/easings and the reduced-motion contract.
- [liveview.md](liveview.md) — the JS ladder, hook DOM contract, and state through patches.
- [component-matrix.md](component-matrix.md) — every family → components → states → ARIA → tests.
- [recipes.md](recipes.md) — real-world patterns (auth form, dashboard, command search, dialogs).
- [troubleshooting.md](troubleshooting.md) — fixes for the common first-run problems.
- [upgrade.md](upgrade.md) — how upgrades and the supported copy path work.

Full docs and the interactive component lab live at
<https://aurora-ui.phxtemplates.com>.
