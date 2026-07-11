defmodule AuroraUI.SelectionTest do
  use ExUnit.Case, async: true

  import Phoenix.Component, except: [slot: 2, slot: 1]
  import Phoenix.LiveViewTest
  import AuroraUI.Components.Selection

  defp slot(name, content) do
    [%{__slot__: name, inner_block: fn _assigns, _arg -> content end}]
  end

  defp option(attrs, content) do
    Map.merge(%{__slot__: :option, inner_block: fn _assigns, _arg -> content end}, attrs)
  end

  describe "select/1" do
    test "renders a native select with a label association and options" do
      html =
        render_component(&select/1,
          id: "country",
          name: "country",
          label: "Country",
          value: "uk",
          prompt: "Choose…",
          options: [{"United States", "us"}, {"United Kingdom", "uk"}]
        )

      assert html =~ ~s(<label for="country")
      assert html =~ "<select"
      assert html =~ ~s(id="country")
      assert html =~ "Choose…"
      assert html =~ ~s(value="us")
      assert html =~ ~s(value="uk")
      # selected option carries `selected`
      assert html =~ ~s(value="uk" selected)
    end

    test "invalid and size variants are reflected" do
      html =
        render_component(&select/1,
          id: "c",
          invalid: true,
          size: "lg",
          options: [{"A", "a"}]
        )

      assert html =~ ~s(aria-invalid="true")
      assert html =~ "aui-select--invalid"
      assert html =~ "aui-select--lg"
    end

    test "description slot is wired via aria-describedby" do
      html =
        render_component(&select/1,
          id: "c",
          options: [{"A", "a"}],
          description: slot(:description, "Pick one")
        )

      assert html =~ ~s(aria-describedby="c-desc")
      assert html =~ ~s(id="c-desc")
      assert html =~ "Pick one"
    end

    test "disabled select" do
      html = render_component(&select/1, id: "c", disabled: true, options: [])
      assert html =~ "disabled"
    end
  end

  describe "combobox/1" do
    test "renders the correct ARIA combobox skeleton and hook target" do
      html =
        render_component(&combobox/1,
          id: "fruit",
          name: "fruit",
          label: "Fruit",
          value: "ap",
          selected: "1",
          open: true,
          option: [
            option(%{value: "1", selected: true}, "Apple"),
            option(%{value: "2"}, "Banana")
          ]
        )

      assert html =~ ~s(role="combobox")
      assert html =~ ~s(phx-hook="AuroraCombobox")
      assert html =~ ~s(aria-autocomplete="list")
      assert html =~ ~s(aria-expanded="true")
      assert html =~ ~s(aria-controls="fruit-listbox")
      assert html =~ ~s(id="fruit-listbox")
      assert html =~ ~s(role="listbox")
      assert html =~ ~s(role="option")
      assert html =~ ~s(id="fruit-option-s0")
      assert html =~ ~s(aria-selected="true")
      assert html =~ ~s(aria-selected="false")
      assert html =~ ~s(data-value="1")
      assert html =~ "Apple"
      assert html =~ "Banana"
      # a clear button by default
      assert html =~ "aui-combobox__clear"
      assert html =~ ~s(aria-label="Clear")
    end

    test "options attribute renders deterministic option ids and selection" do
      html =
        render_component(&combobox/1,
          id: "c",
          open: true,
          selected: "2",
          options: [{"Apple", "1"}, {"Banana", "2"}]
        )

      assert html =~ ~s(id="c-option-0")
      assert html =~ ~s(id="c-option-1")
      assert html =~ ~s(data-value="2")
      assert html =~ ~s(aria-selected="true")
    end

    test "loading sets aria-busy and suppresses the no-results row" do
      html = render_component(&combobox/1, id: "c", open: true, loading: true, options: [])

      assert html =~ ~s(aria-busy="true")
      assert html =~ "aui-combobox__spinner"
      refute html =~ "aui-combobox__empty"
    end

    test "empty options show the no-results row" do
      html =
        render_component(&combobox/1,
          id: "c",
          open: true,
          options: [],
          empty_label: "Nothing here"
        )

      assert html =~ "aui-combobox__empty"
      assert html =~ "Nothing here"
    end

    test "disabled combobox hides the clear button and disables the input" do
      html = render_component(&combobox/1, id: "c", disabled: true)

      assert html =~ "disabled"
      assert html =~ "aui-combobox--disabled"
      refute html =~ "aui-combobox__clear"
    end
  end
end
