# Snippet: a confirmation dialog wired with the AuroraDialog hook.
defmodule AuroraUI.Snippets.OverlayDialog do
  use Phoenix.Component
  import AuroraUI.Components.Overlay
  import AuroraUI.Components.Actions

  def example(assigns) do
    ~H"""
    <.dialog id="confirm-delete" open={@open}>
      <:title>Delete project?</:title>
      <:description>This action can't be undone.</:description>
      <:footer>
        <.button variant="danger" phx-click="delete">Delete</.button>
      </:footer>
    </.dialog>
    """
  end
end
