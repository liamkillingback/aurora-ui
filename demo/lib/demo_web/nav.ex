defmodule DemoWeb.Nav do
  @moduledoc """
  The single source of truth for the docs-app navigation: the 15 Aurora UI
  component families (their slug, name, one-line tagline, and public
  components) and the prose documentation pages.

  Both the persistent sidebar (`DemoWeb.Layouts`) and the component-lab index
  (`/components`) render from these lists, so a family added here appears
  everywhere at once. Family slugs are also the `:family` route param.
  """

  @typedoc "A component family entry."
  @type family :: %{
          slug: String.t(),
          name: String.t(),
          tagline: String.t(),
          module: String.t(),
          components: [String.t()]
        }

  @families [
    %{
      slug: "actions",
      name: "Actions",
      tagline: "Buttons, icon buttons, groups, and link treatments.",
      module: "AuroraUI.Components.Actions",
      components: ~w(button icon_button button_group link_text)
    },
    %{
      slug: "field",
      name: "Field",
      tagline: "Text inputs, textareas, labels, help, and errors.",
      module: "AuroraUI.Components.Field",
      components: ~w(field input textarea label help_text field_error)
    },
    %{
      slug: "choices",
      name: "Choices",
      tagline: "Checkbox, radio group, switch, and segmented control.",
      module: "AuroraUI.Components.Choices",
      components: ~w(checkbox radio_group radio switch segmented_control)
    },
    %{
      slug: "selection",
      name: "Selection",
      tagline: "Native select and an enhanced combobox.",
      module: "AuroraUI.Components.Selection",
      components: ~w(select combobox)
    },
    %{
      slug: "navigation",
      name: "Navigation",
      tagline: "Skip link, navbar, sidebar, breadcrumbs, pagination, steps.",
      module: "AuroraUI.Components.Navigation",
      components:
        ~w(skip_link navbar sidebar sidebar_item sidebar_group breadcrumbs pagination steps)
    },
    %{
      slug: "tabs",
      name: "Tabs & disclosure",
      tagline: "ARIA tabs and native-details accordion.",
      module: "AuroraUI.Components.Tabs",
      components: ~w(tabs accordion)
    },
    %{
      slug: "overlay",
      name: "Overlays",
      tagline: "Dialog, alert dialog, and drawer.",
      module: "AuroraUI.Components.Overlay",
      components: ~w(dialog alert_dialog drawer)
    },
    %{
      slug: "floating",
      name: "Floating",
      tagline: "Menu, popover, and tooltip.",
      module: "AuroraUI.Components.Floating",
      components: ~w(menu popover tooltip)
    },
    %{
      slug: "feedback",
      name: "Feedback",
      tagline: "Alert, toasts, inline status, connection state.",
      module: "AuroraUI.Components.Feedback",
      components: ~w(alert toast_group toast inline_status connection_state)
    },
    %{
      slug: "data-display",
      name: "Data display",
      tagline: "Card, badge, avatar, stat, and description list.",
      module: "AuroraUI.Components.DataDisplay",
      components: ~w(card badge avatar avatar_group stat description_list)
    },
    %{
      slug: "data-navigation",
      name: "Data navigation",
      tagline: "Table, data grid, filter bar, filter chip, empty state.",
      module: "AuroraUI.Components.DataNavigation",
      components: ~w(table data_grid filter_bar filter_chip empty_state)
    },
    %{
      slug: "progress",
      name: "Loading & progress",
      tagline: "Spinner, progress, skeleton, and async state.",
      module: "AuroraUI.Components.Progress",
      components: ~w(spinner progress skeleton async_state)
    },
    %{
      slug: "command",
      name: "Search & command",
      tagline: "Search field, results, and command palette.",
      module: "AuroraUI.Components.Command",
      components: ~w(search_field search_results search_result command_palette)
    },
    %{
      slug: "media",
      name: "Media & content",
      tagline: "Media, gallery, code block, prose, and callout.",
      module: "AuroraUI.Components.Media",
      components: ~w(media gallery code_block prose callout)
    },
    %{
      slug: "experience",
      name: "Experience",
      tagline: "Reveal, stagger, spotlight, tilt, and scene host.",
      module: "AuroraUI.Components.Experience",
      components: ~w(reveal stagger spotlight tilt scene_host)
    }
  ]

  @doc_pages [
    %{slug: "getting-started", title: "Getting started"},
    %{slug: "tokens", title: "Design tokens"},
    %{slug: "motion", title: "Motion"},
    %{slug: "accessibility", title: "Accessibility"},
    %{slug: "liveview", title: "LiveView"},
    %{slug: "compatibility", title: "Compatibility"},
    %{slug: "recipes", title: "Recipes"},
    %{slug: "troubleshooting", title: "Troubleshooting"},
    %{slug: "upgrade", title: "Upgrade"},
    %{slug: "privacy", title: "Privacy"}
  ]

  @doc "All 15 component families, in presentation order."
  @spec families() :: [family()]
  def families, do: @families

  @doc "Look up a single family by its slug. Returns `nil` when unknown."
  @spec family(String.t()) :: family() | nil
  def family(slug), do: Enum.find(@families, &(&1.slug == slug))

  @doc "All prose documentation pages."
  @spec doc_pages() :: [%{slug: String.t(), title: String.t()}]
  def doc_pages, do: @doc_pages

  @doc "Look up a docs page by its slug. Returns `nil` when unknown."
  @spec doc_page(String.t()) :: %{slug: String.t(), title: String.t()} | nil
  def doc_page(slug), do: Enum.find(@doc_pages, &(&1.slug == slug))
end
