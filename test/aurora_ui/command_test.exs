defmodule AuroraUI.Components.CommandTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias AuroraUI.Components.Command

  describe "search_field/1" do
    test "renders a search landmark with an explicit searchbox role" do
      html = render_component(&Command.search_field/1, name: "q", label: "Find")

      assert html =~ ~s(role="search")
      assert html =~ ~s(type="search")
      assert html =~ ~s(role="searchbox")
      assert html =~ ~s(aria-label="Find")
      assert html =~ ~s(name="q")
    end

    test "renders a leading icon and a clear button" do
      html = render_component(&Command.search_field/1, [])

      assert html =~ "aui-search__icon"
      assert html =~ ~s(aria-label="Clear search")
      assert html =~ "data-aui-search-clear"
    end

    test "loading sets aria-busy and shows a spinner" do
      html = render_component(&Command.search_field/1, loading: true)

      assert html =~ ~s(aria-busy="true")
      assert html =~ "aui-search__spinner"
    end

    test "forwards phx-debounce for live-search debouncing" do
      html = render_component(&Command.search_field/1, debounce: 200)

      assert html =~ ~s(phx-debounce="200")
    end
  end

  describe "search_results/1" do
    test "announces the result count in a polite live region" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Command.search_results count={3}>
          <Command.search_result href="/a">Alpha</Command.search_result>
        </Command.search_results>
        """)

      assert html =~ ~s(aria-live="polite")
      assert html =~ "3 results."
      assert html =~ ~s(role="list")
    end

    test "singular count message" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Command.search_results count={1}>
          <Command.search_result href="/a">Alpha</Command.search_result>
        </Command.search_results>
        """)

      assert html =~ "1 result."
    end

    test "renders the empty slot with suggestions when count is zero" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Command.search_results count={0}>
          <:empty>Try <em>installation</em></:empty>
        </Command.search_results>
        """)

      assert html =~ "aui-search-results__empty"
      assert html =~ "installation"
      refute html =~ ~s(role="list")
    end

    test "renders titled groups" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Command.search_results count={2}>
          <:group label="Docs">
            <Command.search_result href="/a">Alpha</Command.search_result>
          </:group>
        </Command.search_results>
        """)

      assert html =~ "aui-search-results__group-label"
      assert html =~ "Docs"
    end
  end

  describe "search_result/1" do
    test "renders a list item with a link when navigable" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Command.search_result href="/docs/x">
          <:icon>i</:icon>
          Result title
          <:meta>2m ago</:meta>
        </Command.search_result>
        """)

      assert html =~ "<li"
      assert html =~ ~s(href="/docs/x")
      assert html =~ "Result title"
      assert html =~ "2m ago"
    end
  end

  describe "command_palette/1" do
    test "renders dialog semantics with a labelled title" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Command.command_palette id="cmdk" label="Commands">
          <:group label="Nav">
            <button role="option" data-aui-command-item>Go home</button>
          </:group>
        </Command.command_palette>
        """)

      assert html =~ ~s(role="dialog")
      assert html =~ ~s(aria-modal="true")
      assert html =~ ~s(aria-labelledby="cmdk-title")
      assert html =~ ~s(id="cmdk-title")
    end

    test "uses the lazy command palette hook on a stable id" do
      html = render_component(&Command.command_palette/1, id: "cmdk")

      assert html =~ ~s(phx-hook="AuroraCommandPalette")
      assert html =~ ~s(id="cmdk-dialog")
      assert html =~ "data-aui-command"
    end

    test "exposes a visible trigger button (no-shortcut equivalence)" do
      html =
        render_component(&Command.command_palette/1, id: "cmdk", trigger_label: "Search commands")

      assert html =~ "data-aui-command-open"
      assert html =~ ~s(aria-haspopup="dialog")
      assert html =~ "Search commands"
    end

    test "shows a discoverable kbd hint only when a shortcut is configured" do
      with_shortcut =
        render_component(&Command.command_palette/1, id: "cmdk", shortcut: "⌘K")

      without =
        render_component(&Command.command_palette/1, id: "cmdk2")

      assert with_shortcut =~ "aui-command__kbd"
      assert with_shortcut =~ ~s(data-aui-shortcut="⌘K")
      assert with_shortcut =~ "⌘K"
      refute without =~ "aui-command__kbd"
    end

    test "uses combobox + listbox pattern for filtering" do
      html = render_component(&Command.command_palette/1, id: "cmdk")

      assert html =~ ~s(role="combobox")
      assert html =~ ~s(role="listbox")
      assert html =~ "data-aui-command-input"
    end
  end
end
