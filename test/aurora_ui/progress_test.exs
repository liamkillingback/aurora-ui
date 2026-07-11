defmodule AuroraUI.Components.ProgressTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import AuroraUI.Components.Progress

  describe "spinner/1" do
    test "renders a status region with a visually-hidden label" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.spinner label="Saving changes" size="lg" />
        """)

      assert html =~ ~s(role="status")
      assert html =~ "aui-spinner--lg"
      assert html =~ "aui-sr-only"
      assert html =~ "Saving changes"
      # The animated element itself is hidden from AT.
      assert html =~ ~s(aria-hidden="true")
    end
  end

  describe "progress/1 determinate" do
    test "renders role=progressbar with aria-value min/max/now" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.progress value={64} label="Uploading" show_value />
        """)

      assert html =~ ~s(role="progressbar")
      assert html =~ ~s(aria-valuemin="0")
      assert html =~ ~s(aria-valuemax="100")
      assert html =~ ~s(aria-valuenow="64")
      assert html =~ "Uploading"
      # Visible percentage + a labelledby relationship to the label.
      assert html =~ "64%"
      assert html =~ "aria-labelledby"
    end

    test "computes the percentage against a custom min/max" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.progress value={5} min={0} max={20} label="Steps" show_value />
        """)

      assert html =~ ~s(aria-valuenow="5")
      assert html =~ ~s(aria-valuemax="20")
      assert html =~ "25%"
    end
  end

  describe "progress/1 indeterminate" do
    test "omits aria-valuenow and marks the track indeterminate" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.progress indeterminate label="Processing" />
        """)

      assert html =~ ~s(role="progressbar")
      assert html =~ "aui-progress__track--indeterminate"
      refute html =~ "aria-valuenow"
    end

    test "a nil value is treated as indeterminate" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.progress label="Working" />
        """)

      refute html =~ "aria-valuenow"
    end
  end

  describe "skeleton/1" do
    test "reserves layout with explicit size and is hidden from AT" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.skeleton width="12rem" height="1.25rem" shape="text" />
        """)

      assert html =~ "aui-skeleton"
      assert html =~ "aui-skeleton--text"
      assert html =~ ~s(aria-hidden="true")
      assert html =~ "inline-size: 12rem"
      assert html =~ "block-size: 1.25rem"
    end

    test "circle shape squares the box off the height" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.skeleton height="3rem" shape="circle" />
        """)

      assert html =~ "aui-skeleton--circle"
      assert html =~ "inline-size: 3rem"
      assert html =~ "block-size: 3rem"
    end
  end

  describe "async_state/1" do
    test "renders the loading branch (with a default spinner) for :loading" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.async_state state={:loading}>
          <:empty>empty</:empty>
          <:error>error</:error>
          <p>loaded content</p>
        </.async_state>
        """)

      assert html =~ ~s(role="status")
      assert html =~ "aui-spinner"
      refute html =~ "loaded content"
    end

    test "renders the ok branch for :ok" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.async_state state={:ok}>
          <:loading>loading</:loading>
          <:empty>empty</:empty>
          <:error>error</:error>
          <p>loaded content</p>
        </.async_state>
        """)

      assert html =~ "loaded content"
      refute html =~ ">loading<"
    end

    test "renders the error branch in a role=alert region" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.async_state state={:error}>
          <:error>Something went wrong.</:error>
          <p>loaded content</p>
        </.async_state>
        """)

      assert html =~ ~s(role="alert")
      assert html =~ "Something went wrong."
      refute html =~ "loaded content"
    end

    test "renders the empty branch for :empty" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.async_state state={:empty}>
          <:empty>No results yet.</:empty>
          <p>loaded content</p>
        </.async_state>
        """)

      assert html =~ "No results yet."
      refute html =~ "loaded content"
    end
  end
end
