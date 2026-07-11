defmodule AuroraUI.Components.DataDisplayTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest, except: [render: 1]

  alias AuroraUI.Components.DataDisplay

  defp render(template) when is_function(template, 1) do
    rendered_to_string(template.(%{}))
  end

  describe "card/1" do
    test "renders a semantic <article> with an elevation class" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.card elevation="md">
            <:header>
              <h3>Report</h3>
            </:header>
            <:body>Body</:body>
          </DataDisplay.card>
          """
        end)

      assert html =~ "<article"
      assert html =~ "aui-card--elev-md"
      assert html =~ "<header"
      assert html =~ "Report"
      assert html =~ "Body"
    end

    test "interactive renders a single stretched anchor with an accessible name" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.card interactive navigate="/reports/42" link_label="Open report 42">
            <:header>
              <h3>Report 42</h3>
            </:header>
          </DataDisplay.card>
          """
        end)

      assert html =~ "aui-card--interactive"
      assert html =~ "aui-card__link"
      assert html =~ ~s(aria-label="Open report 42")
      assert html =~ ~s(href="/reports/42")
    end

    test "selected marks the card with aria-current" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.card selected>x</DataDisplay.card>
          """
        end)

      assert html =~ ~s(aria-current="true")
      assert html =~ "aui-card--selected"
    end

    test "loading exposes aria-busy for a skeleton state" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.card loading>x</DataDisplay.card>
          """
        end)

      assert html =~ ~s(aria-busy="true")
      assert html =~ "aui-card--loading"
    end
  end

  describe "badge/1" do
    test "renders variant, size, and a leading dot" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.badge variant="success" size="lg" dot>Live</DataDisplay.badge>
          """
        end)

      assert html =~ "aui-badge--success"
      assert html =~ "aui-badge--lg"
      assert html =~ "aui-badge__dot"
      assert html =~ "Live"
    end

    test "removable renders a real labelled button" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.badge removable on_remove="drop" remove_label="Remove tag">Tag</DataDisplay.badge>
          """
        end)

      assert html =~ "<button"
      assert html =~ "aui-badge__remove"
      assert html =~ ~s(aria-label="Remove tag")
      assert html =~ ~s(phx-click="drop")
    end
  end

  describe "avatar/1" do
    test "with src renders an img carrying the alt text" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.avatar src="/u/ada.jpg" alt="Ada Lovelace" />
          """
        end)

      assert html =~ "<img"
      assert html =~ ~s(alt="Ada Lovelace")
    end

    test "without src falls back to initials with an accessible name" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.avatar name="Grace Hopper" size="lg" />
          """
        end)

      assert html =~ "aui-avatar__fallback"
      assert html =~ ~s(role="img")
      assert html =~ ~s(aria-label="Grace Hopper")
      assert html =~ "GH"
    end

    test "status adds a data attribute and visually-hidden status text" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.avatar name="Ada" status="online" />
          """
        end)

      assert html =~ ~s(data-aui-status="online")
      assert html =~ "aui-avatar__status-dot"
      assert html =~ "aui-sr-only"
      assert html =~ "online"
    end
  end

  describe "avatar_group/1" do
    test "renders a group with an accessible name" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.avatar_group label="Members">
            <DataDisplay.avatar name="Ada" />
          </DataDisplay.avatar_group>
          """
        end)

      assert html =~ ~s(role="group")
      assert html =~ ~s(aria-label="Members")
      assert html =~ "aui-avatar-group"
    end
  end

  describe "stat/1" do
    test "renders label, value, and a delta whose direction is not color-only" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.stat
            label="Revenue"
            value="$48,120"
            delta="12%"
            trend="up"
            description="vs last month"
          />
          """
        end)

      assert html =~ "Revenue"
      assert html =~ "$48,120"
      assert html =~ "aui-stat__delta--up"
      assert html =~ ~s(data-aui-trend="up")
      assert html =~ "increased"
      assert html =~ "12%"
      assert html =~ "vs last month"
    end

    test "down trend announces decreased" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.stat label="Churn" value="3.1%" delta="0.4pt" trend="down" />
          """
        end)

      assert html =~ "aui-stat__delta--down"
      assert html =~ "decreased"
    end
  end

  describe "description_list/1" do
    test "renders semantic dl/dt/dd from item slots" do
      html =
        render(fn assigns ->
          ~H"""
          <DataDisplay.description_list>
            <:item term="Plan">Pro</:item>
            <:item term="Renews">March 1</:item>
          </DataDisplay.description_list>
          """
        end)

      assert html =~ "<dl"
      assert html =~ "<dt"
      assert html =~ "<dd"
      assert html =~ "Plan"
      assert html =~ "Pro"
      assert html =~ "Renews"
      assert html =~ "March 1"
    end
  end
end
