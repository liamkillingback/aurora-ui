defmodule AuroraUI.TabsTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import AuroraUI.Components.Tabs

  describe "tabs/1" do
    test "renders the ARIA tabs pattern with correct roles and wiring" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tabs id="settings" label="Settings">
          <:tab label="Profile">Profile content</:tab>
          <:tab label="Billing">Billing content</:tab>
        </.tabs>
        """)

      assert html =~ ~s(phx-hook="AuroraTabs")
      assert html =~ ~s(data-aui-activation="manual")
      assert html =~ ~s(role="tablist")
      assert html =~ ~s(aria-label="Settings")
      assert html =~ ~s(aria-orientation="horizontal")
      assert html =~ ~s(role="tab")
      assert html =~ ~s(role="tabpanel")

      # tab/panel ids derive from the stable component id
      assert html =~ ~s(id="settings-tab-0")
      assert html =~ ~s(id="settings-panel-0")
      assert html =~ ~s(aria-controls="settings-panel-0")
      assert html =~ ~s(aria-labelledby="settings-tab-0")
    end

    test "selects the first tab and applies roving tabindex" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tabs id="t" label="Tabs">
          <:tab label="One">1</:tab>
          <:tab label="Two">2</:tab>
        </.tabs>
        """)

      assert html =~ ~s(id="t-tab-0")
      # first tab selected + focusable
      assert html =~ ~r/id="t-tab-0".*?aria-selected="true"/s
      assert html =~ ~r/id="t-tab-0".*?tabindex="0"/s
      # second tab not selected + removed from tab order
      assert html =~ ~r/id="t-tab-1".*?aria-selected="false"/s
      assert html =~ ~r/id="t-tab-1".*?tabindex="-1"/s
    end

    test "hides non-active panels" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tabs id="t" label="Tabs">
          <:tab label="One">1</:tab>
          <:tab label="Two">2</:tab>
        </.tabs>
        """)

      # panel 0 visible, panel 1 hidden
      refute html =~ ~r/id="t-panel-0"[^>]*hidden/
      assert html =~ ~r/id="t-panel-1"[^>]*hidden/
    end

    test "honours the auto activation and vertical orientation attrs" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tabs id="t" label="Tabs" activation="auto" orientation="vertical">
          <:tab label="One">1</:tab>
        </.tabs>
        """)

      assert html =~ ~s(data-aui-activation="auto")
      assert html =~ ~s(aria-orientation="vertical")
      assert html =~ "aui-tabs--vertical"
    end

    test "disables a tab" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.tabs id="t" label="Tabs">
          <:tab label="One">1</:tab>
          <:tab label="Archived" disabled>2</:tab>
        </.tabs>
        """)

      assert html =~ ~r/id="t-tab-1"[^>]*disabled/
    end
  end

  describe "accordion/1" do
    test "renders native details/summary with the disclosure hook" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion id="faq">
          <:item title="Question one">Answer one</:item>
          <:item title="Question two">Answer two</:item>
        </.accordion>
        """)

      assert html =~ "<details"
      assert html =~ "<summary"
      assert html =~ ~s(phx-hook="AuroraDisclosure")
      assert html =~ ~s(id="faq-item-0")
      assert html =~ "Question one"
      assert html =~ "Answer one"
    end

    test "single type groups details by a shared name for exclusive open" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion id="faq" type="single">
          <:item title="One">a</:item>
          <:item title="Two">b</:item>
        </.accordion>
        """)

      assert html =~ ~s(name="faq")
    end

    test "multiple type does not set a grouping name" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion id="faq" type="multiple">
          <:item title="One">a</:item>
        </.accordion>
        """)

      refute html =~ ~s(name="faq")
    end

    test "opens an item marked open on the server" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.accordion id="faq">
          <:item title="Closed">a</:item>
          <:item title="Open me" open>b</:item>
        </.accordion>
        """)

      assert html =~ ~r/id="faq-item-1"[^>]*open/
      refute html =~ ~r/id="faq-item-0"[^>]*open/
    end
  end
end
