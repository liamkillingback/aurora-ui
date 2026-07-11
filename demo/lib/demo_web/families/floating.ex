defmodule DemoWeb.Families.Floating do
  @moduledoc """
  Component-lab stories for the Floating family — `menu/1`, `popover/1`, and
  `tooltip/1`.

  Follows the `DemoWeb.Families.Actions` exemplar. Unlike overlays, every
  component here ships its own trigger: the `AuroraMenu` hook wires the menu's
  `[data-aui-menu-trigger]` button, `popover/1` uses the native `popovertarget`
  invoker, and `tooltip/1` shows on hover and focus of the wrapped control. So
  each preview is fully interactive with no extra wiring.
  """
  use DemoWeb, :html

  @code %{
    menu: ~S|<.menu id="lab-menu" label="Row actions">
  <:item>Duplicate</:item>
  <:item>Rename</:item>
  <:item>Move to…</:item>
  <:item destructive>Delete</:item>
</.menu>|,
    popover: ~S|<.popover id="lab-popover" label="Account">
  <p class="aui-popover__title">Signed in as jane@acme.com</p>
  <p>Free plan · 3 of 5 seats used.</p>
  <.button variant="ghost" size="sm">Sign out</.button>
</.popover>|,
    tooltip: ~S|<.tooltip text="Sync runs every 5 minutes">
  <.icon_button label="Sync info">
    <.icon name="hero-information-circle" class="size-5" />
  </.icon_button>
</.tooltip>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Menu"
        description="A trigger plus a role=menu list of application actions. The hook adds roving focus, typeahead, arrow-key navigation, and Escape to close."
        code={@code.menu}
      >
        <.menu id="lab-menu" label="Row actions">
          <:item>Duplicate</:item>
          <:item>Rename</:item>
          <:item>Move to…</:item>
          <:item destructive>Delete</:item>
        </.menu>
      </.story>

      <.story
        title="Popover"
        description="Non-modal interactive content anchored to a trigger, built on the native popover attribute. The page stays interactive while it is open."
        code={@code.popover}
      >
        <.popover id="lab-popover" label="Account">
          <p style="margin:0 0 .25rem;font-weight:600;color:rgb(var(--aui-text));">
            Signed in as jane@acme.com
          </p>
          <p style="margin:0 0 .75rem;color:rgb(var(--aui-text-muted));">
            Free plan · 3 of 5 seats used.
          </p>
          <.button variant="ghost" size="sm">Sign out</.button>
        </.popover>
      </.story>

      <.story
        title="Tooltip"
        description="Supplementary text shown on hover and keyboard focus, referenced via aria-describedby. Never the only copy of a label or a required instruction."
        code={@code.tooltip}
      >
        <.tooltip text="Sync runs every 5 minutes">
          <.icon_button label="Sync info">
            <.icon name="hero-information-circle" class="size-5" />
          </.icon_button>
        </.tooltip>
      </.story>
    </div>
    """
  end
end
