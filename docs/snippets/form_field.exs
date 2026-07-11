# Snippet: an accessible form field with help + error association.
defmodule AuroraUI.Snippets.FormField do
  use Phoenix.Component
  import AuroraUI.Components.Field

  def example(assigns) do
    ~H"""
    <.input id="email" name="email" type="email" value={@email}
      help="We'll never share it." autocomplete="email" />
    """
  end
end
