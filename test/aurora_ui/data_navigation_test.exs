defmodule AuroraUI.Components.DataNavigationTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import AuroraUI.Components.DataNavigation

  defp rows do
    [
      %{id: 1, name: "Ada", email: "ada@example.com", seats: 3},
      %{id: 2, name: "Grace", email: "grace@example.com", seats: 7}
    ]
  end

  describe "table/1 semantics" do
    test "renders a semantic table with a caption and scoped column headers" do
      assigns = %{rows: rows()}

      html =
        rendered_to_string(~H"""
        <.table caption="Team members" rows={@rows}>
          <:col :let={r} label="Name">{r.name}</:col>
          <:col :let={r} label="Email">{r.email}</:col>
        </.table>
        """)

      assert html =~ "<table"
      assert html =~ "<caption"
      assert html =~ "Team members"
      assert html =~ ~s(scope="col")
      assert html =~ ">Name<"
      assert html =~ "Ada"
      assert html =~ "grace@example.com"
    end

    test "sortable columns expose aria-sort and a sort button emitting the event" do
      assigns = %{rows: rows()}

      html =
        rendered_to_string(~H"""
        <.table caption="Users" rows={@rows} sort_by="name" sort_dir="asc" sort_event="sort">
          <:col :let={r} label="Name" key="name" sortable>{r.name}</:col>
          <:col :let={r} label="Email" key="email" sortable>{r.email}</:col>
          <:col :let={r} label="Seats">{r.seats}</:col>
        </.table>
        """)

      # Active column reflects direction; other sortable columns advertise none.
      assert html =~ ~s(aria-sort="ascending")
      assert html =~ ~s(aria-sort="none")
      # Sort control is a real button that emits the documented event + key.
      assert html =~ ~s(phx-click="sort")
      assert html =~ ~s(phx-value-key="name")
    end

    test "descending sort maps to aria-sort=descending" do
      assigns = %{rows: rows()}

      html =
        rendered_to_string(~H"""
        <.table caption="Users" rows={@rows} sort_by="seats" sort_dir="desc">
          <:col :let={r} label="Seats" key="seats" sortable>{r.seats}</:col>
        </.table>
        """)

      assert html =~ ~s(aria-sort="descending")
    end

    test "selectable adds a checkbox column, select-all, and per-row checkboxes" do
      assigns = %{rows: rows(), selected: [1]}

      html =
        rendered_to_string(~H"""
        <.table
          caption="Users"
          rows={@rows}
          selectable
          selected={@selected}
          row_id={& &1.id}
          all_selected={false}
        >
          <:col :let={r} label="Name">{r.name}</:col>
          <:bulk_actions>Archive</:bulk_actions>
        </.table>
        """)

      assert html =~ ~s(type="checkbox")
      assert html =~ ~s(aria-label="Select all rows")
      assert html =~ ~s(aria-label="Select row")
      assert html =~ ~s(phx-value-id="1")
      # Selected row is flagged and the bulk-actions region appears.
      assert html =~ "aui-table__row--selected"
      assert html =~ "Archive"
      assert html =~ "1 selected"
    end

    test "loading renders aria-busy and skeleton rows" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.table caption="Users" rows={[]} loading loading_rows={3}>
          <:col label="Name">x</:col>
        </.table>
        """)

      assert html =~ ~s(aria-busy="true")
      assert html =~ "aui-table__skeleton"
    end

    test "empty state slot renders when there are no rows" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.table caption="Users" rows={[]}>
          <:col label="Name">x</:col>
          <:empty>Nobody here yet.</:empty>
        </.table>
        """)

      assert html =~ "Nobody here yet."
    end

    test "error slot renders in an alert region" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.table caption="Users" rows={[]}>
          <:col label="Name">x</:col>
          <:error>Could not load rows.</:error>
        </.table>
        """)

      assert html =~ ~s(role="alert")
      assert html =~ "Could not load rows."
    end

    test "responsive stack mode adds the stack modifier and data-label cells" do
      assigns = %{rows: rows()}

      html =
        rendered_to_string(~H"""
        <.table caption="Users" rows={@rows} responsive="stack">
          <:col :let={r} label="Name">{r.name}</:col>
        </.table>
        """)

      assert html =~ "aui-table--stack"
      assert html =~ ~s(data-label="Name")
    end
  end

  describe "data_grid/1" do
    test "renders role=grid with gridcells and roving tabindex" do
      assigns = %{rows: rows()}

      html =
        rendered_to_string(~H"""
        <.data_grid rows={@rows} caption="Budget" active_row={0} active_col={1}>
          <:col :let={r} label="Name">{r.name}</:col>
          <:col :let={r} label="Seats" editable>{r.seats}</:col>
        </.data_grid>
        """)

      assert html =~ ~s(role="grid")
      assert html =~ ~s(role="columnheader")
      assert html =~ ~s(role="gridcell")
      # Exactly one active cell holds tabindex=0; the rest are -1.
      assert html =~ ~s(tabindex="0")
      assert html =~ ~s(tabindex="-1")
      # Non-editable column is advertised read-only; the grid exposes its hook contract.
      assert html =~ ~s(aria-readonly="true")
      assert html =~ "data-aui-grid"
    end
  end

  describe "filter_bar/1 and filter_chip/1" do
    test "renders a search region, chips, clear-all, and a live count" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.filter_bar count={12} count_unit="orders" active?={true} clear_event="clear">
          <:chips>
            <.filter_chip label="Status: Active" remove_event="drop" value="status" />
          </:chips>
        </.filter_bar>
        """)

      assert html =~ ~s(role="search")
      assert html =~ ~s(aria-live="polite")
      assert html =~ "12 orders"
      assert html =~ "Status: Active"
      assert html =~ ~s(aria-label="Remove filter: Status: Active")
      assert html =~ ~s(phx-click="drop")
      assert html =~ ~s(phx-click="clear")
    end
  end

  describe "empty_state/1" do
    test "renders a status region with title, description, and actions" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.empty_state title="No invoices" description="They appear here once you bill someone.">
          <:icon>icon</:icon>
          <:actions>Create</:actions>
        </.empty_state>
        """)

      assert html =~ ~s(role="status")
      assert html =~ "No invoices"
      assert html =~ "They appear here once you bill someone."
      assert html =~ "Create"
      assert html =~ ~s(aria-hidden="true")
    end
  end
end
