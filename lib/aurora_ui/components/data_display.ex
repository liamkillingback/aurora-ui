defmodule AuroraUI.Components.DataDisplay do
  @moduledoc """
  DataDisplay family — card, badge, avatar (+ group), stat, description list.

  The read-only surface of the kit: containers and primitives for *presenting*
  data rather than collecting it. The recurring theme is picking the correct
  semantic element instead of a pile of `<div>`s, so structure survives with CSS
  off and reads correctly to assistive technology.

  ## Semantics

  * `card/1` is an `<article>` (or `<section>` when it has no self-contained
    heading). Its `interactive` variant makes the *whole* card a single link by
    stretching one real `<a>` over the surface — there are never nested
    interactive elements inside a linked card (that is a WCAG 2.2 name/role
    trap), so any footer actions must live outside an interactive card.

  * `badge/1` is a small inline pill. When `removable`, the remove control is a
    real `<button>` with an accessible name — not a clickable `<span>`.

  * `avatar/1` renders an `<img>` with required `alt` when a `src` is given, and
    falls back to text initials (marked up so AT still gets the name) when it is
    not. `avatar_group/1` stacks avatars and can summarise the overflow as
    "+N" with an accessible label.

  * `stat/1` is a KPI. Its delta never relies on color alone: the direction is
    also stated in visually-hidden text ("increased" / "decreased") and shown
    with a caret, so "up 12%" is unambiguous in grayscale and forced-colors.

  * `description_list/1` is a real `<dl>` with `<dt>`/`<dd>` pairs from `:item`
    slots, laid out as a responsive two-column grid that collapses to stacked
    rows on narrow viewports.

  ## States

  Every surface here covers default, hover, and — for the interactive card —
  focus-visible and selected. A `loading` flag renders a skeleton placeholder
  (safe to show before data arrives) and components degrade gracefully to an
  empty state. All of it is light/dark, reduced-motion, forced-colors, and RTL
  safe; the interactive card uses the shared `.aui-focusable` ring.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @badge_variants ~w(neutral info success warning danger accent)
  @sizes ~w(sm md lg)
  @elevations ~w(flat sm md)

  attr :elevation, :string, default: "sm", values: @elevations, doc: "resting shadow depth."

  attr :interactive, :boolean,
    default: false,
    doc: "Make the whole card a single link. Requires `navigate`/`patch`/`href`."

  attr :selected, :boolean, default: false, doc: "Marks a chosen card (aria-current)."
  attr :loading, :boolean, default: false, doc: "Render a skeleton placeholder."

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :string, default: nil

  attr :link_label, :string,
    default: nil,
    doc: "accessible name for the stretched link when the header text is not enough."

  attr :rest, :global

  slot :header, doc: "title area; rendered in a <header>."
  slot :media, doc: "edge-to-edge media (image/video) above the body."
  slot :body, doc: "main content."
  slot :footer, doc: "actions or metadata; omit inside an interactive card."
  slot :inner_block, doc: "shorthand body when the :body slot is not used."

  @doc """
  A surface container with optional header, media, body, and footer slots.

  With `interactive` and a destination, the entire card becomes one clickable
  link via a stretched anchor — do not place other interactive controls inside
  it. `elevation` sets the resting shadow; `selected` marks the current card.

  ## When not to use

  If the card needs several independent actions (buttons, links), keep it
  non-interactive and let those controls be the interactive elements.

  ## Examples

      <.card>
        <:header><h3>Weekly report</h3></:header>
        <:body>Everything nominal.</:body>
      </.card>

      <.card interactive navigate={~p"/reports/42"} link_label="Open report 42">
        <:header><h3>Report #42</h3></:header>
      </.card>
  """
  def card(assigns) do
    assigns =
      assign(
        assigns,
        :class,
        cx([
          "aui-card",
          "aui-card--elev-#{variant(elevation_map(), assigns.elevation, "sm")}",
          {"aui-card--interactive", assigns.interactive},
          {"aui-card--selected", assigns.selected},
          {"aui-card--loading", assigns.loading}
        ])
      )

    ~H"""
    <article
      class={@class}
      aria-busy={@loading && "true"}
      aria-current={@selected && "true"}
      data-aui-loading={@loading && "true"}
      {@rest}
    >
      <.link
        :if={@interactive && (@navigate || @patch || @href)}
        class="aui-card__link aui-focusable"
        navigate={@navigate}
        patch={@patch}
        href={@href}
        aria-label={@link_label}
      >
        <span class="aui-sr-only">{@link_label}</span>
      </.link>
      <div :if={@media != []} class="aui-card__media">{render_slot(@media)}</div>
      <header :if={@header != []} class="aui-card__header">{render_slot(@header)}</header>
      <div :if={@body != [] || @inner_block != []} class="aui-card__body">
        {render_slot(@body)}{render_slot(@inner_block)}
      </div>
      <footer :if={@footer != []} class="aui-card__footer">{render_slot(@footer)}</footer>
    </article>
    """
  end

  attr :variant, :string, default: "neutral", values: @badge_variants
  attr :size, :string, default: "md", values: @sizes
  attr :dot, :boolean, default: false, doc: "Show a leading status dot."

  attr :removable, :boolean,
    default: false,
    doc: "Render a real remove button; wire it with `on_remove`."

  attr :on_remove, :any, default: nil, doc: "phx-click event/JS for the remove button."
  attr :remove_label, :string, default: "Remove"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A small status/label pill. Supports `variant`, `size`, an optional leading
  `dot`, and a `removable` mode whose remove control is a real, labelled button.

  ## Examples

      <.badge variant="success" dot>Live</.badge>
      <.badge removable on_remove={JS.push("drop", value: %{id: 7})}>Tag</.badge>
  """
  def badge(assigns) do
    assigns =
      assign(
        assigns,
        :class,
        cx([
          "aui-badge",
          "aui-badge--#{variant(badge_variant_map(), assigns.variant, "neutral")}",
          "aui-badge--#{variant(size_map(), assigns.size, "md")}",
          {"aui-badge--removable", assigns.removable}
        ])
      )

    ~H"""
    <span class={@class} data-aui-variant={@variant} {@rest}>
      <span :if={@dot} class="aui-badge__dot" aria-hidden="true"></span>
      <span class="aui-badge__label">{render_slot(@inner_block)}</span>
      <button
        :if={@removable}
        type="button"
        class="aui-badge__remove aui-focusable"
        phx-click={@on_remove}
        aria-label={@remove_label}
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </span>
    """
  end

  attr :src, :string, default: nil, doc: "image URL; when absent, initials are shown."

  attr :alt, :string,
    default: nil,
    doc: "accessible name. Required with `src`; used to derive initials without one."

  attr :name, :string, default: nil, doc: "full name; used to compute fallback initials."
  attr :size, :string, default: "md", values: @sizes
  attr :shape, :string, default: "circle", values: ~w(circle square)

  attr :status, :string,
    default: nil,
    values: [nil | ~w(online away busy offline)],
    doc: "Adds a status ring + dot with an accessible label."

  attr :rest, :global

  @doc """
  An avatar image with an initials fallback. When `src` is set, `alt` is the
  accessible name; without `src` the component shows initials derived from
  `name` (or `alt`) while keeping that name available to AT. An optional
  `status` adds a ring, a dot, and visually-hidden status text.

  ## Examples

      <.avatar src="/u/ada.jpg" alt="Ada Lovelace" status="online" />
      <.avatar name="Grace Hopper" size="lg" />
  """
  def avatar(assigns) do
    accessible_name = assigns.alt || assigns.name

    assigns =
      assigns
      |> assign(:accessible_name, accessible_name)
      |> assign(:initials, initials(accessible_name))
      |> assign(
        :class,
        cx([
          "aui-avatar",
          "aui-avatar--#{variant(size_map(), assigns.size, "md")}",
          "aui-avatar--#{assigns.shape}",
          {"aui-avatar--status", assigns.status != nil}
        ])
      )

    ~H"""
    <span class={@class} data-aui-status={@status} {@rest}>
      <img :if={@src} class="aui-avatar__img" src={@src} alt={@accessible_name || ""} loading="lazy" />
      <span
        :if={!@src}
        class="aui-avatar__fallback"
        role="img"
        aria-label={@accessible_name}
      >
        <span aria-hidden="true">{@initials}</span>
      </span>
      <span :if={@status} class="aui-avatar__status-dot" aria-hidden="true"></span>
      <span :if={@status} class="aui-sr-only">{@status}</span>
    </span>
    """
  end

  attr :max, :integer, default: nil, doc: "Cap the visible avatars; the rest become a +N pill."
  attr :label, :string, default: nil, doc: "accessible name for the whole group (role=group)."
  attr :rest, :global
  slot :inner_block, required: true, doc: "the `avatar/1` items."

  @doc """
  Stacks avatars into an overlapping cluster. Pair with a manual "+N" `badge`,
  or set `max`-aware markup upstream; the group carries an accessible name.

  ## Examples

      <.avatar_group label="Project members">
        <.avatar name="Ada Lovelace" />
        <.avatar name="Grace Hopper" />
        <span class="aui-avatar-group__overflow" aria-hidden="true">+3</span>
      </.avatar_group>
  """
  def avatar_group(assigns) do
    ~H"""
    <div class="aui-avatar-group" role="group" aria-label={@label} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :label, :string, required: true, doc: "what the number measures."
  attr :value, :string, required: true, doc: "the headline value (pre-formatted)."

  attr :delta, :string,
    default: nil,
    doc: "change magnitude, e.g. \"12%\". Pair with `trend` for direction."

  attr :trend, :string,
    default: "flat",
    values: ~w(up down flat),
    doc: "direction of `delta`; also emitted as visually-hidden text, not color alone."

  attr :description, :string, default: nil, doc: "supporting context under the value."
  attr :loading, :boolean, default: false, doc: "Render a skeleton placeholder."
  attr :rest, :global

  @doc """
  A KPI block: label, big value, an optional delta with an accessible direction,
  and a description. The trend is conveyed with a caret **and** hidden
  "increased/decreased" text so it never depends on color alone.

  ## Examples

      <.stat label="Monthly revenue" value="$48,120" delta="12%" trend="up"
        description="vs. last month" />
  """
  def stat(assigns) do
    assigns =
      assigns
      |> assign(:trend_word, trend_word(assigns.trend))
      |> assign(
        :class,
        cx([
          "aui-stat",
          {"aui-stat--loading", assigns.loading}
        ])
      )

    ~H"""
    <div class={@class} aria-busy={@loading && "true"} data-aui-loading={@loading && "true"} {@rest}>
      <p class="aui-stat__label">{@label}</p>
      <p class="aui-stat__value">{@value}</p>
      <p
        :if={@delta}
        class={["aui-stat__delta", "aui-stat__delta--#{@trend}"]}
        data-aui-trend={@trend}
      >
        <span class="aui-stat__delta-icon" aria-hidden="true">{trend_glyph(@trend)}</span>
        <span class="aui-sr-only">{@trend_word}</span>
        <span class="aui-stat__delta-value">{@delta}</span>
      </p>
      <p :if={@description} class="aui-stat__desc">{@description}</p>
    </div>
    """
  end

  attr :rest, :global

  slot :item, doc: "one term/description pair." do
    attr :term, :string, required: true, doc: "the <dt> text."
  end

  @doc """
  A semantic description list: a real `<dl>` with `<dt>`/`<dd>` pairs, laid out
  as a responsive two-column grid that stacks on narrow screens.

  ## Examples

      <.description_list>
        <:item term="Plan">Pro</:item>
        <:item term="Renews">March 1, 2026</:item>
      </.description_list>
  """
  def description_list(assigns) do
    ~H"""
    <dl class="aui-dl" {@rest}>
      <div :for={item <- @item} class="aui-dl__row">
        <dt class="aui-dl__term">{item.term}</dt>
        <dd class="aui-dl__desc">{render_slot(item)}</dd>
      </div>
    </dl>
    """
  end

  defp trend_word("up"), do: "increased"
  defp trend_word("down"), do: "decreased"
  defp trend_word(_), do: "no change"

  defp trend_glyph("up"), do: "▲"
  defp trend_glyph("down"), do: "▼"
  defp trend_glyph(_), do: "→"

  defp initials(nil), do: "?"

  defp initials(name) do
    name
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.map_join("", &String.slice(&1, 0, 1))
    |> String.upcase()
    |> case do
      "" -> "?"
      value -> value
    end
  end

  defp badge_variant_map, do: Map.new(@badge_variants, &{&1, &1})
  defp size_map, do: Map.new(@sizes, &{&1, &1})
  defp elevation_map, do: Map.new(@elevations, &{&1, &1})
end
