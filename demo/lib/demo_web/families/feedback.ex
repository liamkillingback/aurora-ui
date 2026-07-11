defmodule DemoWeb.Families.Feedback do
  @moduledoc """
  Component-lab stories for the Feedback family — `alert/1`, `inline_status/1`,
  `connection_state/1`, and a `toast_group/1` of `toast/1` items.

  Follows the `DemoWeb.Families.Actions` exemplar. Toasts are streamed live
  regions in production; here they are rendered statically inside the region with
  `timeout={0}` so the preview stays put instead of auto-dismissing. Their
  built-in dismiss buttons (`[data-aui-toast-close]`) are still wired by the
  `AuroraToast` hook.
  """
  use DemoWeb, :html

  @code %{
    alerts: ~S|<.alert variant="info" title="Heads up">
  <:icon><.icon name="hero-information-circle" class="size-5" /></:icon>
  A new workspace theme is available in settings.
</.alert>
<.alert variant="success" title="Saved">
  <:icon><.icon name="hero-check-circle" class="size-5" /></:icon>
  Your changes are live.
</.alert>
<.alert variant="warning" title="Approaching limit">
  <:icon><.icon name="hero-exclamation-triangle" class="size-5" /></:icon>
  You've used 80% of your monthly build minutes.
</.alert>
<.alert variant="danger" title="Payment failed">
  <:icon><.icon name="hero-exclamation-circle" class="size-5" /></:icon>
  We couldn't charge your card. Update your billing details.
</.alert>
<.alert variant="neutral" title="Note">
  <:icon><.icon name="hero-bell" class="size-5" /></:icon>
  Scheduled maintenance runs Sunday at 02:00 UTC.
</.alert>|,
    dismissible: ~S|<.alert
  id="lab-alert-quota"
  variant="danger"
  title="Quota reached"
  on_dismiss={JS.hide(to: "#lab-alert-quota")}
>
  You have hit your plan's quota. Upgrade to keep deploying.
</.alert>|,
    inline_status: ~S|<.inline_status severity="success" label="Operational" />
<.inline_status severity="warning" pulse>Degraded</.inline_status>
<.inline_status severity="danger" label="Outage" />
<.inline_status severity="info" label="Deploying" pulse />
<.inline_status severity="neutral" label="Paused" />|,
    connection_state: ~S|<.connection_state id="lab-conn" hide_when_connected={false} />|,
    toasts: ~S|<.toast_group id="lab-toasts">
  <.toast id="lab-toast-1" severity="success" title="Copied" timeout={0}>
    Invite link copied to your clipboard.
  </.toast>
  <.toast id="lab-toast-2" severity="info" title="Item archived" timeout={0}>
    <:action><.button size="sm" variant="ghost">Undo</.button></:action>
    You can restore it from the archive.
  </.toast>
  <.toast id="lab-toast-3" severity="danger" title="Upload failed" timeout={0}>
    <:action><.button size="sm">Retry</.button></:action>
    We couldn't reach the server. This toast is persistent (timeout=0).
  </.toast>
</.toast_group>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Alert variants"
        description="Static, inline messages. info/success/warning/neutral are polite (role=status); danger is assertive (role=alert)."
        code={@code.alerts}
      >
        <div style="display:flex;flex-direction:column;gap:var(--aui-space-3);width:100%;">
          <.alert variant="info" title="Heads up">
            <:icon><.icon name="hero-information-circle" class="size-5" /></:icon>
            A new workspace theme is available in settings.
          </.alert>
          <.alert variant="success" title="Saved">
            <:icon><.icon name="hero-check-circle" class="size-5" /></:icon>
            Your changes are live.
          </.alert>
          <.alert variant="warning" title="Approaching limit">
            <:icon><.icon name="hero-exclamation-triangle" class="size-5" /></:icon>
            You've used 80% of your monthly build minutes.
          </.alert>
          <.alert variant="danger" title="Payment failed">
            <:icon><.icon name="hero-exclamation-circle" class="size-5" /></:icon>
            We couldn't charge your card. Update your billing details.
          </.alert>
          <.alert variant="neutral" title="Note">
            <:icon><.icon name="hero-bell" class="size-5" /></:icon>
            Scheduled maintenance runs Sunday at 02:00 UTC.
          </.alert>
        </div>
      </.story>

      <.story
        title="Dismissible alert"
        description="Passing on_dismiss renders a labelled dismiss button. Here it hides the alert client-side with JS.hide."
        code={@code.dismissible}
      >
        <.alert
          id="lab-alert-quota"
          variant="danger"
          title="Quota reached"
          on_dismiss={JS.hide(to: "#lab-alert-quota")}
        >
          You have hit your plan's quota. Upgrade to keep deploying.
        </.alert>
      </.story>

      <.story
        title="Inline status"
        description="A compact dot + label. No live region — it changes silently. The label always carries the meaning, so it reads without color."
        code={@code.inline_status}
      >
        <.inline_status severity="success" label="Operational" />
        <.inline_status severity="warning" pulse>Degraded</.inline_status>
        <.inline_status severity="danger" label="Outage" />
        <.inline_status severity="info" label="Deploying" pulse />
        <.inline_status severity="neutral" label="Paused" />
      </.story>

      <.story
        title="Connection state"
        description="A single polite region wired to the LiveView socket via the AuroraConnectionState hook. Shown here with hide_when_connected disabled so the healthy label is visible."
        code={@code.connection_state}
      >
        <.connection_state id="lab-conn" hide_when_connected={false} />
      </.story>

      <.story
        title="Toast group"
        description="The one streaming live region on the page. These are rendered statically with timeout={0} (persistent); a real app streams them in and the hook owns timers, pause-on-hover, and de-duplication."
        code={@code.toasts}
      >
        <%!-- The region is position:fixed in production; the transformed wrapper becomes its
             containing block so it pins into the preview box rather than the viewport. --%>
        <div style="position:relative;transform:translateZ(0);min-height:14rem;width:100%;">
          <.toast_group id="lab-toasts">
            <.toast id="lab-toast-1" severity="success" title="Copied" timeout={0}>
              Invite link copied to your clipboard.
            </.toast>
            <.toast id="lab-toast-2" severity="info" title="Item archived" timeout={0}>
              <:action><.button size="sm" variant="ghost">Undo</.button></:action>
              You can restore it from the archive.
            </.toast>
            <.toast id="lab-toast-3" severity="danger" title="Upload failed" timeout={0}>
              <:action><.button size="sm">Retry</.button></:action>
              We couldn't reach the server. This toast is persistent (timeout=0).
            </.toast>
          </.toast_group>
        </div>
      </.story>
    </div>
    """
  end
end
