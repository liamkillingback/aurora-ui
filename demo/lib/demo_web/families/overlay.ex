defmodule DemoWeb.Families.Overlay do
  @moduledoc """
  Component-lab stories for the Overlay family — `dialog/1`, `alert_dialog/1`,
  and `drawer/1` (modal + non-modal).

  Follows the `DemoWeb.Families.Actions` exemplar: `lab/1` returns a
  `<div class="demo-stories">` of `<.story>` blocks, each with a live preview
  and copyable HEEx.

  ## How the previews open

  Every overlay is a native `<dialog>` enhanced by the `AuroraDialog` /
  `AuroraDrawer` hooks, whose documented DOM open contract is the `data-aui-open`
  attribute (see `AGENTS.md`). Each story renders a real trigger button that
  toggles that attribute with `Phoenix.LiveView.JS`, plus the overlay itself with
  a stable id. The overlays' built-in close controls (`[data-aui-dialog-close]`,
  the alert's cancel/confirm, the drawer close) are wired by the hooks. In a real
  app you would instead drive `open` from a server assign and pass
  `on_close={JS.push(...)}`, exactly as the moduledoc shows.
  """
  use DemoWeb, :html

  @code %{
    dialog:
      ~S|<.button phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-dialog")}>
  Invite teammates
</.button>

<.dialog id="lab-dialog" on_close={JS.remove_attribute("data-aui-open", to: "#lab-dialog")}>
  <:title>Invite teammates</:title>
  <:description>They'll get an email with a link to join your workspace.</:description>
  <p>Add up to five collaborators on the free plan.</p>
  <:footer>
    <.button variant="ghost" data-aui-dialog-close>Cancel</.button>
    <.button data-aui-dialog-close>Send invites</.button>
  </:footer>
</.dialog>|,
    alert_dialog: ~S|<.button
  variant="danger"
  phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-alert-dialog")}
>
  Delete project
</.button>

<.alert_dialog
  id="lab-alert-dialog"
  confirm_label="Delete project"
  on_confirm={JS.remove_attribute("data-aui-open", to: "#lab-alert-dialog")}
  on_cancel={JS.remove_attribute("data-aui-open", to: "#lab-alert-dialog")}
>
  <:title>Delete this project?</:title>
  <:description>This permanently removes 3 sites and cannot be undone.</:description>
</.alert_dialog>|,
    drawer:
      ~S|<.button phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-drawer")}>
  Open filters
</.button>

<.drawer id="lab-drawer" side="end" on_close={JS.remove_attribute("data-aui-open", to: "#lab-drawer")}>
  <:title>Filters</:title>
  <:description>Narrow the results shown in the table.</:description>
  <.field :let={f} id="lab-drawer-q" label="Search">
    <.input {f} name="q" placeholder="Search projects…" />
  </.field>
  <:footer>
    <.button variant="ghost" data-aui-drawer-close>Reset</.button>
    <.button data-aui-drawer-close>Apply</.button>
  </:footer>
</.drawer>|,
    drawer_nonmodal: ~S|<.button
  variant="secondary"
  phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-drawer-inspector")}
>
  Open inspector
</.button>

<.drawer
  id="lab-drawer-inspector"
  side="end"
  modal={false}
  on_close={JS.remove_attribute("data-aui-open", to: "#lab-drawer-inspector")}
>
  <:title>Inspector</:title>
  <:description>A non-modal sheet: focus is not trapped and the page stays interactive.</:description>
  <p>Edit the selected item while you keep working alongside it.</p>
</.drawer>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Dialog"
        description="A modal task built on the native <dialog>. Focus is trapped, the page is inert, and focus returns to the trigger on close."
        code={@code.dialog}
      >
        <.button phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-dialog")}>
          Invite teammates
        </.button>

        <.dialog id="lab-dialog" on_close={JS.remove_attribute("data-aui-open", to: "#lab-dialog")}>
          <:title>Invite teammates</:title>
          <:description>They'll get an email with a link to join your workspace.</:description>
          <p style="color:rgb(var(--aui-text));">Add up to five collaborators on the free plan.</p>
          <:footer>
            <.button variant="ghost" data-aui-dialog-close>Cancel</.button>
            <.button data-aui-dialog-close>Send invites</.button>
          </:footer>
        </.dialog>
      </.story>

      <.story
        title="Alert dialog"
        description="A destructive confirmation with role=alertdialog. Initial focus lands on Cancel and the backdrop never dismisses it."
        code={@code.alert_dialog}
      >
        <.button
          variant="danger"
          phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-alert-dialog")}
        >
          Delete project
        </.button>

        <.alert_dialog
          id="lab-alert-dialog"
          confirm_label="Delete project"
          on_confirm={JS.remove_attribute("data-aui-open", to: "#lab-alert-dialog")}
          on_cancel={JS.remove_attribute("data-aui-open", to: "#lab-alert-dialog")}
        >
          <:title>Delete this project?</:title>
          <:description>This permanently removes 3 sites and cannot be undone.</:description>
        </.alert_dialog>
      </.story>

      <.story
        title="Drawer — modal"
        description="A sheet that slides from an edge. Modal drawers trap focus and inert the page, like a dialog."
        code={@code.drawer}
      >
        <.button phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-drawer")}>
          Open filters
        </.button>

        <.drawer
          id="lab-drawer"
          side="end"
          on_close={JS.remove_attribute("data-aui-open", to: "#lab-drawer")}
        >
          <:title>Filters</:title>
          <:description>Narrow the results shown in the table.</:description>
          <.field :let={f} id="lab-drawer-q" label="Search">
            <.input {f} name="q" placeholder="Search projects…" />
          </.field>
          <:footer>
            <.button variant="ghost" data-aui-drawer-close>Reset</.button>
            <.button data-aui-drawer-close>Apply</.button>
          </:footer>
        </.drawer>
      </.story>

      <.story
        title="Drawer — non-modal"
        description="modal={false} opens with show() (not showModal): no backdrop, no focus trap, and the page stays fully interactive."
        code={@code.drawer_nonmodal}
      >
        <.button
          variant="secondary"
          phx-click={JS.set_attribute({"data-aui-open", "true"}, to: "#lab-drawer-inspector")}
        >
          Open inspector
        </.button>

        <.drawer
          id="lab-drawer-inspector"
          side="end"
          modal={false}
          on_close={JS.remove_attribute("data-aui-open", to: "#lab-drawer-inspector")}
        >
          <:title>Inspector</:title>
          <:description>
            A non-modal sheet: focus is not trapped and the page stays interactive.
          </:description>
          <p style="color:rgb(var(--aui-text));">
            Edit the selected item while you keep working alongside it.
          </p>
        </.drawer>
      </.story>
    </div>
    """
  end
end
