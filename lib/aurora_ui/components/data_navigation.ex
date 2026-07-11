defmodule AuroraUI.Components.DataNavigation do
  @moduledoc """
  Data navigation family — semantic `table`, an interactive `data_grid`, a
  `filter_bar` (+ `filter_chip`), and an `empty_state`.

  This family draws a deliberate line between two very different jobs that other
  kits blur together:

  * **`table/1`** is a *semantic* `<table>`. It is the right tool for the vast
    majority of tabular data: read-mostly rows, optional column sorting, row
    selection with bulk actions, and full loading/empty/error states. It leans
    entirely on native table semantics (`<caption>`, `<th scope="col">`,
    `aria-sort`) so screen readers announce structure for free. No custom focus
    model, no roving `tabindex` — you get platform behavior.

  * **`data_grid/1`** is an *interactive* `role="grid"` widget for the narrow
    case where each cell is individually focusable and editable (a spreadsheet
    surface). It is heavier: it opts you out of the default reading experience
    and into an application keyboard model (see below), so reach for it **only**
    when cells are edited in place. When in doubt, use `table/1`.

  ### `data_grid/1` keyboard model

  A grid manages a single roving focus point (one cell is `tabindex="0"`, the
  rest are `tabindex="-1"`). The consumer's `AuroraDataGrid` hook (not shipped
  in core — the family exposes the `data-aui-grid` DOM contract for you to wire)
  implements:

  | Key | Action |
  |---|---|
  | Arrow keys | Move cell focus one cell in that direction |
  | Home / End | First / last cell in the row |
  | Ctrl+Home / Ctrl+End | First / last cell in the grid |
  | Enter / F2 | Enter edit mode for the focused cell |
  | Escape | Cancel edit, restore the previous value, keep focus |

  The server renders the active cell (`active_row`/`active_col`) as
  `tabindex="0"`; the hook updates roving focus client-side without a round trip.

  ### Sorting event contract (`table/1`)

  Sortable headers render a real `<button>` inside the `<th>` that emits
  `phx-click={@sort_event}` with `phx-value-key` set to the column's `key`. Your
  LiveView handles it and re-assigns `sort_by`/`sort_dir`:

      def handle_event("sort", %{"key" => key}, socket) do
        {:noreply, assign(socket, sort_by: key, sort_dir: toggle(socket, key))}
      end

  The current column reflects `aria-sort="ascending" | "descending"`; other
  sortable columns advertise `aria-sort="none"`.

  ### Selection event contract (`table/1`)

  With `selectable`, a checkbox column is added. Row checkboxes emit
  `phx-click={@select_event}` with `phx-value-id` (from `row_id`); the header
  select-all checkbox emits `phx-click={@select_all_event}`. The set of selected
  ids is passed back in via `selected`.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @sizes ~w(sm md lg)

  attr :rows, :list, default: [], doc: "the row data; each is passed to every `:col` slot"

  attr :caption, :string,
    default: nil,
    doc: "table caption; the accessible name/description of the table. Strongly recommended."

  attr :caption_visible, :boolean,
    default: true,
    doc: "when false the caption is kept for AT but visually hidden"

  attr :selectable, :boolean, default: false, doc: "adds a leading checkbox column + select-all"

  attr :responsive, :string,
    default: "scroll",
    values: ~w(scroll stack),
    doc: """
    Narrow-viewport strategy. `scroll` keeps the table and lets it scroll
    horizontally inside a focusable region. `stack` collapses each row into a
    labelled card below the `--stack` breakpoint (cells expose `data-label` from
    the column `label`).
    """

  attr :loading, :boolean, default: false, doc: "renders shimmer skeleton rows and sets aria-busy"
  attr :loading_rows, :integer, default: 5, doc: "how many skeleton rows to show while loading"

  attr :sort_by, :string, default: nil, doc: "the `key` of the currently sorted column"
  attr :sort_dir, :string, default: nil, doc: "`asc` or `desc` for the sorted column"
  attr :sort_event, :string, default: "sort", doc: "phx-click event name emitted by sort buttons"

  attr :selected, :list, default: [], doc: "ids (matched against `row_id`) of selected rows"
  attr :row_id, :any, default: nil, doc: "1-arity fun `row -> id`; falls back to the row index"
  attr :all_selected, :boolean, default: false, doc: "checks the select-all box"
  attr :select_event, :string, default: "select_row"
  attr :select_all_event, :string, default: "select_all"

  attr :rest, :global

  slot :col, doc: "one column. Its inner block receives the row via `:let`." do
    attr :label, :string, doc: "header text (also used as the stacked cell label)"
    attr :key, :string, doc: "sort key sent as phx-value-key; required for sortable columns"
    attr :sortable, :boolean
    attr :align, :string, values: ~w(start center end), doc: "cell text alignment"
    attr :numeric, :boolean, doc: "right-aligns and uses tabular figures"
  end

  slot :bulk_actions, doc: "actions shown above the table while any row is selected"
  slot :empty, doc: "shown in place of rows when `rows` is empty and not loading"

  slot :error,
    doc: "include only in the error state; replaces the table body with an error region"

  @doc """
  A semantic data table with sorting, selection, and full state coverage.

  ## When not to use

  If each cell is individually focusable and editable in place, use
  `data_grid/1` instead — a `<table>` is not an application grid.

  ## Examples

      <.table caption="Team members" rows={@members} selectable
              selected={@selected} sort_by={@sort_by} sort_dir={@sort_dir}>
        <:col :let={m} label="Name" key="name" sortable>{m.name}</:col>
        <:col :let={m} label="Role">{m.role}</:col>
        <:col :let={m} label="Seats" key="seats" sortable numeric>{m.seats}</:col>
        <:bulk_actions>
          <.button variant="danger" phx-click="archive">Archive</.button>
        </:bulk_actions>
        <:empty>No members yet.</:empty>
      </.table>
  """
  def table(assigns) do
    assigns =
      assigns
      |> assign(:colspan, length(assigns.col) + if(assigns.selectable, do: 1, else: 0))
      |> assign_new(:caption_id, fn -> id(nil, "table-cap") end)

    ~H"""
    <div
      class={
        cx([
          "aui-table",
          "aui-table--#{@responsive}",
          {"aui-table--selectable", @selectable}
        ])
      }
      data-aui
      {@rest}
    >
      <div
        :if={@selectable and @selected != []}
        class="aui-table__bulk"
        role="region"
        aria-label="Bulk actions"
      >
        <span class="aui-table__bulk-count" aria-live="polite">
          {length(@selected)} selected
        </span>
        {render_slot(@bulk_actions)}
      </div>

      <div class="aui-table__scroll" tabindex="0" role="group" aria-labelledby={@caption_id}>
        <table class="aui-table__el" aria-busy={@loading && "true"}>
          <caption
            id={@caption_id}
            class={cx(["aui-table__caption", {"aui-sr-only", not @caption_visible}])}
          >
            {@caption}
          </caption>
          <thead class="aui-table__head">
            <tr>
              <th :if={@selectable} scope="col" class="aui-table__th aui-table__th--select">
                <input
                  type="checkbox"
                  class="aui-table__checkbox aui-focusable"
                  checked={@all_selected}
                  aria-label="Select all rows"
                  phx-click={@select_all_event}
                />
              </th>
              <th
                :for={col <- @col}
                scope="col"
                class={
                  cx([
                    "aui-table__th",
                    {"aui-table__th--numeric", col[:numeric]},
                    col[:align] && "aui-table__cell--#{col[:align]}"
                  ])
                }
                aria-sort={sort_state(col, @sort_by, @sort_dir)}
              >
                <button
                  :if={col[:sortable]}
                  type="button"
                  class="aui-table__sort aui-focusable"
                  phx-click={@sort_event}
                  phx-value-key={col[:key]}
                >
                  <span class="aui-table__sort-label">{col[:label]}</span>
                  <span
                    class="aui-table__sort-icon"
                    aria-hidden="true"
                    data-dir={sort_dir_of(col, @sort_by, @sort_dir)}
                  ></span>
                </button>
                <span :if={!col[:sortable]}>{col[:label]}</span>
              </th>
            </tr>
          </thead>

          <tbody :if={@loading} class="aui-table__body">
            <tr :for={_ <- 1..@loading_rows//1} class="aui-table__row" aria-hidden="true">
              <td :if={@selectable} class="aui-table__td aui-table__td--select">
                <span class="aui-table__skeleton aui-table__skeleton--box"></span>
              </td>
              <td :for={_col <- @col} class="aui-table__td">
                <span class="aui-table__skeleton"></span>
              </td>
            </tr>
          </tbody>

          <tbody :if={not @loading and @error != []} class="aui-table__body">
            <tr>
              <td class="aui-table__td aui-table__state" colspan={@colspan} role="alert">
                {render_slot(@error)}
              </td>
            </tr>
          </tbody>

          <tbody :if={not @loading and @error == [] and @rows == []} class="aui-table__body">
            <tr>
              <td class="aui-table__td aui-table__state" colspan={@colspan}>
                <span :if={@empty != []}>{render_slot(@empty)}</span>
                <span :if={@empty == []} class="aui-table__empty-default">No data to display.</span>
              </td>
            </tr>
          </tbody>

          <tbody :if={not @loading and @error == [] and @rows != []} class="aui-table__body">
            <tr
              :for={{row, index} <- Enum.with_index(@rows)}
              class={
                cx([
                  "aui-table__row",
                  {"aui-table__row--selected", row_selected?(row, index, @row_id, @selected)}
                ])
              }
            >
              <td :if={@selectable} class="aui-table__td aui-table__td--select">
                <input
                  type="checkbox"
                  class="aui-table__checkbox aui-focusable"
                  checked={row_selected?(row, index, @row_id, @selected)}
                  aria-label="Select row"
                  phx-click={@select_event}
                  phx-value-id={row_id(row, index, @row_id)}
                />
              </td>
              <td
                :for={col <- @col}
                class={
                  cx([
                    "aui-table__td",
                    {"aui-table__td--numeric", col[:numeric]},
                    col[:align] && "aui-table__cell--#{col[:align]}"
                  ])
                }
                data-label={col[:label]}
              >
                {render_slot(col, row)}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @grid_edit_keys "ArrowUp ArrowDown ArrowLeft ArrowRight Home End Enter Escape F2"

  attr :rows, :list, default: [], doc: "row data; each is passed to every `:col` slot"
  attr :caption, :string, default: nil, doc: "accessible name for the grid (aria-label)"

  attr :active_row, :integer, default: 0, doc: "0-based row index that holds roving focus"
  attr :active_col, :integer, default: 0, doc: "0-based column index that holds roving focus"

  attr :rest, :global

  slot :col, required: true, doc: "one grid column; inner block receives the row via `:let`." do
    attr :label, :string, required: true
    attr :editable, :boolean, doc: "advertises the cell as editable to AT"
  end

  @doc """
  An interactive `role="grid"` for cell-by-cell focus and in-place editing.

  This is intentionally heavier than `table/1`: it replaces native table reading
  semantics with an application keyboard model (Arrow keys move a single roving
  focus point, Enter/F2 edit, Escape cancels). Only reach for it when cells are
  edited in place — otherwise `table/1` is more accessible and less code.

  The grid emits the `data-aui-grid` DOM contract; wire the roving-focus/edit
  keyboard handling with your own `AuroraDataGrid` hook (the server keeps
  `active_row`/`active_col` authoritative so focus survives a patch).

  ## Examples

      <.data_grid rows={@cells} active_row={@r} active_col={@c} caption="Budget">
        <:col :let={row} label="Item">{row.item}</:col>
        <:col :let={row} label="Amount" editable>{row.amount}</:col>
      </.data_grid>
  """
  def data_grid(assigns) do
    assigns = assign(assigns, :colcount, length(assigns.col))

    ~H"""
    <div
      class="aui-grid"
      role="grid"
      aria-label={@caption}
      aria-rowcount={length(@rows) + 1}
      aria-colcount={@colcount}
      data-aui-grid
      data-aui-edit-keys={grid_edit_keys()}
      data-aui
      {@rest}
    >
      <div role="rowgroup" class="aui-grid__head">
        <div role="row" class="aui-grid__row" aria-rowindex="1">
          <div
            :for={col <- @col}
            role="columnheader"
            class="aui-grid__cell aui-grid__cell--header"
          >
            {col[:label]}
          </div>
        </div>
      </div>
      <div role="rowgroup" class="aui-grid__body">
        <div
          :for={{row, r} <- Enum.with_index(@rows)}
          role="row"
          class="aui-grid__row"
          aria-rowindex={r + 2}
        >
          <div
            :for={{col, c} <- Enum.with_index(@col)}
            role="gridcell"
            class="aui-grid__cell aui-focusable"
            aria-colindex={c + 1}
            aria-readonly={!col[:editable] && "true"}
            tabindex={if(r == @active_row and c == @active_col, do: "0", else: "-1")}
            data-aui-grid-cell
            data-aui-row={r}
            data-aui-col={c}
            data-aui-editable={col[:editable] && "true"}
          >
            {render_slot(col, row)}
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Bound the moduledoc key list into an accessor usable inside HEEx.
  defp grid_edit_keys, do: @grid_edit_keys

  attr :label, :string, default: "Filters", doc: "accessible name for the filter region"
  attr :count, :integer, default: nil, doc: "result count; announced politely when it changes"

  attr :count_unit, :string,
    default: "results",
    doc: "noun for the count, e.g. \"results\", \"orders\""

  attr :active?, :boolean,
    default: false,
    doc: "whether any filter is applied; toggles the clear-all button"

  attr :clear_event, :string, default: "clear_filters", doc: "phx-click for the clear-all button"
  attr :rest, :global

  slot :inner_block, doc: "the filter controls (selects, search field, …)"
  slot :chips, doc: "the applied-filter chips (use `filter_chip/1`)"

  @doc """
  A filter shell: controls, removable applied-filter chips, a clear-all button,
  and a politely-announced result count.

  ## URL state + LiveView streams

  Keep filters in the URL so they are shareable and back/forward-safe, and render
  results into a stream so only changed rows are patched:

      # router-driven: filters live in params, results in a stream
      def handle_params(params, _uri, socket) do
        filters = Filters.parse(params)
        rows = Catalog.list(filters)

        {:noreply,
         socket
         |> assign(:filters, filters)
         |> assign(:count, length(rows))
         |> stream(:rows, rows, reset: true)}
      end

      # a chip's remove button just patches the URL without that key
      def handle_event("drop", %{"key" => key}, socket) do
        {:noreply, push_patch(socket, to: ~p"/catalog?\#{Filters.drop(socket.assigns.filters, key)}")}
      end

      <.filter_bar count={@count} active?={@filters != %{}} clear_event="clear">
        <.field ... />
        <:chips>
          <.filter_chip :for={{k, v} <- @filters} label={label(k, v)}
                        remove_event="drop" value={k} />
        </:chips>
      </.filter_bar>
      <.table rows={@streams.rows} ...>...</.table>
  """
  def filter_bar(assigns) do
    ~H"""
    <section class="aui-filter" role="search" aria-label={@label} data-aui {@rest}>
      <div class="aui-filter__controls">
        {render_slot(@inner_block)}
      </div>

      <div :if={@chips != [] or @active?} class="aui-filter__applied">
        <ul :if={@chips != []} class="aui-filter__chips" aria-label="Applied filters">
          {render_slot(@chips)}
        </ul>
        <button
          :if={@active?}
          type="button"
          class="aui-filter__clear aui-focusable"
          phx-click={@clear_event}
        >
          Clear all
        </button>
      </div>

      <p :if={@count != nil} class="aui-filter__count" role="status" aria-live="polite">
        {@count} {@count_unit}
      </p>
    </section>
    """
  end

  attr :label, :string, required: true, doc: "the chip's visible text"
  attr :remove_event, :string, default: nil, doc: "phx-click emitted by the remove button"
  attr :value, :string, default: nil, doc: "sent as phx-value-key with the remove event"
  attr :rest, :global

  slot :inner_block, doc: "optional custom content in place of `label`"

  @doc """
  A single applied-filter chip. Renders as a list item so it belongs inside the
  `filter_bar` `:chips` slot. When `remove_event` is set, a remove button with a
  descriptive accessible name (`Remove filter: <label>`) is shown.

  ## Examples

      <.filter_chip label="Status: Active" remove_event="drop" value="status" />
  """
  def filter_chip(assigns) do
    ~H"""
    <li class="aui-filter__chip" data-aui {@rest}>
      <span class="aui-filter__chip-label">
        {if @inner_block != [], do: render_slot(@inner_block), else: @label}
      </span>
      <button
        :if={@remove_event}
        type="button"
        class="aui-filter__chip-remove aui-focusable"
        phx-click={@remove_event}
        phx-value-key={@value}
        aria-label={"Remove filter: " <> @label}
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </li>
    """
  end

  attr :title, :string, required: true, doc: "the empty-state headline"
  attr :description, :string, default: nil, doc: "supporting sentence under the title"

  attr :size, :string, default: "md", values: @sizes, doc: "overall scale of the block"

  attr :rest, :global

  slot :icon, doc: "decorative icon or illustration (marked aria-hidden)"
  slot :actions, doc: "primary action(s) that resolve the empty state"

  @doc """
  A centered empty-state block: illustration, title, description, and a primary
  action. Use inside a container that already communicates *what* is empty (a
  card, a panel, a table state) — the block itself is `role="status"` so a
  freshly-loaded empty result is announced.

  ## Examples

      <.empty_state title="No invoices yet" description="Invoices appear here once you bill a customer.">
        <:icon><.receipt_icon /></:icon>
        <:actions><.button phx-click="new">Create invoice</.button></:actions>
      </.empty_state>
  """
  def empty_state(assigns) do
    ~H"""
    <div class={"aui-empty aui-empty--#{@size}"} role="status" data-aui {@rest}>
      <div :if={@icon != []} class="aui-empty__icon" aria-hidden="true">
        {render_slot(@icon)}
      </div>
      <p class="aui-empty__title">{@title}</p>
      <p :if={@description} class="aui-empty__desc">{@description}</p>
      <div :if={@actions != []} class="aui-empty__actions">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  ## Helpers

  defp row_id(_row, index, nil), do: index
  defp row_id(row, _index, fun) when is_function(fun, 1), do: fun.(row)

  defp row_selected?(row, index, row_id_fun, selected) do
    row_id(row, index, row_id_fun) in selected
  end

  # aria-sort value for a header: nil for non-sortable, else none/ascending/descending.
  defp sort_state(col, sort_by, sort_dir) do
    cond do
      !col[:sortable] -> nil
      sorted?(col, sort_by) and sort_dir == "asc" -> "ascending"
      sorted?(col, sort_by) and sort_dir == "desc" -> "descending"
      true -> "none"
    end
  end

  defp sort_dir_of(col, sort_by, sort_dir) do
    if sorted?(col, sort_by), do: sort_dir, else: nil
  end

  defp sorted?(col, sort_by),
    do: sort_by != nil and col[:key] != nil and to_string(col[:key]) == to_string(sort_by)
end
