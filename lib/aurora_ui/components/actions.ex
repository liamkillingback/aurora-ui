defmodule AuroraUI.Components.Actions do
  @moduledoc """
  Actions family — button, icon button, button group, and link treatments.

  Actions are the kit's most-used primitive, so they set the conventions the
  rest of the library follows: finite `variant`/`size` attributes (never a
  stringly-typed style prop), explicit `loading`/`disabled`/`destructive`
  states, global-attribute passthrough, and a single focus-visible ring.

  ## Semantics

  `button/1` renders a real `<button>` (or `<a>` when `navigate`/`href`/`patch`
  is set) so keyboard, form, and assistive-technology behavior come from the
  platform. A loading button stays focusable and announces its busy state with
  `aria-busy`; it is not silently swapped for a disabled control.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @variants ~w(primary secondary ghost subtle danger link)
  @sizes ~w(sm md lg)

  attr :variant, :string,
    default: "primary",
    values: @variants,
    doc: "Visual priority. `primary` for the main action, `danger` for destructive."

  attr :size, :string, default: "md", values: @sizes
  attr :type, :string, default: "button", doc: "button type when rendered as <button>"
  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false, doc: "shows a spinner and sets aria-busy"

  attr :full_width, :boolean, default: false

  attr :href, :string, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil

  attr :rest, :global, include: ~w(form name value download target rel phx-click phx-value-id)

  slot :icon_start, doc: "leading icon; hidden from AT (decorative)"
  slot :icon_end
  slot :inner_block, required: true

  @doc """
  Renders a button. Becomes an `<a>` when `navigate`, `patch`, or `href` is set,
  preserving the same visual treatment and focus behavior.

  ## Examples

      <.button>Save</.button>
      <.button variant="danger" loading={@deleting}>Delete</.button>
      <.button variant="link" navigate={~p"/docs"}>Read the docs</.button>
  """
  def button(assigns) do
    assigns =
      assign(assigns, :class, [
        "aui-btn aui-focusable",
        "aui-btn--#{variant(button_variant_map(), assigns.variant, "primary")}",
        "aui-btn--#{variant(size_map(), assigns.size, "md")}",
        {"aui-btn--block", assigns.full_width},
        {"aui-btn--loading", assigns.loading}
      ])

    ~H"""
    <.link
      :if={link?(assigns)}
      class={@class}
      href={@href}
      navigate={@navigate}
      patch={@patch}
      aria-busy={@loading && "true"}
      aria-disabled={@disabled && "true"}
      {@rest}
    >
      <.button_body {assigns} />
    </.link>
    <button
      :if={!link?(assigns)}
      type={@type}
      class={@class}
      disabled={@disabled}
      aria-busy={@loading && "true"}
      {@rest}
    >
      <.button_body {assigns} />
    </button>
    """
  end

  defp button_body(assigns) do
    ~H"""
    <span :if={@loading} class="aui-btn__spinner" aria-hidden="true"></span>
    <span :if={@icon_start != [] && !@loading} class="aui-btn__icon" aria-hidden="true">
      {render_slot(@icon_start)}
    </span>
    <span class="aui-btn__label">{render_slot(@inner_block)}</span>
    <span :if={@icon_end != []} class="aui-btn__icon" aria-hidden="true">
      {render_slot(@icon_end)}
    </span>
    """
  end

  attr :label, :string, required: true, doc: "accessible name; rendered as aria-label + tooltip"
  attr :variant, :string, default: "ghost", values: @variants
  attr :size, :string, default: "md", values: @sizes
  attr :disabled, :boolean, default: false
  attr :loading, :boolean, default: false
  attr :rest, :global, include: ~w(form name value phx-click phx-value-id type)
  slot :inner_block, required: true, doc: "the icon"

  @doc """
  Icon-only button. Requires `label` for a non-visual accessible name; the icon
  itself is marked decorative.

      <.icon_button label="Close"><.x_icon /></.icon_button>
  """
  def icon_button(assigns) do
    assigns =
      assign(assigns, :class, [
        "aui-btn aui-btn--icon aui-focusable",
        "aui-btn--#{variant(button_variant_map(), assigns.variant, "ghost")}",
        "aui-btn--#{variant(size_map(), assigns.size, "md")}",
        {"aui-btn--loading", assigns.loading}
      ])

    ~H"""
    <button
      type={Map.get(@rest, :type, "button")}
      class={@class}
      disabled={@disabled}
      aria-label={@label}
      aria-busy={@loading && "true"}
      title={@label}
      {@rest}
    >
      <span :if={@loading} class="aui-btn__spinner" aria-hidden="true"></span>
      <span :if={!@loading} class="aui-btn__icon" aria-hidden="true">{render_slot(@inner_block)}</span>
    </button>
    """
  end

  attr :label, :string, default: nil, doc: "group accessible name (role=group)"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Groups related buttons into a single segmented cluster. Use for a small set of
  peer actions, not for navigation (use `tabs` or a `menu` there).
  """
  def button_group(assigns) do
    ~H"""
    <div role="group" aria-label={@label} class="aui-btn-group" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :string, default: nil
  attr :variant, :string, default: "default", values: ~w(default subtle quiet)
  attr :external, :boolean, default: false, doc: "adds rel/target and a visual affordance"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Inline text link with consistent underline, focus, and visited treatment.
  External links get `rel=\"noopener noreferrer\"`, `target=\"_blank\"`, and a
  visually-hidden \"(opens in new tab)\" hint.
  """
  def link_text(assigns) do
    assigns =
      assign(assigns, :class, [
        "aui-link",
        "aui-link--#{assigns.variant}"
      ])

    ~H"""
    <.link
      class={@class}
      navigate={@navigate}
      patch={@patch}
      href={@href}
      target={@external && "_blank"}
      rel={@external && "noopener noreferrer"}
      {@rest}
    >
      {render_slot(@inner_block)}<span :if={@external} class="aui-sr-only">(opens in new tab)</span>
    </.link>
    """
  end

  defp link?(assigns), do: assigns.href || assigns.navigate || assigns.patch

  defp button_variant_map do
    Map.new(@variants, &{&1, &1})
  end

  defp size_map, do: Map.new(@sizes, &{&1, &1})
end
