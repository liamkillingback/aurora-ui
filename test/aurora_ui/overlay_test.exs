defmodule AuroraUI.Components.OverlayTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias AuroraUI.Components.Overlay

  defp html(rendered), do: rendered_to_string(rendered)

  describe "dialog/1" do
    test "renders a native dialog wired for the hook and ARIA relationships" do
      assigns = %{}

      out =
        html(~H"""
        <Overlay.dialog id="invite" open on_close="close_invite">
          <:title>Invite teammates</:title>
          <:description>They receive a join link by email.</:description>
          <p>Body</p>
          <:footer>
            <button data-aui-dialog-close>Cancel</button>
          </:footer>
        </Overlay.dialog>
        """)

      # native dialog element + hook contract
      assert out =~ ~s(<dialog)
      assert out =~ ~s(id="invite")
      assert out =~ ~s(phx-hook="AuroraDialog")
      assert out =~ "data-aui-dialog"
      assert out =~ ~s(data-aui-open="true")
      assert out =~ ~s(aria-modal="true")

      # accessible name/description are wired to deterministic ids
      assert out =~ ~s(aria-labelledby="invite-title")
      assert out =~ ~s(aria-describedby="invite-desc")
      assert out =~ ~s(id="invite-title")
      assert out =~ ~s(id="invite-desc")
      assert out =~ "Invite teammates"

      # an explicit close control exists
      assert out =~ "data-aui-dialog-close"
      assert out =~ ~s(aria-label="Close")
    end

    test "is dismissable by default and reflects a non-dismissable flag" do
      assigns = %{}

      dismissable =
        html(~H"""
        <Overlay.dialog id="a"><:title>T</:title>Body</Overlay.dialog>
        """)

      assert dismissable =~ ~s(data-aui-dismissable="true")

      locked =
        html(~H"""
        <Overlay.dialog id="b" dismissable={false}><:title>T</:title>Body</Overlay.dialog>
        """)

      assert locked =~ ~s(data-aui-dismissable="false")
    end

    test "closed dialog omits the open flag" do
      assigns = %{}

      out =
        html(~H"""
        <Overlay.dialog id="c"><:title>T</:title>Body</Overlay.dialog>
        """)

      refute out =~ ~s(data-aui-open="true")
    end
  end

  describe "alert_dialog/1" do
    test "uses role=alertdialog, is non-dismissable, and requires confirm + cancel" do
      assigns = %{}

      out =
        html(~H"""
        <Overlay.alert_dialog
          id="del"
          open
          on_confirm="delete"
          on_cancel="cancel"
          confirm_label="Delete project"
          cancel_label="Keep it"
        >
          <:title>Delete this project?</:title>
          <:description>This cannot be undone.</:description>
        </Overlay.alert_dialog>
        """)

      assert out =~ ~s(role="alertdialog")
      assert out =~ ~s(data-aui-dismissable="false")
      assert out =~ ~s(aria-labelledby="del-title")
      assert out =~ ~s(aria-describedby="del-desc")

      # both actions present
      assert out =~ "Delete project"
      assert out =~ "Keep it"
      assert out =~ "data-aui-dialog-confirm"
      assert out =~ "data-aui-dialog-close"
    end

    test "initial focus lands on the least destructive (cancel) action" do
      assigns = %{}

      out =
        html(~H"""
        <Overlay.alert_dialog id="d" on_confirm="ok">
          <:title>Sure?</:title>
          <:description>Consequence.</:description>
        </Overlay.alert_dialog>
        """)

      # autofocus is on the cancel button, which also carries the close marker
      cancel = out |> String.split("<button") |> Enum.find(&(&1 =~ "data-aui-dialog-close"))
      assert cancel =~ "autofocus"
    end
  end

  describe "drawer/1" do
    test "renders side + modal contract and defaults to modal" do
      assigns = %{}

      out =
        html(~H"""
        <Overlay.drawer id="nav" side="start" open>
          <:title>Menu</:title>
          <p>Links</p>
        </Overlay.drawer>
        """)

      assert out =~ ~s(phx-hook="AuroraDrawer")
      assert out =~ "data-aui-drawer"
      assert out =~ ~s(data-aui-side="start")
      assert out =~ ~s(data-aui-modal="true")
      assert out =~ ~s(aria-modal="true")
      assert out =~ ~s(role="dialog")
      assert out =~ ~s(aria-labelledby="nav-title")
      assert out =~ "data-aui-drawer-close"
    end

    test "non-modal drawer drops modal semantics" do
      assigns = %{}

      out =
        html(~H"""
        <Overlay.drawer id="f" side="end" modal={false}>
          <:title>Filters</:title>
          <p>Controls</p>
        </Overlay.drawer>
        """)

      assert out =~ ~s(data-aui-modal="false")
      assert out =~ ~s(aria-modal="false")
      assert out =~ ~s(data-aui-side="end")
    end
  end
end
