defmodule AuroraUI.NavigationTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import AuroraUI.Components.Navigation

  describe "skip_link/1" do
    test "renders a focusable anchor with a default label" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.skip_link href="#main" />
        """)

      assert html =~ ~s(href="#main")
      assert html =~ "aui-navbar__skip"
      assert html =~ "aui-focusable"
      assert html =~ "Skip to content"
    end

    test "uses custom slot content" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.skip_link href="#content">Jump ahead</.skip_link>
        """)

      assert html =~ "Jump ahead"
    end
  end

  describe "navbar/1" do
    test "renders a labelled nav landmark with a native disclosure" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.navbar id="site-nav" label="Primary">
          <:brand>Aurora</:brand>
          <:link navigate="/" current>Home</:link>
          <:link navigate="/docs">Docs</:link>
          <:actions>Sign in</:actions>
        </.navbar>
        """)

      assert html =~ ~s(<nav class="aui-navbar" aria-label="Primary")
      assert html =~ "<details"
      assert html =~ ~s(id="site-nav")
      assert html =~ "Aurora"
      assert html =~ "Sign in"
    end

    test "marks the current link with aria-current=page and no others" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.navbar id="nav">
          <:link navigate="/" current>Home</:link>
          <:link navigate="/docs">Docs</:link>
        </.navbar>
        """)

      # Exactly one aria-current="page".
      assert length(String.split(html, ~s(aria-current="page"))) == 2
    end

    test "does not use phx-update ignore" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.navbar id="nav"><:link navigate="/">Home</:link></.navbar>
        """)

      refute html =~ "phx-update"
    end
  end

  describe "sidebar/1" do
    test "renders sections, headings, items, current and collapsible group" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.sidebar label="Docs">
          <:section label="Getting started">
            <.sidebar_item navigate="/install" current>Install</.sidebar_item>
            <.sidebar_item navigate="/theming">Theming</.sidebar_item>
          </:section>
          <.sidebar_group label="Components">
            <.sidebar_item navigate="/components/button">Button</.sidebar_item>
          </.sidebar_group>
        </.sidebar>
        """)

      assert html =~ ~s(aria-label="Docs")
      assert html =~ "aui-sidebar__heading"
      assert html =~ "Getting started"
      assert html =~ ~s(aria-current="page")
      # collapsible group is a native details, open by default
      assert html =~ "aui-sidebar__group"
      assert html =~ ~s(<details class="aui-sidebar__group" open)
    end
  end

  describe "breadcrumbs/1" do
    test "renders an ordered list with the last crumb as aria-current" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.breadcrumbs label="Breadcrumb">
          <:crumb navigate="/">Home</:crumb>
          <:crumb navigate="/docs">Docs</:crumb>
          <:crumb>Navigation</:crumb>
        </.breadcrumbs>
        """)

      assert html =~ ~s(<nav class="aui-breadcrumbs" aria-label="Breadcrumb")
      assert html =~ "<ol"
      # the trailing crumb is a plain current element, not a link
      assert html =~ ~s(<span class="aui-breadcrumbs__current" aria-current="page">)
      assert html =~ "Navigation"
      # exactly one current marker
      assert length(String.split(html, ~s(aria-current="page"))) == 2
    end
  end

  describe "pagination/1" do
    test "renders a labelled nav with numbered pages and current marker" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.pagination page={2} total_pages={5} path={fn n -> "/p/#{n}" end} />
        """)

      assert html =~ ~s(<nav class="aui-pagination" aria-label="Pagination")
      assert html =~ ~s(href="/p/1")
      assert html =~ ~s(href="/p/3")
      assert html =~ ~s(aria-current="page")
    end

    test "disables prev at the first page and next at the last" do
      assigns = %{}

      first =
        rendered_to_string(~H"""
        <.pagination page={1} total_pages={5} path={fn n -> "/p/#{n}" end} />
        """)

      assert first =~ ~s(aria-disabled="true")
      # prev disabled -> rendered as a span, not a link with href to page 0
      refute first =~ ~s(href="/p/0")

      last =
        rendered_to_string(~H"""
        <.pagination page={5} total_pages={5} path={fn n -> "/p/#{n}" end} />
        """)

      assert last =~ ~s(aria-disabled="true")
      refute last =~ ~s(href="/p/6")
    end

    test "truncates long ranges with an ellipsis gap" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.pagination page={10} total_pages={20} path={fn n -> "/p/#{n}" end} />
        """)

      assert html =~ "aui-pagination__gap"
      assert html =~ "…"
    end

    test "page_items builds a truncated range with gap markers" do
      assert page_items(6, 20, 1) == [1, :gap, 5, 6, 7, :gap, 20]
      assert page_items(1, 3, 1) == [1, 2, 3]
      assert page_items(1, 1, 1) == [1]
      assert page_items(3, 0, 1) == []
    end
  end

  describe "steps/1" do
    test "derives states and marks the current step with aria-current=step" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.steps current={2}>
          <:step label="Account" description="Create your account" />
          <:step label="Profile" description="Add your details" />
          <:step label="Done" />
        </.steps>
        """)

      assert html =~ ~s(<nav class="aui-steps aui-steps--horizontal" aria-label="Progress")
      assert html =~ "aui-steps__item--complete"
      assert html =~ "aui-steps__item--current"
      assert html =~ "aui-steps__item--upcoming"
      assert html =~ ~s(aria-current="step")
      # completed step announces state to AT
      assert html =~ "(completed)"
    end

    test "supports vertical orientation" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.steps current={1} orientation="vertical">
          <:step label="One" />
          <:step label="Two" />
        </.steps>
        """)

      assert html =~ "aui-steps--vertical"
    end
  end
end
