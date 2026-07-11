defmodule AuroraUI.Components.FeedbackTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest, except: [render: 1]

  alias AuroraUI.Components.Feedback

  defp render(template) when is_function(template, 1) do
    rendered_to_string(template.(%{}))
  end

  describe "alert/1" do
    test "info uses role=status (polite)" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.alert variant="info">All good</Feedback.alert>
          """
        end)

      assert html =~ ~s(role="status")
      assert html =~ "aui-alert--info"
      assert html =~ "All good"
    end

    test "success uses role=status" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.alert variant="success">Saved</Feedback.alert>
          """
        end)

      assert html =~ ~s(role="status")
      assert html =~ "aui-alert--success"
    end

    test "danger uses role=alert (assertive) by default" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.alert variant="danger">Boom</Feedback.alert>
          """
        end)

      assert html =~ ~s(role="alert")
      assert html =~ "aui-alert--danger"
    end

    test "assertive forces role=alert on a non-danger variant" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.alert variant="info" assertive>Urgent</Feedback.alert>
          """
        end)

      assert html =~ ~s(role="alert")
    end

    test "renders a title and a labelled dismiss button when on_dismiss is set" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.alert variant="warning" title="Heads up" on_dismiss="close">
            Body text
          </Feedback.alert>
          """
        end)

      assert html =~ "aui-alert__title"
      assert html =~ "Heads up"
      assert html =~ ~s(aria-label="Dismiss")
      assert html =~ ~s(phx-click="close")
    end

    test "omits the dismiss button without on_dismiss" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.alert>No dismiss</Feedback.alert>
          """
        end)

      refute html =~ "aui-alert__dismiss"
    end
  end

  describe "toast_group/1" do
    test "renders the live region container wired to the hook, polite by default" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.toast_group id="toasts" label="Alerts">x</Feedback.toast_group>
          """
        end)

      assert html =~ "data-aui-toast-region"
      assert html =~ ~s(phx-hook="AuroraToast")
      assert html =~ ~s(aria-live="polite")
      assert html =~ ~s(role="region")
      assert html =~ ~s(aria-label="Alerts")
    end

    test "assertive switches the live region politeness" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.toast_group id="errs" assertive>x</Feedback.toast_group>
          """
        end)

      assert html =~ ~s(aria-live="assertive")
    end
  end

  describe "toast/1" do
    test "renders a list item with severity, timeout, and a labelled dismiss control" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.toast id="t1" severity="success" title="Copied" timeout={4000}>
            Link copied
          </Feedback.toast>
          """
        end)

      assert html =~ "<li"
      assert html =~ "aui-toast--success"
      assert html =~ ~s(data-aui-severity="success")
      assert html =~ ~s(data-aui-timeout="4000")
      assert html =~ ~s(data-aui-toast-close)
      assert html =~ ~s(aria-label="Dismiss")
      assert html =~ "Copied"
    end

    test "timeout of 0 makes the toast persistent (no data-aui-timeout)" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.toast id="t2" severity="danger" timeout={0}>Stay</Feedback.toast>
          """
        end)

      refute html =~ "data-aui-timeout"
    end
  end

  describe "inline_status/1" do
    test "renders a dot and a text label" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.inline_status severity="success" label="Operational" />
          """
        end)

      assert html =~ "aui-status--success"
      assert html =~ "aui-status__dot"
      assert html =~ "Operational"
    end

    test "inner block overrides the label attr" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.inline_status severity="warning">Degraded</Feedback.inline_status>
          """
        end)

      assert html =~ "Degraded"
      assert html =~ "aui-status--warning"
    end
  end

  describe "connection_state/1" do
    test "wires the connection hook and a calm polite live region" do
      html =
        render(fn assigns ->
          ~H"""
          <Feedback.connection_state id="conn" />
          """
        end)

      assert html =~ ~s(phx-hook="AuroraConnectionState")
      assert html =~ ~s(data-aui-conn="connected")
      assert html =~ ~s(role="status")
      assert html =~ ~s(aria-live="polite")
      assert html =~ "Reconnecting"
    end
  end
end
