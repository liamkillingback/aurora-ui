defmodule AuroraUI.Components.Command do
  @moduledoc """
  Command family — search field, search results, and the command palette.

  These components cover the "find and act" surface of an app: a debounced
  search input, an accessible results list with a live result-count
  announcement and an empty state, and a command palette opened from a
  **visible** trigger (never a keyboard shortcut alone).

  ## Semantics

  Search is server-rendered: the input emits `phx-change`/`phx-submit` and the
  server re-renders `search_results/1`. JavaScript only enhances — the palette's
  filtering/keyboard behavior is layered on top of a fully working button +
  form. Results are a **semantic list** (`<ul role="list">`), not a `listbox`:
  results are navigable content (links), not options in a single-select widget,
  so the list-plus-link semantics match assistive-technology expectations and
  keep native link keyboard behavior. The palette is the one exception — it is a
  filter-then-pick widget, so it uses the combobox + listbox pattern.

  ## Debounce guidance

  Always debounce the live search so you do not round-trip on every keystroke.
  Set `debounce` (renders `phx-debounce`); `120`–`300` ms feels responsive
  without flooding the server, and `"blur"` defers until focus leaves. Pair a
  `phx-change` for incremental results with a `phx-submit` fallback so pressing
  Enter still works when JS is unavailable.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @sizes ~w(sm md lg)

  attr :id, :string, default: nil, doc: "stable id; generated when omitted"
  attr :name, :string, default: "q", doc: "input name submitted with the form"
  attr :value, :string, default: nil, doc: "current query value"
  attr :label, :string, default: "Search", doc: "accessible name for the search region and input"
  attr :placeholder, :string, default: "Search…"
  attr :size, :string, default: "md", values: @sizes
  attr :loading, :boolean, default: false, doc: "sets aria-busy and shows a spinner"
  attr :clearable, :boolean, default: true, doc: "renders a clear button when the field has text"

  attr :debounce, :any,
    default: nil,
    doc: "renders phx-debounce (ms integer or \"blur\"); always debounce live search"

  attr :rest, :global,
    include: ~w(phx-change phx-submit phx-target phx-value-id autocomplete method action)

  slot :inner_block,
    doc: "optional trailing controls rendered after the input (e.g. a scope select)"

  @doc """
  A search input inside a `role="search"` landmark.

  Renders `type="search"` + explicit `role="searchbox"`, a leading search icon,
  an optional clear button (auto-hidden while empty via `:placeholder-shown`),
  and a busy state (`aria-busy`) with a spinner. Emits `phx-change`/`phx-submit`
  from the wrapping form.

  ## Examples

      <.search_field phx-change="search" phx-submit="search" debounce={200} value={@q} />
      <.search_field label="Find a doc" loading={@searching} name="query" />
  """
  def search_field(assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || id(nil, "search"))
      |> assign(:class, cx(["aui-search", "aui-search--#{assigns.size}"]))

    ~H"""
    <form role="search" aria-label={@label} class={@class} data-aui="search" {@rest}>
      <div class="aui-search__control">
        <span class="aui-search__icon" aria-hidden="true">
          <.search_icon />
        </span>
        <input
          id={@id}
          type="search"
          role="searchbox"
          class="aui-search__input aui-focusable"
          name={@name}
          value={@value}
          placeholder={@placeholder}
          aria-label={@label}
          aria-busy={@loading && "true"}
          autocomplete="off"
          spellcheck="false"
          phx-debounce={@debounce}
        />
        <span :if={@loading} class="aui-search__spinner" role="presentation" aria-hidden="true"></span>
        <button
          :if={@clearable}
          type="reset"
          class="aui-search__clear aui-focusable"
          data-aui-search-clear
          aria-label="Clear search"
          title="Clear search"
        >
          <.x_icon />
        </button>
      </div>
      {render_slot(@inner_block)}
    </form>
    """
  end

  attr :id, :string, default: nil
  attr :label, :string, default: "Search results", doc: "accessible name for the results list"

  attr :count, :integer,
    default: nil,
    doc: "number of results; drives the aria-live announcement and the empty state. nil = unknown"

  attr :loading, :boolean, default: false
  attr :rest, :global

  slot :group, doc: "an optional titled group of results" do
    attr :label, :string, required: true
  end

  slot :inner_block, doc: "flat results (`search_result/1`) when not grouping"
  slot :empty, doc: "no-results content; put suggested queries/actions here"

  @doc """
  A results list with a polite result-count announcement and an empty state.

  When `count` is `0` the `empty` slot renders (a default message otherwise);
  any other value renders the results. The count is announced through a
  visually-hidden `aria-live="polite"` region so screen-reader users hear how
  many matches came back without moving focus. Use the `group` slot for titled
  sections, or the default slot for a flat list of `search_result/1`.

  ## Examples

      <.search_results count={length(@results)}>
        <.search_result :for={r <- @results} navigate={~p"/docs/\#{r.slug}"}>
          {r.title}
        </.search_result>
        <:empty>
          No matches. Try <.search_result>installation</.search_result>.
        </:empty>
      </.search_results>
  """
  def search_results(assigns) do
    assigns = assign(assigns, :id, assigns.id || id(nil, "results"))

    ~H"""
    <section
      id={@id}
      class="aui-search-results"
      aria-label={@label}
      aria-busy={@loading && "true"}
      data-aui="search-results"
      {@rest}
    >
      <p class="aui-sr-only" role="status" aria-live="polite" aria-atomic="true">
        {count_message(@count)}
      </p>

      <div :if={@count == 0} class="aui-search-results__empty">
        <%= if @empty != [] do %>
          {render_slot(@empty)}
        <% else %>
          <p class="aui-search-results__empty-text">No results found.</p>
        <% end %>
      </div>

      <div :if={@count != 0 && @group != []} class="aui-search-results__groups">
        <section :for={group <- @group} class="aui-search-results__group">
          <h3 class="aui-search-results__group-label">{group.label}</h3>
          <ul role="list" class="aui-search-results__list">
            {render_slot(group)}
          </ul>
        </section>
      </div>

      <ul :if={@count != 0 && @group == []} role="list" class="aui-search-results__list">
        {render_slot(@inner_block)}
      </ul>
    </section>
    """
  end

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :string, default: nil
  attr :active, :boolean, default: false, doc: "highlights the current/keyboard-focused row"
  attr :rest, :global, include: ~w(phx-click phx-value-id target rel download)

  slot :icon, doc: "leading media/icon (decorative)"
  slot :meta, doc: "trailing metadata (shortcut, type, timestamp)"
  slot :inner_block, required: true, doc: "the result title/summary"

  @doc """
  A single result row. Becomes a link when `navigate`/`patch`/`href` is set,
  otherwise a static `<li>` (wire `phx-click` for command-style rows).
  """
  def search_result(assigns) do
    assigns = assign(assigns, :link?, assigns.navigate || assigns.patch || assigns.href)

    ~H"""
    <li class={cx(["aui-search-result", {"aui-search-result--active", @active}])}>
      <.link
        :if={@link?}
        class="aui-search-result__link aui-focusable"
        navigate={@navigate}
        patch={@patch}
        href={@href}
        {@rest}
      >
        <.search_result_body icon={@icon} meta={@meta} inner_block={@inner_block} />
      </.link>
      <div :if={!@link?} class="aui-search-result__link" {@rest}>
        <.search_result_body icon={@icon} meta={@meta} inner_block={@inner_block} />
      </div>
    </li>
    """
  end

  defp search_result_body(assigns) do
    ~H"""
    <span :if={@icon != []} class="aui-search-result__icon" aria-hidden="true">
      {render_slot(@icon)}
    </span>
    <span class="aui-search-result__body">{render_slot(@inner_block)}</span>
    <span :if={@meta != []} class="aui-search-result__meta">{render_slot(@meta)}</span>
    """
  end

  attr :id, :string, default: nil, doc: "stable id — required for the hook to survive patches"
  attr :label, :string, default: "Command palette", doc: "dialog accessible name (title)"
  attr :trigger_label, :string, default: "Search commands", doc: "visible trigger button text"
  attr :placeholder, :string, default: "Type a command or search…"
  attr :open, :boolean, default: false, doc: "server-controlled open state"

  attr :shortcut, :string,
    default: nil,
    doc:
      "discoverable, configurable shortcut hint (e.g. \"⌘K\"); shown as a kbd and passed to the hook"

  attr :rest, :global

  slot :group, doc: "a titled group of commands; place role=option items inside" do
    attr :label, :string, required: true
  end

  slot :empty, doc: "shown when the filter matches nothing"

  @doc """
  A command palette opened from a **visible** trigger button.

  The palette is a dialog (`role="dialog"`, `aria-modal`, labelled by its title)
  containing a `combobox` search input and grouped commands in a `listbox`.
  Enhancement is lazy: `phx-hook="AuroraCommandPalette"` dynamic-imports
  `./command.js` only where a palette actually renders, keeping it out of every
  other bundle.

  ## Shortcuts are an enhancement, never the only door

  The visible trigger is the source of truth, so the palette works with zero
  keyboard shortcuts. When you *do* wire one (via `shortcut`), it must be:

    * **discoverable** — shown as a `kbd` hint on the trigger and inside the
      dialog, so users can learn it;
    * **configurable** — the value is an attribute, not hard-coded;
    * **non-hijacking** — the hook must never intercept browser or
      assistive-technology shortcuts (it listens for the configured combo only,
      and never swallows keys while focus is in another input or AT is driving).

  ## Examples

      <.command_palette id="cmdk" shortcut="⌘K">
        <:group label="Navigation">
          <button role="option" data-aui-command-item phx-click="go" phx-value-to="/inbox">
            Go to Inbox
          </button>
        </:group>
        <:empty>No commands match.</:empty>
      </.command_palette>
  """
  def command_palette(assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || id(nil, "command"))
      |> then(fn a ->
        a
        |> assign(:dialog_id, id(a.id, "dialog"))
        |> assign(:title_id, id(a.id, "title"))
        |> assign(:input_id, id(a.id, "input"))
        |> assign(:list_id, id(a.id, "list"))
      end)

    ~H"""
    <div class="aui-command" data-aui="command" {@rest}>
      <button
        type="button"
        class="aui-command__trigger aui-focusable"
        data-aui-command-open
        aria-haspopup="dialog"
        aria-expanded={to_string(@open)}
        aria-controls={@dialog_id}
      >
        <span class="aui-command__trigger-icon" aria-hidden="true"><.search_icon /></span>
        <span class="aui-command__trigger-label">{@trigger_label}</span>
        <kbd :if={@shortcut} class="aui-command__kbd" aria-hidden="true">{@shortcut}</kbd>
      </button>

      <div
        id={@dialog_id}
        class="aui-command__dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby={@title_id}
        data-aui-command
        data-aui-open={@open && "true"}
        data-aui-shortcut={@shortcut}
        phx-hook="AuroraCommandPalette"
        hidden={!@open}
      >
        <div class="aui-command__backdrop" data-aui-command-close aria-hidden="true"></div>

        <div class="aui-command__panel" role="document">
          <h2 id={@title_id} class="aui-sr-only">{@label}</h2>

          <div class="aui-command__search">
            <span class="aui-command__search-icon" aria-hidden="true"><.search_icon /></span>
            <input
              id={@input_id}
              type="text"
              class="aui-command__input aui-focusable"
              role="combobox"
              aria-expanded="true"
              aria-controls={@list_id}
              aria-label={@label}
              placeholder={@placeholder}
              data-aui-command-input
              autocomplete="off"
              spellcheck="false"
            />
            <button
              type="button"
              class="aui-command__close aui-focusable"
              data-aui-command-close
              aria-label="Close command palette"
            >
              <.x_icon />
            </button>
          </div>

          <div
            :if={@shortcut}
            class="aui-command__hint"
            data-aui-command-hint
          >
            Tip: press <kbd class="aui-command__kbd">{@shortcut}</kbd> to open this anywhere.
          </div>

          <ul
            id={@list_id}
            class="aui-command__list"
            role="listbox"
            aria-label={@label}
            data-aui-command-list
          >
            <li
              :for={group <- @group}
              class="aui-command__group"
              role="group"
              aria-label={group.label}
            >
              <span class="aui-command__group-label" role="presentation">{group.label}</span>
              <ul role="presentation" class="aui-command__group-items">
                {render_slot(group)}
              </ul>
            </li>
          </ul>

          <div :if={@empty != []} class="aui-command__empty" data-aui-command-empty hidden>
            {render_slot(@empty)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ── Internal ──────────────────────────────────────────────────────────────

  defp count_message(nil), do: ""
  defp count_message(0), do: "No results found."
  defp count_message(1), do: "1 result."
  defp count_message(n) when is_integer(n) and n > 1, do: "#{n} results."

  defp search_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <circle cx="9" cy="9" r="6" stroke="currentColor" stroke-width="1.6" />
      <path d="m14 14 3.5 3.5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" />
    </svg>
    """
  end

  defp x_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <path
        d="m5 5 10 10M15 5 5 15"
        stroke="currentColor"
        stroke-width="1.6"
        stroke-linecap="round"
      />
    </svg>
    """
  end
end
