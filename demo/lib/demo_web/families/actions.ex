defmodule DemoWeb.Families.Actions do
  @moduledoc """
  Component-lab stories for the Actions family — the exemplar every other family
  module follows. Each family module lives in `demo/lib/demo_web/families/` and
  exposes `lab/1`, an `~H` render returning a `<div class="demo-stories">` of
  `<.story>` blocks (live preview + copyable HEEx). `DemoWeb.FamilyLive`
  dispatches to the module whose name matches the family slug.
  """
  use DemoWeb, :html

  # Copyable HEEx per story, kept in an attribute so the template has no
  # unindented heredoc lines.
  @code %{
    variants: ~S|<.button variant="primary">Primary</.button>
<.button variant="secondary">Secondary</.button>
<.button variant="ghost">Ghost</.button>
<.button variant="subtle">Subtle</.button>
<.button variant="danger">Danger</.button>
<.button variant="link">Link</.button>|,
    sizes: ~S|<.button size="sm">Small</.button>
<.button size="md">Medium</.button>
<.button size="lg">Large</.button>|,
    icons: ~S|<.button>
  <:icon_start><.icon name="hero-plus" class="size-4" /></:icon_start>
  New project
</.button>|,
    states: ~S|<.button loading>Saving…</.button>
<.button variant="danger" loading>Deleting…</.button>
<.button disabled>Disabled</.button>|,
    full_width: ~S|<.button full_width>Create account</.button>|,
    links: ~S|<.button variant="link" navigate={~p"/docs/getting-started"}>Read the docs</.button>
<.button href="https://hexdocs.pm" variant="secondary">Hex docs</.button>|,
    icon_buttons:
      ~S|<.icon_button label="Edit"><.icon name="hero-pencil-square" class="size-4" /></.icon_button>
<.icon_button label="Delete" variant="danger"><.icon name="hero-trash" class="size-4" /></.icon_button>|,
    group: ~S|<.button_group label="Text style">
  <.button variant="secondary" size="sm">Bold</.button>
  <.button variant="secondary" size="sm">Italic</.button>
</.button_group>|,
    link_text: ~S|Read the <.link_text navigate={~p"/docs/tokens"}>token reference</.link_text>.|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Button variants"
        description="Six visual priorities. Pick by importance, not by color."
        code={@code.variants}
      >
        <.button variant="primary">Primary</.button>
        <.button variant="secondary">Secondary</.button>
        <.button variant="ghost">Ghost</.button>
        <.button variant="subtle">Subtle</.button>
        <.button variant="danger">Danger</.button>
        <.button variant="link">Link</.button>
      </.story>

      <.story
        title="Sizes"
        description="sm, md (default, 44px touch target), and lg."
        code={@code.sizes}
      >
        <.button size="sm">Small</.button>
        <.button size="md">Medium</.button>
        <.button size="lg">Large</.button>
      </.story>

      <.story
        title="With icons"
        description="Leading and trailing icons are decorative (aria-hidden)."
        code={@code.icons}
      >
        <.button>
          <:icon_start><.icon name="hero-plus" class="size-4" /></:icon_start>
          New project
        </.button>
        <.button variant="secondary">
          Continue
          <:icon_end><.icon name="hero-arrow-right" class="size-4" /></:icon_end>
        </.button>
      </.story>

      <.story
        title="Loading & disabled"
        description="A loading button stays focusable and sets aria-busy; it is not swapped for a disabled control."
        code={@code.states}
      >
        <.button loading>Saving…</.button>
        <.button variant="danger" loading>Deleting…</.button>
        <.button disabled>Disabled</.button>
      </.story>

      <.story
        title="Full width"
        description="Stretches to fill its container — useful in forms and cards."
        code={@code.full_width}
      >
        <div style="width:100%;max-width:22rem;">
          <.button full_width>Create account</.button>
        </div>
      </.story>

      <.story
        title="As links"
        description="A button becomes an <a> when navigate/patch/href is set, keeping the same treatment."
        code={@code.links}
      >
        <.button variant="link" navigate={~p"/docs/getting-started"}>Read the docs</.button>
        <.button href="https://hexdocs.pm" variant="secondary">Hex docs</.button>
      </.story>

      <.story
        title="Icon buttons"
        description="Icon-only buttons require a label for a non-visual accessible name."
        code={@code.icon_buttons}
      >
        <.icon_button label="Edit"><.icon name="hero-pencil-square" class="size-4" /></.icon_button>
        <.icon_button label="Delete" variant="danger">
          <.icon name="hero-trash" class="size-4" />
        </.icon_button>
        <.icon_button label="Saving" loading><.icon name="hero-arrow-path" class="size-4" /></.icon_button>
      </.story>

      <.story
        title="Button group"
        description="A cluster of peer actions with role=group. Not for navigation."
        code={@code.group}
      >
        <.button_group label="Text style">
          <.button variant="secondary" size="sm">Bold</.button>
          <.button variant="secondary" size="sm">Italic</.button>
          <.button variant="secondary" size="sm">Underline</.button>
        </.button_group>
      </.story>

      <.story
        title="Link text"
        description="Inline links with consistent underline and focus. External links get rel/target + an SR-only hint."
        code={@code.link_text}
      >
        <p style="color:rgb(var(--aui-text));">
          Read the <.link_text navigate={~p"/docs/tokens"}>token reference</.link_text>
          or the <.link_text href="https://hexdocs.pm/phoenix" external>Phoenix guides</.link_text>.
        </p>
      </.story>
    </div>
    """
  end
end
