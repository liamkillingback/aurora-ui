defmodule AuroraUI.Components.Overlay do
  @moduledoc """
  Overlay family — modal `dialog/1`, `alert_dialog/1`, and `drawer/1`.

  Overlays are the kit's highest-risk components for accessibility, so they are
  built on the platform first: every overlay is a native `<dialog>` element and
  the JavaScript hook only *enhances* it (open/close, focus trap, focus return,
  scroll lock, background `inert`, and Escape handling). Getting focus wrong
  strands keyboard and screen-reader users, so the rules below are not optional.

  ## Focus management (owned by the hooks)

  * **Open** — the hook calls `showModal()` (modal) or `show()` (non-modal) and
    moves focus to the element marked `autofocus`, else the first tabbable
    control, else the dialog box.
  * **Trap** — modal overlays (`dialog`, `alert_dialog`, and a modal `drawer`)
    keep Tab/Shift+Tab inside the box and mark the rest of the page `inert`.
  * **Return** — on close focus returns to the element that was focused before
    the overlay opened (the trigger).
  * **Escape** — closes a dialog / cancels an `alert_dialog` / closes a drawer.
    `alert_dialog` is never dismissed by clicking the backdrop; Escape still
    routes through the *cancel* action so the app can react.

  ## Scrolling

  Long or zoomed content scrolls **inside** the overlay body. The title, close
  control, and footer actions stay pinned so they can never be pushed offscreen.

  ## DOM contract

  Roots carry `data-aui` (for the shared focus ring, reduced-motion, and
  forced-colors base rules), a stable `id` (hook target), and:

  | Component | `phx-hook` | data attributes |
  |---|---|---|
  | `dialog` / `alert_dialog` | `AuroraDialog` | `data-aui-dialog`, `data-aui-open`, `[data-aui-dialog-close]` |
  | `drawer` | `AuroraDrawer` | `data-aui-drawer`, `data-aui-side`, `data-aui-modal`, `[data-aui-drawer-close]` |
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @sides ~w(start end top bottom)

  attr :id, :string, default: nil, doc: "stable id; auto-generated when omitted"

  attr :open, :boolean,
    default: false,
    doc: "controlled open state; reflected as data-aui-open for the hook"

  attr :on_close, :any,
    default: nil,
    doc: "a Phoenix.LiveView.JS command or event name run when the dialog requests close"

  attr :dismissable, :boolean,
    default: true,
    doc: "when true, clicking the backdrop closes the dialog"

  attr :size, :string, default: "md", values: ~w(sm md lg xl), doc: "max-width of the box"
  attr :rest, :global

  slot :title, required: true, doc: "accessible name; wired via aria-labelledby"
  slot :description, doc: "supporting copy; wired via aria-describedby"
  slot :inner_block, required: true, doc: "dialog body (scrolls when tall)"
  slot :footer, doc: "pinned action row"

  @doc """
  A modal dialog built on the native `<dialog>` element.

  Focus is trapped while open, the background is made `inert`, body scroll is
  locked, and focus returns to the trigger on close. Provide `on_close` so the
  server can clear the controlling assign when the user dismisses via Escape,
  the backdrop, or the close control.

  ## When not to use

  For a destructive confirmation reach for `alert_dialog/1` (it forces an
  explicit choice and is not click-away dismissable). For non-modal contextual
  content use `AuroraUI.Components.Floating.popover/1`.

  ## Examples

      <.dialog id="invite" open={@show_invite} on_close={JS.push("close_invite")}>
        <:title>Invite teammates</:title>
        <:description>They'll get an email with a join link.</:description>
        <.field ... />
        <:footer>
          <.button variant="ghost" data-aui-dialog-close>Cancel</.button>
          <.button phx-click="send_invite">Send invites</.button>
        </:footer>
      </.dialog>
  """
  def dialog(assigns) do
    assigns = with_dialog_ids(assigns)

    ~H"""
    <dialog
      id={@id}
      class={["aui-dialog", "aui-dialog--#{@size}"]}
      phx-hook="AuroraDialog"
      data-aui
      data-aui-dialog
      data-aui-open={@open && "true"}
      data-aui-dismissable={(@dismissable && "true") || "false"}
      aria-modal="true"
      aria-labelledby={@title_id}
      aria-describedby={@description != [] && @desc_id}
      {@rest}
    >
      <div class="aui-dialog__box">
        <div class="aui-dialog__header">
          <h2 id={@title_id} class="aui-dialog__title">{render_slot(@title)}</h2>
          <button
            type="button"
            class="aui-btn aui-btn--icon aui-btn--ghost aui-btn--sm aui-focusable aui-dialog__close"
            aria-label="Close"
            data-aui-dialog-close
            phx-click={@on_close}
          >
            <.close_icon />
          </button>
        </div>
        <p :if={@description != []} id={@desc_id} class="aui-dialog__description">
          {render_slot(@description)}
        </p>
        <div class="aui-dialog__body">{render_slot(@inner_block)}</div>
        <div :if={@footer != []} class="aui-dialog__footer">{render_slot(@footer)}</div>
      </div>
    </dialog>
    """
  end

  attr :id, :string, default: nil
  attr :open, :boolean, default: false
  attr :size, :string, default: "sm", values: ~w(sm md lg xl)

  attr :on_confirm, :any, required: true, doc: "JS command or event for the confirming action"

  attr :on_cancel, :any,
    default: nil,
    doc: "JS command or event for the cancelling action; also runs on Escape"

  attr :confirm_label, :string, default: "Confirm"
  attr :cancel_label, :string, default: "Cancel"

  attr :confirm_variant, :string,
    default: "danger",
    values: ~w(primary danger),
    doc: "visual weight of the confirm button; the destructive default is `danger`"

  attr :rest, :global

  slot :title, required: true
  slot :description, required: true, doc: "explain the consequence; wired via aria-describedby"
  slot :inner_block, doc: "optional extra body content"

  @doc """
  A confirmation dialog with `role="alertdialog"`.

  Unlike `dialog/1` it requires an explicit **confirm** and **cancel** action,
  puts initial focus on the *least destructive* action (Cancel), and is **not**
  dismissable by clicking the backdrop. Escape still routes through `on_cancel`
  so nothing is silently discarded.

  ## Examples

      <.alert_dialog
        id="del"
        open={@confirming}
        on_confirm={JS.push("delete")}
        on_cancel={JS.push("cancel_delete")}
        confirm_label="Delete project"
      >
        <:title>Delete this project?</:title>
        <:description>This permanently removes 3 sites and cannot be undone.</:description>
      </.alert_dialog>
  """
  def alert_dialog(assigns) do
    assigns = with_dialog_ids(assigns)

    ~H"""
    <dialog
      id={@id}
      class={["aui-dialog", "aui-dialog--alert", "aui-dialog--#{@size}"]}
      phx-hook="AuroraDialog"
      role="alertdialog"
      data-aui
      data-aui-dialog
      data-aui-open={@open && "true"}
      data-aui-dismissable="false"
      aria-modal="true"
      aria-labelledby={@title_id}
      aria-describedby={@desc_id}
      {@rest}
    >
      <div class="aui-dialog__box">
        <div class="aui-dialog__header">
          <h2 id={@title_id} class="aui-dialog__title">{render_slot(@title)}</h2>
        </div>
        <div class="aui-dialog__body">
          <p id={@desc_id} class="aui-dialog__description">{render_slot(@description)}</p>
          {render_slot(@inner_block)}
        </div>
        <div class="aui-dialog__footer">
          <%!-- Least-destructive action first + autofocus: initial focus lands here. --%>
          <button
            type="button"
            class="aui-btn aui-btn--ghost aui-btn--md aui-focusable"
            autofocus
            data-aui-dialog-close
            phx-click={@on_cancel}
          >
            {@cancel_label}
          </button>
          <button
            type="button"
            class={["aui-btn aui-btn--md aui-focusable", "aui-btn--#{@confirm_variant}"]}
            data-aui-dialog-confirm
            phx-click={@on_confirm}
          >
            {@confirm_label}
          </button>
        </div>
      </div>
    </dialog>
    """
  end

  attr :id, :string, default: nil
  attr :open, :boolean, default: false

  attr :side, :string,
    default: "end",
    values: @sides,
    doc: "logical edge the sheet slides from (start/end honor writing direction)"

  attr :modal, :boolean,
    default: true,
    doc: "modal drawers trap focus and inert the page; non-modal drawers do neither"

  attr :on_close, :any, default: nil
  attr :dismissable, :boolean, default: true
  attr :rest, :global

  slot :title, required: true
  slot :description
  slot :inner_block, required: true
  slot :footer

  @doc """
  A sheet that slides in from a `side` (`start`/`end`/`top`/`bottom`).

  ## Modal vs non-modal

  * `modal={true}` (default) — behaves like `dialog/1`: focus is **trapped**
    inside the sheet, the rest of the page is `inert`, a backdrop is shown, and
    Escape/backdrop close it. Use for tasks that must be completed or abandoned.
  * `modal={false}` — the sheet opens with `show()` (not `showModal()`), so
    focus is **not** trapped and the background stays fully interactive with no
    backdrop. Use for inspectors/filters the user works alongside the page.

  The exit transition is played by the hook *before* the element is removed, so
  it never races LiveView DOM patching.

  ## Examples

      <.drawer id="filters" side="end" modal={false} open={@show_filters}>
        <:title>Filters</:title>
        ...filter controls...
      </.drawer>
  """
  def drawer(assigns) do
    assigns = with_dialog_ids(assigns)

    ~H"""
    <dialog
      id={@id}
      class={["aui-drawer", "aui-drawer--#{@side}"]}
      phx-hook="AuroraDrawer"
      role="dialog"
      data-aui
      data-aui-drawer
      data-aui-side={@side}
      data-aui-modal={(@modal && "true") || "false"}
      data-aui-open={@open && "true"}
      data-aui-dismissable={(@dismissable && "true") || "false"}
      aria-modal={(@modal && "true") || "false"}
      aria-labelledby={@title_id}
      aria-describedby={@description != [] && @desc_id}
      {@rest}
    >
      <div class="aui-drawer__box">
        <div class="aui-dialog__header">
          <h2 id={@title_id} class="aui-dialog__title">{render_slot(@title)}</h2>
          <button
            type="button"
            class="aui-btn aui-btn--icon aui-btn--ghost aui-btn--sm aui-focusable aui-dialog__close"
            aria-label="Close"
            data-aui-drawer-close
            phx-click={@on_close}
          >
            <.close_icon />
          </button>
        </div>
        <p :if={@description != []} id={@desc_id} class="aui-dialog__description">
          {render_slot(@description)}
        </p>
        <div class="aui-dialog__body">{render_slot(@inner_block)}</div>
        <div :if={@footer != []} class="aui-dialog__footer">{render_slot(@footer)}</div>
      </div>
    </dialog>
    """
  end

  # ── internal ─────────────────────────────────────────────────────────────

  defp close_icon(assigns) do
    ~H"""
    <svg class="aui-dialog__close-icon" viewBox="0 0 20 20" aria-hidden="true" focusable="false">
      <path
        d="M5 5l10 10M15 5L5 15"
        fill="none"
        stroke="currentColor"
        stroke-width="1.75"
        stroke-linecap="round"
      />
    </svg>
    """
  end

  defp with_dialog_ids(assigns) do
    base = assigns[:id] || id(nil, "dialog")

    assigns
    |> assign(:id, base)
    |> assign(:title_id, id(base, "title"))
    |> assign(:desc_id, id(base, "desc"))
  end
end
