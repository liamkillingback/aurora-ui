defmodule DemoWeb.Families.Tabs do
  @moduledoc """
  Component-lab stories for the Tabs family — `tabs/1` (ARIA tablist) and
  `accordion/1` (native disclosure). Follows the `DemoWeb.Families.Actions`
  exemplar: a `@code` map of copyable HEEx plus `lab/1`, which renders a
  `<div class="demo-stories">` of `<.story>` blocks with live previews.
  """
  use DemoWeb, :html

  # Copyable HEEx per story, kept in an attribute so the template has no
  # unindented heredoc lines.
  @code %{
    tabs: ~S|<.tabs id="settings" label="Settings" activation="manual">
  <:tab label="Profile">Your name, avatar, and public handle.</:tab>
  <:tab label="Billing">Plan, payment method, and invoices.</:tab>
  <:tab label="Notifications">Email and in-app alert preferences.</:tab>
  <:tab label="Archived" disabled>Nothing here yet.</:tab>
</.tabs>|,
    tabs_auto: ~S|<.tabs id="report" label="Report" activation="auto">
  <:tab label="Overview">High-level summary.</:tab>
  <:tab label="Traffic">Sessions and sources.</:tab>
  <:tab label="Revenue">Sales and refunds.</:tab>
</.tabs>|,
    accordion_multiple: ~S|<.accordion id="faq" type="multiple">
  <:item title="What is Aurora UI?" open>
    A free, MIT-licensed Phoenix LiveView + Tailwind component kit.
  </:item>
  <:item title="Do I need JavaScript?">
    No — panels are native &lt;details&gt;; the hook only animates open/close.
  </:item>
  <:item title="Is it accessible?">
    Yes — built to WCAG 2.2 AA.
  </:item>
</.accordion>|,
    accordion_single: ~S|<.accordion id="plans" type="single">
  <:item title="Starter" open>Everything you need to launch.</:item>
  <:item title="Team">Collaboration and shared workspaces.</:item>
  <:item title="Enterprise">SSO, audit logs, and support SLAs.</:item>
</.accordion>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Tabs"
        description={"The WAI-ARIA Tabs pattern: a role=\"tablist\" of tabs each linked to a panel. The first tab renders selected on the server; the AuroraTabs hook adds roving tabindex and Arrow/Home/End keys. Pass a stable id."}
        code={@code.tabs}
      >
        <.tabs id="lab-settings" label="Settings" activation="manual">
          <:tab label="Profile">Your name, avatar, and public handle.</:tab>
          <:tab label="Billing">Plan, payment method, and invoices.</:tab>
          <:tab label="Notifications">Email and in-app alert preferences.</:tab>
          <:tab label="Archived" disabled>Nothing here yet.</:tab>
        </.tabs>
      </.story>

      <.story
        title="Tabs — manual vs auto activation"
        description={"activation=\"manual\" (the default) moves focus with the arrow keys and selects on Enter/Space; activation=\"auto\" selects a tab as soon as it receives focus. Prefer manual when panels are expensive to render."}
        code={@code.tabs_auto}
      >
        <.tabs id="lab-report" label="Report" activation="auto">
          <:tab label="Overview">High-level summary.</:tab>
          <:tab label="Traffic">Sessions and sources.</:tab>
          <:tab label="Revenue">Sales and refunds.</:tab>
        </.tabs>
      </.story>

      <.story
        title="Accordion — multiple"
        description={"A stack of native <details> sections. type=\"multiple\" (default) lets any number of items be open at once. Set open on an item to expand it on load."}
        code={@code.accordion_multiple}
      >
        <.accordion id="lab-faq" type="multiple">
          <:item title="What is Aurora UI?" open>
            A free, MIT-licensed Phoenix LiveView + Tailwind component kit.
          </:item>
          <:item title="Do I need JavaScript?">
            No — panels are native <code>&lt;details&gt;</code>; the hook only animates open/close.
          </:item>
          <:item title="Is it accessible?">
            Yes — built to WCAG 2.2 AA.
          </:item>
        </.accordion>
      </.story>

      <.story
        title="Accordion — single"
        description={"type=\"single\" uses native <details name> grouping so opening one item closes the others — exactly one panel stays open at a time."}
        code={@code.accordion_single}
      >
        <.accordion id="lab-plans" type="single">
          <:item title="Starter" open>Everything you need to launch.</:item>
          <:item title="Team">Collaboration and shared workspaces.</:item>
          <:item title="Enterprise">SSO, audit logs, and support SLAs.</:item>
        </.accordion>
      </.story>
    </div>
    """
  end
end
