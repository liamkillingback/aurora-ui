defmodule AuroraUI.Components.Navigation do
  @moduledoc """
  Navigation family — navbar, sidebar, breadcrumbs, pagination, and steps.

  These components describe "where am I and where can I go" and lean entirely on
  server-rendered semantics: real `<nav>` landmarks with accessible names, `<ol>`
  ordering where sequence matters, and `aria-current` to mark the active
  location. The only client behavior is the navbar's mobile disclosure, which is
  a native `<details>`/`<summary>` — no JavaScript, no `phx-update="ignore"`.

  ## Semantics

  - Every navigation region is a `<nav aria-label=…>` so multiple regions on one
    page are distinguishable in the landmarks rotor.
  - The current page/step is marked with `aria-current` (`"page"` for links,
    `"step"` for the stepper) rather than styling alone.
  - `breadcrumbs/1`, `pagination/1`, and `steps/1` use an ordered list because
    their order is meaningful; the active trailing crumb is a plain element (not
    a link) with `aria-current="page"`.
  - `skip_link/1` gives keyboard and screen-reader users a way to jump past the
    navbar straight to the main content.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  # ──────────────────────────────────────────────────────────────────────────
  # skip_link
  # ──────────────────────────────────────────────────────────────────────────

  attr :href, :string, default: "#main", doc: "fragment id of the main landmark"
  attr :rest, :global
  slot :inner_block, doc: "link text; defaults to \"Skip to content\""

  @doc """
  A visually-hidden-until-focused link that lets keyboard users jump past
  repeated navigation to the page's main content. Place it as the first focusable
  element in the document and point it at your `<main id="main">`.

  ## Examples

      <.skip_link href="#main">Skip to content</.skip_link>
  """
  def skip_link(assigns) do
    ~H"""
    <a href={@href} class="aui-navbar__skip aui-focusable" {@rest}>
      {if @inner_block == [], do: "Skip to content", else: render_slot(@inner_block)}
    </a>
    """
  end

  # ──────────────────────────────────────────────────────────────────────────
  # navbar
  # ──────────────────────────────────────────────────────────────────────────

  attr :id, :string, default: nil, doc: "id for the mobile disclosure; generated when omitted"
  attr :label, :string, default: "Primary", doc: "accessible name for the <nav> landmark"

  attr :toggle_label, :string,
    default: "Menu",
    doc: "accessible name for the mobile disclosure toggle"

  attr :rest, :global

  slot :brand, doc: "logo / wordmark, rendered at the inline-start edge"

  slot :link, doc: "primary navigation links" do
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
    attr :current, :boolean, doc: "marks this link as the current page"
  end

  slot :actions, doc: "trailing actions (buttons, avatar, theme toggle)"

  @doc """
  Top navigation bar with a brand region, primary links, and trailing actions.

  On narrow viewports the links collapse behind a native `<details>` disclosure,
  so the toggle works with zero JavaScript and needs no `phx-update="ignore"`.
  On wide viewports CSS forces the panel open and hides the toggle. Mark the
  active link with `current` so it renders `aria-current="page"`.

  ## Examples

      <.navbar id="site-nav">
        <:brand><.link navigate={~p"/"}>Aurora</.link></:brand>
        <:link navigate={~p"/"} current>Home</:link>
        <:link navigate={~p"/docs"}>Docs</:link>
        <:actions><.button>Sign in</.button></:actions>
      </.navbar>
  """
  def navbar(assigns) do
    assigns = assign(assigns, :id, assigns.id || id(nil, "navbar"))

    ~H"""
    <nav class="aui-navbar" aria-label={@label} {@rest}>
      <div class="aui-navbar__inner">
        <div :if={@brand != []} class="aui-navbar__brand">{render_slot(@brand)}</div>

        <details :if={@link != []} id={@id} class="aui-navbar__disclosure">
          <summary class="aui-navbar__toggle aui-focusable" aria-label={@toggle_label}>
            <span class="aui-navbar__toggle-bars" aria-hidden="true"></span>
          </summary>
          <ul class="aui-navbar__links">
            <li :for={link <- @link} class="aui-navbar__item">
              <.link
                class="aui-navbar__link aui-focusable"
                navigate={link[:navigate]}
                patch={link[:patch]}
                href={link[:href]}
                aria-current={link[:current] && "page"}
              >
                {render_slot(link)}
              </.link>
            </li>
          </ul>
        </details>

        <div :if={@actions != []} class="aui-navbar__actions">{render_slot(@actions)}</div>
      </div>
    </nav>
    """
  end

  # ──────────────────────────────────────────────────────────────────────────
  # sidebar
  # ──────────────────────────────────────────────────────────────────────────

  attr :label, :string, default: "Sidebar", doc: "accessible name for the <nav> landmark"
  attr :rest, :global

  slot :section, doc: "a labelled group of items" do
    attr :label, :string, doc: "optional section heading"
  end

  slot :inner_block, doc: "items placed outside any section (use sidebar_item/group)"

  @doc """
  Vertical navigation rail with optional labelled sections. Compose it from
  `sidebar_item/1` for leaf links and `sidebar_group/1` for collapsible groups.

  ## Responsive / off-canvas

  The sidebar renders as a plain in-flow `<nav>`. For an off-canvas layout on
  small screens, place it inside the `drawer` component (or any container you
  toggle with `aria-expanded`) — the sidebar itself stays presentation-agnostic
  so it works equally as a persistent rail or a slide-in panel.

  ## Examples

      <.sidebar label="Docs">
        <:section label="Getting started">
          <.sidebar_item navigate={~p"/install"} current>Install</.sidebar_item>
          <.sidebar_item navigate={~p"/theming"}>Theming</.sidebar_item>
        </:section>
        <.sidebar_group label="Components">
          <.sidebar_item navigate={~p"/components/button"}>Button</.sidebar_item>
        </.sidebar_group>
      </.sidebar>
  """
  def sidebar(assigns) do
    ~H"""
    <nav class="aui-sidebar" aria-label={@label} {@rest}>
      <div :if={@inner_block != []} class="aui-sidebar__items">{render_slot(@inner_block)}</div>
      <div :for={section <- @section} class="aui-sidebar__section">
        <div :if={section[:label]} class="aui-sidebar__heading">{section[:label]}</div>
        <ul class="aui-sidebar__items">{render_slot(section)}</ul>
      </div>
    </nav>
    """
  end

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :string, default: nil
  attr :current, :boolean, default: false, doc: "marks the item as the current page"
  attr :rest, :global
  slot :icon, doc: "decorative leading icon"
  slot :inner_block, required: true

  @doc """
  A single sidebar link. Renders inside a list item so grouping stays semantic.
  Set `current` to expose `aria-current="page"`.
  """
  def sidebar_item(assigns) do
    ~H"""
    <li class="aui-sidebar__item">
      <.link
        class="aui-sidebar__link aui-focusable"
        navigate={@navigate}
        patch={@patch}
        href={@href}
        aria-current={@current && "page"}
        {@rest}
      >
        <span :if={@icon != []} class="aui-sidebar__icon" aria-hidden="true">{render_slot(@icon)}</span>
        <span class="aui-sidebar__label">{render_slot(@inner_block)}</span>
      </.link>
    </li>
    """
  end

  attr :label, :string, required: true, doc: "the group trigger label"
  attr :open, :boolean, default: true, doc: "initial expanded state"
  attr :rest, :global
  slot :icon, doc: "decorative leading icon"
  slot :inner_block, required: true, doc: "sidebar_item/1 children"

  @doc """
  A collapsible group of sidebar items built on native `<details>` — the
  disclosure state is keyboard-operable with no JavaScript. The summary is a
  real button-like control and exposes its expanded state to assistive tech.
  """
  def sidebar_group(assigns) do
    ~H"""
    <details class="aui-sidebar__group" open={@open} {@rest}>
      <summary class="aui-sidebar__group-trigger aui-focusable">
        <span :if={@icon != []} class="aui-sidebar__icon" aria-hidden="true">{render_slot(@icon)}</span>
        <span class="aui-sidebar__label">{@label}</span>
        <span class="aui-sidebar__group-chevron" aria-hidden="true"></span>
      </summary>
      <ul class="aui-sidebar__items">{render_slot(@inner_block)}</ul>
    </details>
    """
  end

  # ──────────────────────────────────────────────────────────────────────────
  # breadcrumbs
  # ──────────────────────────────────────────────────────────────────────────

  attr :label, :string, default: "Breadcrumb", doc: "accessible name for the <nav> landmark"
  attr :rest, :global

  slot :crumb, required: true, doc: "one path segment; the last is the current page" do
    attr :navigate, :string
    attr :patch, :string
    attr :href, :string
  end

  @doc """
  A breadcrumb trail. Renders a `<nav>` wrapping an ordered list; the final crumb
  is a plain element with `aria-current="page"` (never a link to the page you are
  already on). Long trails truncate with an ellipsis via CSS rather than wrapping.

  ## Examples

      <.breadcrumbs>
        <:crumb navigate={~p"/"}>Home</:crumb>
        <:crumb navigate={~p"/docs"}>Docs</:crumb>
        <:crumb>Navigation</:crumb>
      </.breadcrumbs>
  """
  def breadcrumbs(assigns) do
    assigns = assign(assigns, :last_index, length(assigns.crumb) - 1)

    ~H"""
    <nav class="aui-breadcrumbs" aria-label={@label} {@rest}>
      <ol class="aui-breadcrumbs__list">
        <li
          :for={{crumb, index} <- Enum.with_index(@crumb)}
          class="aui-breadcrumbs__item"
        >
          <.link
            :if={index != @last_index}
            class="aui-breadcrumbs__link aui-focusable"
            navigate={crumb[:navigate]}
            patch={crumb[:patch]}
            href={crumb[:href]}
          >
            {render_slot(crumb)}
          </.link>
          <span
            :if={index == @last_index}
            class="aui-breadcrumbs__current"
            aria-current="page"
          >
            {render_slot(crumb)}
          </span>
        </li>
      </ol>
    </nav>
    """
  end

  # ──────────────────────────────────────────────────────────────────────────
  # pagination
  # ──────────────────────────────────────────────────────────────────────────

  attr :page, :integer, required: true, doc: "the current 1-based page"
  attr :total_pages, :integer, required: true, doc: "total number of pages"
  attr :siblings, :integer, default: 1, doc: "pages to show on each side of the current page"
  attr :label, :string, default: "Pagination"

  attr :path, :any,
    default: nil,
    doc: "1-arity function `page -> href`; when omitted, pass phx-* via :rest for click handling"

  attr :prev_label, :string, default: "Previous"
  attr :next_label, :string, default: "Next"
  attr :rest, :global, include: ~w(phx-click phx-target)

  @doc """
  Numbered pagination with previous/next controls and truncated ranges
  (`1 … 4 5 6 … 20`). The current page is a plain element with
  `aria-current="page"`; disabled prev/next ends are non-focusable
  `aria-disabled` spans. Supply `path` to build hrefs, or forward `phx-click`
  through the global attrs and read `phx-value-page` on each control.

  ## Examples

      <.pagination page={@page} total_pages={@pages} path={&~p"/list?page=\#{&1}"} />
  """
  def pagination(assigns) do
    assigns =
      assigns
      |> assign(:items, page_items(assigns.page, assigns.total_pages, assigns.siblings))
      |> assign(:prev_disabled, assigns.page <= 1)
      |> assign(:next_disabled, assigns.page >= assigns.total_pages)

    ~H"""
    <nav class="aui-pagination" aria-label={@label} {@rest}>
      <ul class="aui-pagination__list">
        <li class="aui-pagination__item">
          <.page_control
            rel="prev"
            disabled={@prev_disabled}
            path={@path}
            page={@page - 1}
            class="aui-pagination__prev"
          >
            <span class="aui-pagination__arrow" aria-hidden="true">‹</span>
            <span class="aui-pagination__control-label">{@prev_label}</span>
          </.page_control>
        </li>

        <li :for={item <- @items} class="aui-pagination__item">
          <span :if={item == :gap} class="aui-pagination__gap" aria-hidden="true">…</span>
          <.page_control
            :if={item != :gap}
            path={@path}
            page={item}
            current={item == @page}
            class="aui-pagination__page"
          >
            <span class="aui-sr-only">Page </span>{item}
          </.page_control>
        </li>

        <li class="aui-pagination__item">
          <.page_control
            rel="next"
            disabled={@next_disabled}
            path={@path}
            page={@page + 1}
            class="aui-pagination__next"
          >
            <span class="aui-pagination__control-label">{@next_label}</span>
            <span class="aui-pagination__arrow" aria-hidden="true">›</span>
          </.page_control>
        </li>
      </ul>
    </nav>
    """
  end

  # Private renderer for a single pagination cell. Declared without `attr`
  # metadata (Phoenix reserves that for public components); defaults are
  # normalized here so each call site can pass only the keys it needs.
  defp page_control(assigns) do
    assigns =
      assigns
      |> assign_new(:rel, fn -> nil end)
      |> assign_new(:current, fn -> false end)
      |> assign_new(:disabled, fn -> false end)
      |> assign_new(:class, fn -> nil end)
      |> assign_new(:path, fn -> nil end)

    ~H"""
    <span
      :if={@disabled}
      class={["aui-pagination__control", "aui-pagination__control--disabled", @class]}
      aria-disabled="true"
    >
      {render_slot(@inner_block)}
    </span>
    <.link
      :if={!@disabled}
      class={[
        "aui-pagination__control aui-focusable",
        @current && "aui-pagination__control--current",
        @class
      ]}
      href={(@path && @path.(@page)) || "#"}
      rel={@rel}
      aria-current={@current && "page"}
      phx-value-page={@page}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  # ──────────────────────────────────────────────────────────────────────────
  # steps
  # ──────────────────────────────────────────────────────────────────────────

  attr :current, :integer, default: 1, doc: "1-based index of the current step"
  attr :orientation, :string, default: "horizontal", values: ~w(horizontal vertical)
  attr :label, :string, default: "Progress"
  attr :rest, :global

  slot :step, required: true, doc: "one step in the process" do
    attr :label, :string, required: true
    attr :description, :string, doc: "optional supporting line under the label"
    attr :status, :string, doc: "override: complete | current | upcoming"
  end

  @doc """
  A process stepper. Steps derive their state (`complete`/`current`/`upcoming`)
  from `current`, or you can override any step with an explicit `status`. The
  active step carries `aria-current="step"`; completed steps announce
  "completed" to assistive tech and show a check. Supports `horizontal` and
  `vertical` orientation via logical properties, so it mirrors correctly in RTL.

  ## Examples

      <.steps current={2}>
        <:step label="Account" description="Create your account" />
        <:step label="Profile" description="Add your details" />
        <:step label="Done" />
      </.steps>
  """
  def steps(assigns) do
    ~H"""
    <nav class={["aui-steps", "aui-steps--#{@orientation}"]} aria-label={@label} {@rest}>
      <ol class="aui-steps__list">
        <li
          :for={{step, index} <- Enum.with_index(@step)}
          class={["aui-steps__item", "aui-steps__item--#{step_status(step, index, @current)}"]}
          aria-current={step_status(step, index, @current) == "current" && "step"}
        >
          <span class="aui-steps__marker" aria-hidden="true">
            <span :if={step_status(step, index, @current) == "complete"} class="aui-steps__check"></span>
            <span :if={step_status(step, index, @current) != "complete"} class="aui-steps__index">
              {index + 1}
            </span>
          </span>
          <span class="aui-steps__body">
            <span class="aui-steps__label">
              {step[:label]}
              <span class="aui-sr-only">{step_status_hint(step_status(step, index, @current))}</span>
            </span>
            <span :if={step[:description]} class="aui-steps__description">{step[:description]}</span>
          </span>
        </li>
      </ol>
    </nav>
    """
  end

  # ── helpers ────────────────────────────────────────────────────────────────

  defp step_status(step, index, current) do
    step[:status] ||
      cond do
        index + 1 < current -> "complete"
        index + 1 == current -> "current"
        true -> "upcoming"
      end
  end

  defp step_status_hint("complete"), do: " (completed)"
  defp step_status_hint("current"), do: " (current step)"
  defp step_status_hint(_), do: ""

  @doc false
  # Builds the visible page list with `:gap` markers for truncated ranges.
  def page_items(_current, total, _siblings) when total <= 0, do: []

  def page_items(current, total, siblings) do
    window_start = max(current - siblings, 1)
    window_end = min(current + siblings, total)

    ([1] ++ Enum.to_list(window_start..window_end) ++ [total])
    |> Enum.filter(&(&1 >= 1 and &1 <= total))
    |> Enum.uniq()
    |> Enum.sort()
    |> insert_gaps()
  end

  defp insert_gaps([a, b | rest]) when b - a > 1, do: [a, :gap | insert_gaps([b | rest])]
  defp insert_gaps([a | rest]), do: [a | insert_gaps(rest)]
  defp insert_gaps([]), do: []
end
