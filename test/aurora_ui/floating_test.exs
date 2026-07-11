defmodule AuroraUI.Components.FloatingTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias AuroraUI.Components.Floating

  defp html(rendered), do: rendered_to_string(rendered)

  describe "menu/1" do
    test "renders a menu button + role=menu list of menuitems" do
      assigns = %{}

      out =
        html(~H"""
        <Floating.menu id="row" label="Row actions">
          <:item on_click="dup">Duplicate</:item>
          <:item on_click="archive">Archive</:item>
          <:item destructive on_click="delete">Delete</:item>
        </Floating.menu>
        """)

      # trigger button announces the popup
      assert out =~ ~s(phx-hook="AuroraMenu")
      assert out =~ ~s(aria-haspopup="menu")
      assert out =~ ~s(aria-expanded="false")
      assert out =~ ~s(aria-controls="row-list")
      assert out =~ "data-aui-menu-trigger"
      assert out =~ "Row actions"

      # menu list + items with roving-focus tabindex
      assert out =~ ~s(role="menu")
      assert out =~ ~s(id="row-list")
      assert out =~ ~s(aria-labelledby="row-trigger")
      assert out =~ "data-aui-menu"

      menuitems = out |> String.split(~s(role="menuitem")) |> length()
      assert menuitems == 4

      assert out =~ ~s(tabindex="-1")
      assert out =~ "aui-menu__item--danger"
      assert out =~ "Delete"
    end

    test "disabled items are marked for AT and native disabling" do
      assigns = %{}

      out =
        html(~H"""
        <Floating.menu id="m" label="Menu">
          <:item disabled on_click="noop">Unavailable</:item>
        </Floating.menu>
        """)

      assert out =~ ~s(aria-disabled="true")
      assert out =~ "disabled"
    end
  end

  describe "popover/1" do
    test "uses the native popover attribute and anchors to its trigger" do
      assigns = %{}

      out =
        html(~H"""
        <Floating.popover id="acct" label="Account" placement="bottom">
          <p>Signed in</p>
        </Floating.popover>
        """)

      # native popover top-layer baseline. `manual` so the hook owns dismissal
      # (and calls showPopover()/hidePopover() to match the :popover-open CSS).
      assert out =~ ~s(popover="manual")
      assert out =~ ~s(id="acct-panel")

      # hook + positioning contract
      assert out =~ ~s(phx-hook="AuroraPopover")
      assert out =~ "data-aui-popover"
      assert out =~ ~s(data-aui-anchor="acct-trigger")
      assert out =~ ~s(data-aui-placement="bottom")

      # trigger relationship + accessible name
      assert out =~ ~s(aria-expanded="false")
      assert out =~ ~s(aria-controls="acct-panel")
      assert out =~ ~s(aria-label="Account")
    end
  end

  describe "tooltip/1" do
    test "renders role=tooltip referenced via aria-describedby" do
      assigns = %{}

      out =
        html(~H"""
        <Floating.tooltip id="sync" text="Runs every 5 minutes">
          <button>Sync</button>
        </Floating.tooltip>
        """)

      assert out =~ ~s(phx-hook="AuroraTooltip")
      assert out =~ ~s(role="tooltip")
      assert out =~ ~s(id="sync-tip")
      assert out =~ ~s(aria-describedby="sync-tip")
      assert out =~ "data-aui-tooltip"
      assert out =~ ~s(data-aui-placement="top")
      assert out =~ "Runs every 5 minutes"

      # supplementary only — hidden until hover/focus
      assert out =~ "hidden"
    end
  end
end
