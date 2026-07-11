defmodule AuroraUI.Components.Tabs do
  @moduledoc """
  Tabs family — `tabs/1` (ARIA tablist) and `accordion/1` (native disclosure).

  Both components render complete, correct semantics on the server; the hooks
  only add motion and keyboard niceties on top of a baseline that already works
  without JavaScript.

  ## tabs/1

  Renders the WAI-ARIA Tabs pattern: a `role="tablist"` of `role="tab"` buttons,
  each `aria-controls`-linked to a `role="tabpanel"`. The first tab is selected
  on the server. The `AuroraTabs` hook manages roving `tabindex`, Arrow / Home /
  End key handling, and `activation` (`manual` — move focus, select on
  Enter/Space; `auto` — select on focus). Selection is preserved across LiveView
  patches because the hook owns it in the DOM and survives `updated()`. Pass a
  **stable `id`** so the hook target is stable across patches.

  ## accordion/1

  Built on native `<details>`/`<summary>` so expand/collapse, keyboard, and
  in-page-find work with zero JavaScript. The `AuroraDisclosure` hook only
  animates open/close (honouring `prefers-reduced-motion`) and handles
  interruption when a user toggles mid-animation. `type="single"` uses the native
  `<details name>` grouping for exclusive (one-open-at-a-time) behavior.

  ### Deep-link policy

  Because panels are native `<details>`, a browser's "find in page" can reveal
  content in a collapsed panel, and you may open a specific item on load by
  passing `open` on that `:item`. Aurora UI does not auto-open from the URL
  fragment; wire that in your LiveView if you need it, then set `open` server-side.
  """
  use Phoenix.Component

  # ──────────────────────────────────────────────────────────────────────────
  # tabs
  # ──────────────────────────────────────────────────────────────────────────

  attr :id, :string, required: true, doc: "stable id; hook + ARIA targets derive from it"
  attr :label, :string, required: true, doc: "accessible name for the tablist"

  attr :activation, :string,
    default: "manual",
    values: ~w(manual auto),
    doc: "`manual` selects on Enter/Space; `auto` selects on focus"

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "arrow-key axis; sets aria-orientation"

  attr :rest, :global

  slot :tab, required: true, doc: "one tab and its panel" do
    attr :label, :string, required: true, doc: "the visible tab label"
    attr :disabled, :boolean
  end

  @doc """
  An accessible tabbed interface. The first tab renders selected; the
  `AuroraTabs` hook takes over keyboard navigation and keeps the selection stable
  across patches.

  ## Examples

      <.tabs id="settings" label="Settings" activation="manual">
        <:tab label="Profile">…profile fields…</:tab>
        <:tab label="Billing">…billing…</:tab>
        <:tab label="Archived" disabled>…</:tab>
      </.tabs>
  """
  def tabs(assigns) do
    ~H"""
    <div
      id={@id}
      class={["aui-tabs", "aui-tabs--#{@orientation}"]}
      phx-hook="AuroraTabs"
      data-aui-activation={@activation}
      {@rest}
    >
      <div
        role="tablist"
        class="aui-tabs__list"
        aria-label={@label}
        aria-orientation={@orientation}
      >
        <button
          :for={{tab, index} <- Enum.with_index(@tab)}
          type="button"
          role="tab"
          id={"#{@id}-tab-#{index}"}
          class="aui-tabs__tab aui-focusable"
          aria-selected={(index == 0 && "true") || "false"}
          aria-controls={"#{@id}-panel-#{index}"}
          tabindex={(index == 0 && "0") || "-1"}
          disabled={tab[:disabled]}
        >
          {tab[:label]}
        </button>
      </div>

      <div
        :for={{tab, index} <- Enum.with_index(@tab)}
        role="tabpanel"
        id={"#{@id}-panel-#{index}"}
        class="aui-tabs__panel"
        aria-labelledby={"#{@id}-tab-#{index}"}
        tabindex="0"
        hidden={index != 0}
      >
        {render_slot(tab)}
      </div>
    </div>
    """
  end

  # ──────────────────────────────────────────────────────────────────────────
  # accordion
  # ──────────────────────────────────────────────────────────────────────────

  attr :id, :string, required: true, doc: "stable id; item ids + single-open group derive from it"

  attr :type, :string,
    default: "multiple",
    values: ~w(multiple single),
    doc: "`single` allows only one open item (native <details name> grouping)"

  attr :rest, :global

  slot :item, required: true, doc: "one collapsible section" do
    attr :title, :string, required: true, doc: "the summary / trigger label"
    attr :open, :boolean, doc: "render this item expanded"
  end

  @doc """
  A stack of collapsible sections built on native `<details>`. Works fully
  without JavaScript; the `AuroraDisclosure` hook only animates the open/close.
  Set `type="single"` for an exclusive accordion.

  ## Examples

      <.accordion id="faq" type="single">
        <:item title="What is Aurora UI?">A free Phoenix component kit.</:item>
        <:item title="Is it accessible?" open>Yes — WCAG 2.2 AA.</:item>
      </.accordion>
  """
  def accordion(assigns) do
    ~H"""
    <div class="aui-accordion" data-aui-accordion {@rest}>
      <details
        :for={{item, index} <- Enum.with_index(@item)}
        id={"#{@id}-item-#{index}"}
        class="aui-accordion__item"
        name={@type == "single" && @id}
        open={item[:open]}
        phx-hook="AuroraDisclosure"
      >
        <summary class="aui-accordion__trigger aui-focusable">
          <span class="aui-accordion__title">{item[:title]}</span>
          <span class="aui-accordion__icon" aria-hidden="true"></span>
        </summary>
        <div class="aui-accordion__panel">
          <div class="aui-accordion__content">{render_slot(item)}</div>
        </div>
      </details>
    </div>
    """
  end
end
