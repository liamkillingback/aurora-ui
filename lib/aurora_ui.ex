defmodule AuroraUI do
  @moduledoc """
  Aurora UI — a free, MIT-licensed Phoenix LiveView + Tailwind component kit.

  Aurora UI ships 15 cohesive component families as plain `Phoenix.Component`
  function components and a small set of stateful LiveComponents/hooks. Server
  rendered HEEx is always the source of truth; JavaScript only enhances behavior
  that HTML and `Phoenix.LiveView.JS` cannot express safely on their own.

  ## Installing

  Add the dependency and import the components you want. The most common path is
  to import everything in your `html_helpers/0`:

      defp html_helpers do
        quote do
          use AuroraUI
          # ... your existing imports
        end
      end

  `use AuroraUI` imports every family module. If you prefer to keep your bundle
  and namespace tight, import a single family instead:

      import AuroraUI.Components.Actions
      import AuroraUI.Components.Overlay

  ## Design tokens

  Every visual value resolves to a CSS custom property in `assets/css/aurora_ui.css`.
  Consumers override the theme by redefining those properties — no recompile and
  no forked source required. See `docs/tokens.md` and `AuroraUI.Theme`.

  ## JavaScript

  Register the core hooks in your `app.js`:

      import { AuroraHooks } from "aurora_ui"
      const liveSocket = new LiveSocket("/live", Socket, { hooks: { ...AuroraHooks } })

  The command palette, enhanced combobox, advanced motion, and the Three.js scene
  host live in separate entry points that are only imported when their component
  is actually rendered, so a page that uses only a button ships none of them.

  ## Accessibility

  Every component targets WCAG 2.2 AA: complete focus-visible styling, keyboard
  and touch parity, reduced-motion equivalents, forced-colors support, and
  restrained live-region usage. See `docs/accessibility.md`.
  """

  @doc """
  Imports all Aurora UI component families and the theme helpers.

  Intended for a Phoenix app's `html_helpers/0`. For finer-grained control,
  import individual `AuroraUI.Components.*` modules instead.
  """
  defmacro __using__(_opts) do
    quote do
      import AuroraUI.Components.Actions
      import AuroraUI.Components.Field
      import AuroraUI.Components.Choices
      import AuroraUI.Components.Selection
      import AuroraUI.Components.Navigation
      import AuroraUI.Components.Tabs
      import AuroraUI.Components.Overlay
      import AuroraUI.Components.Floating
      import AuroraUI.Components.Feedback
      import AuroraUI.Components.DataDisplay
      import AuroraUI.Components.DataNavigation
      import AuroraUI.Components.Progress
      import AuroraUI.Components.Command
      import AuroraUI.Components.Media
      import AuroraUI.Components.Experience
    end
  end

  @doc "Returns the installed Aurora UI version string."
  @spec version() :: String.t()
  def version, do: unquote(Mix.Project.config()[:version])
end
