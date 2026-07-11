defmodule DemoWeb.Families.DataNavigation do
  @moduledoc """
  Component-lab stories for the DataNavigation family — the semantic `table`
  (sorting, selection, loading + empty states), an interactive `data_grid`, the
  `filter_bar` (+ `filter_chip`), and `empty_state`. Follows the
  `DemoWeb.Families.Actions` exemplar.
  """
  use DemoWeb, :html

  alias Demo.Sample

  @code %{
    table: ~S|<.table
  caption="Team members"
  rows={@rows}
  selectable
  selected={[1, 3]}
  row_id={& &1.id}
  sort_by="name"
  sort_dir="asc"
>
  <:col :let={r} label="Name" key="name" sortable>{r.name}</:col>
  <:col :let={r} label="Email">{r.email}</:col>
  <:col :let={r} label="Role">{r.role}</:col>
  <:col :let={r} label="Project">{r.project}</:col>
  <:bulk_actions>
    <.button variant="danger" size="sm">Archive</.button>
  </:bulk_actions>
</.table>|,
    table_empty: ~S|<.table caption="Team members" rows={[]}>
  <:col :let={r} label="Name">{r.name}</:col>
  <:col :let={r} label="Role">{r.role}</:col>
  <:empty>No members match your filters.</:empty>
</.table>|,
    table_loading: ~S|<.table caption="Team members" rows={[]} loading loading_rows={4}>
  <:col :let={r} label="Name">{r.name}</:col>
  <:col :let={r} label="Email">{r.email}</:col>
  <:col :let={r} label="Role">{r.role}</:col>
</.table>|,
    data_grid:
      ~S|<.data_grid rows={@cells} active_row={0} active_col={1} caption="Quarterly budget">
  <:col :let={row} label="Item">{row.item}</:col>
  <:col :let={row} label="Amount" editable>{row.amount}</:col>
  <:col :let={row} label="Owner" editable>{row.owner}</:col>
</.data_grid>|,
    filter_bar: ~S|<.filter_bar count={3} count_unit="projects" active? clear_event="clear">
  <:chips>
    <.filter_chip label="Status: Active" remove_event="drop" value="status" />
    <.filter_chip label="Owner: Ada Lovelace" remove_event="drop" value="owner" />
  </:chips>
</.filter_bar>|,
    empty_state: ~S|<.empty_state
  title="No projects yet"
  description="Projects appear here once you create your first one."
>
  <:icon><.icon name="hero-folder-plus" class="size-8" /></:icon>
  <:actions><.button>New project</.button></:actions>
</.empty_state>|
  }

  def lab(assigns) do
    assigns =
      assigns
      |> assign(:code, @code)
      |> assign(:rows, Sample.table_rows())
      |> assign(:cells, budget_cells())

    ~H"""
    <div class="demo-stories">
      <.story
        title="Table"
        description="A semantic <table> with a sortable column, row selection, and bulk actions."
        code={@code.table}
      >
        <.table
          caption="Team members"
          rows={@rows}
          selectable
          selected={[1, 3]}
          row_id={& &1.id}
          sort_by="name"
          sort_dir="asc"
        >
          <:col :let={r} label="Name" key="name" sortable>{r.name}</:col>
          <:col :let={r} label="Email">{r.email}</:col>
          <:col :let={r} label="Role">{r.role}</:col>
          <:col :let={r} label="Project">{r.project}</:col>
          <:bulk_actions>
            <.button variant="danger" size="sm">Archive</.button>
          </:bulk_actions>
        </.table>
      </.story>

      <.story
        title="Table — empty state"
        description="When rows is empty and not loading, the :empty slot fills the table body."
        code={@code.table_empty}
      >
        <.table caption="Team members" rows={[]}>
          <:col :let={r} label="Name">{r.name}</:col>
          <:col :let={r} label="Role">{r.role}</:col>
          <:empty>No members match your filters.</:empty>
        </.table>
      </.story>

      <.story
        title="Table — loading state"
        description="Shimmer skeleton rows hold layout and set aria-busy while data loads."
        code={@code.table_loading}
      >
        <.table caption="Team members" rows={[]} loading loading_rows={4}>
          <:col :let={r} label="Name">{r.name}</:col>
          <:col :let={r} label="Email">{r.email}</:col>
          <:col :let={r} label="Role">{r.role}</:col>
        </.table>
      </.story>

      <.story
        title="Data grid"
        description="An interactive role=grid for cell-by-cell focus and in-place editing."
        code={@code.data_grid}
      >
        <.data_grid rows={@cells} active_row={0} active_col={1} caption="Quarterly budget">
          <:col :let={row} label="Item">{row.item}</:col>
          <:col :let={row} label="Amount" editable>{row.amount}</:col>
          <:col :let={row} label="Owner" editable>{row.owner}</:col>
        </.data_grid>
      </.story>

      <.story
        title="Filter bar"
        description="Applied-filter chips, a clear-all button, and a politely-announced result count."
        code={@code.filter_bar}
      >
        <.filter_bar count={3} count_unit="projects" active? clear_event="clear">
          <:chips>
            <.filter_chip label="Status: Active" remove_event="drop" value="status" />
            <.filter_chip label="Owner: Ada Lovelace" remove_event="drop" value="owner" />
          </:chips>
        </.filter_bar>
      </.story>

      <.story
        title="Empty state"
        description="A centered block with an illustration, copy, and a primary action."
        code={@code.empty_state}
      >
        <.empty_state
          title="No projects yet"
          description="Projects appear here once you create your first one."
        >
          <:icon><.icon name="hero-folder-plus" class="size-8" /></:icon>
          <:actions><.button>New project</.button></:actions>
        </.empty_state>
      </.story>
    </div>
    """
  end

  defp budget_cells do
    [
      %{item: "Cloud hosting", amount: "$4,200", owner: "Ada Lovelace"},
      %{item: "Design tools", amount: "$1,150", owner: "Grace Hopper"},
      %{item: "Contractors", amount: "$8,900", owner: "Alan Turing"}
    ]
  end
end
