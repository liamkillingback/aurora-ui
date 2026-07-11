defmodule AuroraUI.Components.Floating do
  @moduledoc """
  Floating family — `menu/1`, `popover/1`, and `tooltip/1`.

  These sit in the top layer next to their anchor. Positioning — collision
  flipping against the viewport edges, working inside scroll containers, staying
  correct at 200–400% zoom, and honoring RTL writing direction — is done by the
  JavaScript hook at runtime; the server renders the semantics and a sensible
  default placement. Each hook also owns light-dismiss (Escape / click-away /
  blur) so the markup below stays declarative.

  ## Choosing between them

  * `menu/1` — a list of **application actions** (`role="menu"`/`menuitem`) with
    roving focus, typeahead, and arrow-key navigation. Not for navigation links —
    use `AuroraUI.Components.Navigation` for those.
  * `popover/1` — richer, **non-modal** interactive content anchored to a
    trigger. Built on the native `popover` attribute for a working baseline,
    then enhanced for positioning.
  * `tooltip/1` — **supplementary** text only, shown on hover *and* focus and
    referenced by `aria-describedby`. Never put required instructions or the
    only copy of an action's label in a tooltip.

  ## DOM contract

  | Component | `phx-hook` | data attributes |
  |---|---|---|
  | `menu` | `AuroraMenu` | `data-aui-menu`, `[role=menuitem]` children |
  | `popover` | `AuroraPopover` | `data-aui-popover`, `data-aui-anchor`, `data-aui-placement` |
  | `tooltip` | `AuroraTooltip` | `data-aui-tooltip`, `data-aui-anchor`, `data-aui-placement` |
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @placements ~w(top bottom start end)

  attr :id, :string, default: nil
  attr :label, :string, required: true, doc: "accessible name for the trigger button"

  attr :placement, :string,
    default: "bottom-start",
    values: ~w(bottom-start bottom-end top-start top-end),
    doc: "preferred placement; the hook flips it on collision"

  attr :variant, :string, default: "secondary", values: ~w(primary secondary ghost subtle)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :rest, :global

  slot :trigger, doc: "custom trigger content; defaults to the label text"

  slot :item, doc: "a menu action (role=menuitem)" do
    attr :on_click, :any, doc: "JS command or event fired when chosen"
    attr :disabled, :boolean
    attr :destructive, :boolean, doc: "styles the item as destructive"
  end

  @doc """
  An actions menu: a trigger button plus a `role="menu"` list of `menuitem`s.

  The hook provides roving `tabindex` focus, `Home`/`End`/arrow navigation,
  first-letter typeahead, Escape to close, and returns focus to the trigger.
  Items are buttons (application actions), never links.

  ## Examples

      <.menu label="Row actions">
        <:item on_click={JS.push("dup", value: %{id: @id})}>Duplicate</:item>
        <:item on_click={JS.push("archive", value: %{id: @id})}>Archive</:item>
        <:item destructive on_click={JS.push("delete", value: %{id: @id})}>Delete</:item>
      </.menu>
  """
  def menu(assigns) do
    base = assigns[:id] || id(nil, "menu")

    assigns =
      assigns
      |> assign(:id, base)
      |> assign(:trigger_id, id(base, "trigger"))
      |> assign(:list_id, id(base, "list"))

    ~H"""
    <div id={@id} class="aui-menu" phx-hook="AuroraMenu" data-aui>
      <button
        id={@trigger_id}
        type="button"
        class={[
          "aui-menu__trigger aui-btn aui-focusable",
          "aui-btn--#{@variant}",
          "aui-btn--#{@size}"
        ]}
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={@list_id}
        data-aui-menu-trigger
        {@rest}
      >
        {if @trigger != [], do: render_slot(@trigger), else: @label}
      </button>
      <div
        id={@list_id}
        class="aui-menu__list"
        role="menu"
        aria-labelledby={@trigger_id}
        data-aui-menu
        data-aui-placement={@placement}
        data-aui-anchor={@trigger_id}
        hidden
      >
        <button
          :for={item <- @item}
          type="button"
          role="menuitem"
          tabindex="-1"
          class={cx(["aui-menu__item", {"aui-menu__item--danger", item[:destructive]}])}
          disabled={item[:disabled]}
          aria-disabled={item[:disabled] && "true"}
          phx-click={item[:on_click]}
        >
          {render_slot(item)}
        </button>
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :label, :string, required: true, doc: "accessible name for the trigger button"

  attr :placement, :string,
    default: "bottom",
    values: @placements,
    doc: "preferred logical placement; the hook flips it on collision"

  attr :variant, :string, default: "secondary", values: ~w(primary secondary ghost subtle)
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :rest, :global

  slot :trigger, doc: "custom trigger content; defaults to the label text"
  slot :inner_block, required: true, doc: "popover panel content"

  @doc """
  A non-modal popover anchored to a trigger, using the native `popover`
  attribute as a progressive baseline (light-dismiss + top layer for free) and
  the hook for anchored positioning.

  Focus behavior works for keyboard, touch, and mouse: opening moves focus into
  the panel when it holds controls, Escape and outside clicks close it, and
  focus returns to the trigger. Because it is non-modal the rest of the page
  stays interactive.

  ## When not to use

  For a required decision use `AuroraUI.Components.Overlay.alert_dialog/1`; for a
  short list of actions use `menu/1`; for a hint use `tooltip/1`.

  ## Examples

      <.popover label="Account">
        <:trigger><.avatar /></:trigger>
        <p>Signed in as jane@acme.com</p>
        <.button variant="ghost" phx-click="sign_out">Sign out</.button>
      </.popover>
  """
  def popover(assigns) do
    base = assigns[:id] || id(nil, "popover")

    assigns =
      assigns
      |> assign(:id, base)
      |> assign(:trigger_id, id(base, "trigger"))
      |> assign(:panel_id, id(base, "panel"))

    ~H"""
    <div class="aui-popover-root" data-aui>
      <button
        id={@trigger_id}
        type="button"
        class={[
          "aui-popover__trigger aui-btn aui-focusable",
          "aui-btn--#{@variant}",
          "aui-btn--#{@size}"
        ]}
        popovertarget={@panel_id}
        aria-haspopup="dialog"
        aria-expanded="false"
        aria-controls={@panel_id}
        data-aui-popover-trigger
        {@rest}
      >
        {if @trigger != [], do: render_slot(@trigger), else: @label}
      </button>
      <div
        id={@panel_id}
        class="aui-popover"
        role="dialog"
        popover="auto"
        aria-label={@label}
        phx-hook="AuroraPopover"
        data-aui
        data-aui-popover
        data-aui-anchor={@trigger_id}
        data-aui-placement={@placement}
      >
        <div class="aui-popover__content">{render_slot(@inner_block)}</div>
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :text, :string, required: true, doc: "supplementary text (not required instructions)"

  attr :placement, :string,
    default: "top",
    values: @placements,
    doc: "preferred placement; the hook flips it on collision"

  attr :rest, :global
  slot :inner_block, required: true, doc: "the trigger element (a focusable control)"

  @doc """
  A tooltip showing supplementary text on hover **and** keyboard focus.

  The panel has `role="tooltip"` and is referenced from the trigger via
  `aria-describedby`, so assistive tech announces it as a description. The hook
  mirrors `aria-describedby` onto the focusable child, positions the tooltip,
  and hides it on Escape/blur.

  ## When not to use

  Never place required instructions, error text, or an interactive control's
  only accessible name in a tooltip — it is supplementary and can be missed by
  touch users.

  ## Examples

      <.tooltip text="Sync runs every 5 minutes">
        <.icon_button label="Sync info"><.info_icon /></.icon_button>
      </.tooltip>
  """
  def tooltip(assigns) do
    base = assigns[:id] || id(nil, "tooltip")

    assigns =
      assigns
      |> assign(:id, base)
      |> assign(:tip_id, id(base, "tip"))

    ~H"""
    <span id={@id} class="aui-tooltip-root" phx-hook="AuroraTooltip" data-aui {@rest}>
      <span class="aui-tooltip__trigger" aria-describedby={@tip_id} data-aui-tooltip-trigger>
        {render_slot(@inner_block)}
      </span>
      <span
        id={@tip_id}
        class="aui-tooltip"
        role="tooltip"
        data-aui-tooltip
        data-aui-anchor={@id}
        data-aui-placement={@placement}
        hidden
      >
        {@text}
      </span>
    </span>
    """
  end
end
