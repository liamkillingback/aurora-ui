# Snippet: basic actions. Compiled by `mix aurora.snippets` so the docs can never
# drift from a working component API.
defmodule AuroraUI.Snippets.ActionsBasic do
  use Phoenix.Component
  import AuroraUI.Components.Actions

  def example(assigns) do
    ~H"""
    <.button variant="primary">Save changes</.button>
    <.button variant="secondary">Cancel</.button>
    <.button variant="danger" loading={@deleting}>Delete</.button>
    <.icon_button label="Close"><span aria-hidden="true">×</span></.icon_button>
    """
  end
end
