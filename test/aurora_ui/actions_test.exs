defmodule AuroraUI.Components.ActionsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias AuroraUI.Components.Actions

  defp component(fun, assigns), do: apply(Actions, fun, [assigns])

  describe "button/1" do
    test "renders a real <button> by default with variant + size classes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.button>Save</Actions.button>
        """)

      assert html =~ "<button"
      assert html =~ ~s(type="button")
      assert html =~ "aui-btn--primary"
      assert html =~ "aui-btn--md"
      assert html =~ "Save"
    end

    test "becomes an <a> when navigate is set" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.button navigate="/docs">Docs</Actions.button>
        """)

      assert html =~ "<a"
      assert html =~ ~s(href="/docs")
    end

    test "loading sets aria-busy and keeps the control focusable (not disabled)" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.button loading>Saving</Actions.button>
        """)

      assert html =~ ~s(aria-busy="true")
      assert html =~ "aui-btn__spinner"
      refute html =~ "disabled"
    end

    test "disabled renders the disabled attribute" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.button disabled>Nope</Actions.button>
        """)

      assert html =~ "disabled"
    end

    test "danger and full_width variants render their classes" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.button variant="danger" full_width>Delete</Actions.button>
        """)

      assert html =~ "aui-btn--danger"
      assert html =~ "aui-btn--block"
    end

    test "raises on an unknown variant rather than rendering nothing" do
      assert_raise ArgumentError, fn ->
        rendered_to_string(component(:button, %{variant: "bogus", inner_block: inner("x")}))
      end
    end
  end

  describe "icon_button/1" do
    test "requires a label used as aria-label and title" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.icon_button label="Close"><span>x</span></Actions.icon_button>
        """)

      assert html =~ ~s(aria-label="Close")
      assert html =~ ~s(title="Close")
      assert html =~ "aui-btn--icon"
    end
  end

  describe "button_group/1" do
    test "renders role=group with an accessible name" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.button_group label="Text style">
          <Actions.button>B</Actions.button>
        </Actions.button_group>
        """)

      assert html =~ ~s(role="group")
      assert html =~ ~s(aria-label="Text style")
    end
  end

  describe "link_text/1" do
    test "external links get rel/target and a visually-hidden new-tab hint" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Actions.link_text href="https://x.test" external>Out</Actions.link_text>
        """)

      assert html =~ ~s(target="_blank")
      assert html =~ "noopener noreferrer"
      assert html =~ "aui-sr-only"
      assert html =~ "opens in new tab"
    end
  end

  defp inner(text), do: [%{__slot__: :inner_block, inner_block: fn _, _ -> text end}]
end
