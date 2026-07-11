defmodule AuroraUI.Components.Feedback do
  @moduledoc """
  Feedback family — alert, toast (with region), inline status, connection state.

  These components tell the user what just happened, what is happening, and
  whether the app can still reach the server. Getting them right is mostly an
  exercise in *restraint*: the wrong live-region strategy turns a helpful app
  into a screen-reader that will not stop talking.

  ## Live-region strategy (read before adding announcements)

  There are three distinct "loudness" levels here and each maps to a specific
  ARIA construct:

  * `alert/1` is **static**. It is server-rendered once, in place, as part of the
    page. `info`/`success`/`warning`/`neutral` carry `role="status"` (a polite
    live region); `danger` — or any alert with `assertive` — carries
    `role="alert"` (assertive). Because the node is present at render time it is
    announced once and never re-announced. It is *not* a live-region that we push
    updates into, so it cannot spam. Use it for validation summaries, empty
    states, and inline warnings.

  * `toast_group/1` is the **one** streaming live region on the page. It owns a
    single `aria-live` politeness setting (polite by default, `assertive` only
    when a group is dedicated to errors). Individual `toast/1` items are appended
    into it as list items; the region — not each toast — is what AT observes, so
    N toasts appearing in one patch are announced as they land rather than as N
    competing regions. To avoid spam the `AuroraToast` hook is responsible for:
    pause-on-hover / pause-on-focus (timers freeze while the pointer or keyboard
    focus is inside the region), de-duplication (a toast whose
    `data-aui-dedup-key` matches a visible one refreshes that toast instead of
    stacking a copy), and honoring `prefers-reduced-motion`. Toasts are
    *ephemeral*: never put an error the user must act on **only** in a toast. A
    critical, persistent error belongs in an `alert/1` (or a toast with
    `timeout={0}`, which the hook leaves on screen until dismissed).

  * `inline_status/1` and `connection_state/1` are **ambient**. `inline_status/1`
    is a plain labelled indicator (dot + text) with no live region — poll/refresh
    changes it silently. `connection_state/1` is a single polite region that the
    `AuroraConnectionState` hook drives from the LiveView socket, reflecting
    `connected` / `connecting` / `disconnected` onto `data-aui-conn`. It is
    deliberately calm: it shows a "reconnecting…" affordance, never steals focus,
    and never discards the user's in-progress work — it only reports reachability.

  ## Semantics

  All dismiss controls are real `<button>`s with an accessible name and the
  shared `.aui-focusable` ring; decorative icons are `aria-hidden`. Nothing here
  relies on color alone — severity is always carried by text and/or an icon in
  addition to the token color.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @alert_variants ~w(info success warning danger neutral)
  @severities ~w(info success warning danger neutral)

  attr :variant, :string,
    default: "info",
    values: @alert_variants,
    doc: "Severity of the message. Drives icon color and default ARIA role."

  attr :title, :string, default: nil, doc: "Optional short heading rendered above the body."

  attr :assertive, :boolean,
    default: false,
    doc: "Force role=alert (assertive live region). `danger` is assertive automatically."

  attr :on_dismiss, :any,
    default: nil,
    doc: "phx-click event name or JS command; when set, a dismiss button is shown."

  attr :dismiss_label, :string, default: "Dismiss"
  attr :rest, :global

  slot :icon, doc: "leading status icon; decorative (aria-hidden)."
  slot :inner_block, required: true, doc: "the message body."

  @doc """
  A static, inline alert. Rendered once as part of the page — not a channel we
  push updates into, so it announces itself a single time and cannot spam.

  `info`/`success`/`warning`/`neutral` use `role="status"` (polite); `danger`
  (or any alert with `assertive`) uses `role="alert"` (assertive).

  ## When not to use

  For transient confirmations that should auto-dismiss, reach for `toast/1`. For
  a per-field validation message, use the field/form components instead.

  ## Examples

      <.alert variant="success" title="Saved">Your changes are live.</.alert>

      <.alert variant="danger" on_dismiss={JS.hide(to: "#quota")} id="quota">
        You have hit your plan's quota.
      </.alert>
  """
  def alert(assigns) do
    assertive? = assigns.assertive or assigns.variant == "danger"

    assigns =
      assigns
      |> assign(:assertive?, assertive?)
      |> assign(:role, if(assertive?, do: "alert", else: "status"))
      |> assign(:class, [
        "aui-alert",
        "aui-alert--#{variant(alert_variant_map(), assigns.variant, "info")}"
      ])

    ~H"""
    <div class={@class} role={@role} data-aui-variant={@variant} {@rest}>
      <span :if={@icon != []} class="aui-alert__icon" aria-hidden="true">{render_slot(@icon)}</span>
      <div class="aui-alert__content">
        <p :if={@title} class="aui-alert__title">{@title}</p>
        <div class="aui-alert__body">{render_slot(@inner_block)}</div>
      </div>
      <button
        :if={@on_dismiss}
        type="button"
        class="aui-alert__dismiss aui-focusable"
        phx-click={@on_dismiss}
        aria-label={@dismiss_label}
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: "Stable id for the region and its hook target."
  attr :label, :string, default: "Notifications", doc: "accessible name for the region."

  attr :assertive, :boolean,
    default: false,
    doc: "Use an assertive live region. Reserve for a group dedicated to errors."

  attr :rest, :global, include: ~w(phx-update)
  slot :inner_block, required: true, doc: "the streamed toast/1 items."

  @doc """
  The single streaming live region that hosts `toast/1` items. Renders the
  `data-aui-toast-region` container wired to the `AuroraToast` hook, which owns
  the timers, pause-on-hover/focus, and de-duplication.

  Put exactly one polite `toast_group/1` in your layout. Only add a second,
  `assertive` group if you have errors that must interrupt — and prefer a
  persistent `alert/1` for anything the user must act on.

  ## Examples

      <.toast_group id="toasts">
        <.toast :for={{id, t} <- @streams.toasts} id={id} severity={t.severity} title={t.title}>
          {t.body}
        </.toast>
      </.toast_group>
  """
  def toast_group(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> id(nil, "toast-region") end)
      |> assign(:live, if(assigns.assertive, do: "assertive", else: "polite"))

    ~H"""
    <div
      id={@id}
      class="aui-toast-region"
      data-aui-toast-region
      phx-hook="AuroraToast"
      role="region"
      aria-label={@label}
    >
      <ul
        id={@id <> "-list"}
        class="aui-toast-region__list"
        aria-live={@live}
        aria-relevant="additions text"
        aria-atomic="false"
        {@rest}
      >
        {render_slot(@inner_block)}
      </ul>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :severity, :string, default: "info", values: @severities

  attr :title, :string, default: nil

  attr :timeout, :integer,
    default: 6000,
    doc: "Auto-dismiss delay in ms. `0` keeps the toast until dismissed (persistent)."

  attr :dedup_key, :string,
    default: nil,
    doc: "Toasts sharing a key refresh the visible one instead of stacking a duplicate."

  attr :on_dismiss, :any, default: nil, doc: "phx-click event/JS run when the toast is dismissed."
  attr :dismiss_label, :string, default: "Dismiss"
  attr :rest, :global

  slot :icon, doc: "leading severity icon; decorative."
  slot :action, doc: "one optional action control (e.g. Undo)."
  slot :inner_block, required: true, doc: "the toast body."

  @doc """
  One toast: a single list item inside a `toast_group/1`. Severity, optional
  title, body, an optional action, and a dismiss button. `data-aui-timeout`
  hands the auto-dismiss delay to the `AuroraToast` hook; `timeout={0}` omits it
  so the toast persists — the right choice for a critical error you cannot lose.

  ## Examples

      <.toast id="t1" severity="success" title="Copied">Link copied to clipboard.</.toast>

      <.toast id="t2" severity="danger" title="Upload failed" timeout={0}>
        <:action><.button size="sm" phx-click="retry">Retry</.button></:action>
        We could not reach the server.
      </.toast>
  """
  def toast(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> id(nil, "toast") end)
      |> assign(:class, [
        "aui-toast",
        "aui-toast--#{variant(severity_map(), assigns.severity, "info")}"
      ])

    ~H"""
    <li
      id={@id}
      class={@class}
      data-aui-severity={@severity}
      data-aui-timeout={@timeout > 0 && @timeout}
      data-aui-dedup-key={@dedup_key}
      {@rest}
    >
      <span :if={@icon != []} class="aui-toast__icon" aria-hidden="true">{render_slot(@icon)}</span>
      <div class="aui-toast__content">
        <p :if={@title} class="aui-toast__title">{@title}</p>
        <div class="aui-toast__body">{render_slot(@inner_block)}</div>
        <div :if={@action != []} class="aui-toast__actions">{render_slot(@action)}</div>
      </div>
      <button
        type="button"
        class="aui-toast__dismiss aui-focusable"
        data-aui-toast-close
        phx-click={@on_dismiss}
        aria-label={@dismiss_label}
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </li>
    """
  end

  attr :severity, :string,
    default: "neutral",
    values: @severities,
    doc: "Maps to the dot color; the label still carries the meaning in text."

  attr :label, :string, default: nil, doc: "status text; alternatively pass an inner block."

  attr :pulse, :boolean,
    default: false,
    doc: "Animate the dot to hint a live/degraded state (respects reduced-motion)."

  attr :rest, :global
  slot :inner_block, doc: "status text (overrides `label`)."

  @doc """
  A compact status indicator: a colored dot plus a text label, e.g.
  "Operational" or "Degraded". No live region — refresh it however you like; it
  changes silently. The dot is decorative and the label always carries the
  meaning, so it is legible without color.

  ## Examples

      <.inline_status severity="success" label="Operational" />
      <.inline_status severity="warning" pulse>Degraded</.inline_status>
  """
  def inline_status(assigns) do
    assigns =
      assign(
        assigns,
        :class,
        cx([
          "aui-status",
          "aui-status--#{variant(severity_map(), assigns.severity, "neutral")}",
          {"aui-status--pulse", assigns.pulse}
        ])
      )

    ~H"""
    <span class={@class} data-aui-severity={@severity} {@rest}>
      <span class="aui-status__dot" aria-hidden="true"></span>
      <span class="aui-status__label">{if @inner_block != [],
        do: render_slot(@inner_block),
        else: @label}</span>
    </span>
    """
  end

  attr :id, :string, default: nil, doc: "Stable id for the hook target."

  attr :connected_label, :string, default: "Connected"
  attr :connecting_label, :string, default: "Reconnecting…"
  attr :disconnected_label, :string, default: "Offline"

  attr :hide_when_connected, :boolean,
    default: true,
    doc: "Collapse the indicator while healthy; reveal only on trouble."

  attr :rest, :global

  @doc """
  A LiveView connection indicator wired to the `AuroraConnectionState` hook. The
  hook reflects the socket state onto `data-aui-conn` (`connected` /
  `connecting` / `disconnected`) and cooperates with Phoenix's own
  `.phx-loading` / `.phx-error` body classes; CSS then reveals the matching
  label.

  It is intentionally calm: a single polite live region (so a reconnect is
  announced once, not spammed), a visible "reconnecting…" affordance, and no
  focus-stealing. It reports reachability only — it never discards in-progress
  work.

  ## Examples

      <.connection_state id="conn" />
  """
  def connection_state(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> id(nil, "conn") end)
      |> assign(
        :class,
        cx([
          "aui-conn",
          {"aui-conn--auto-hide", assigns.hide_when_connected}
        ])
      )

    ~H"""
    <div
      id={@id}
      class={@class}
      phx-hook="AuroraConnectionState"
      data-aui-conn="connected"
      role="status"
      aria-live="polite"
      {@rest}
    >
      <span class="aui-conn__dot" aria-hidden="true"></span>
      <span class="aui-conn__label aui-conn__label--connected">{@connected_label}</span>
      <span class="aui-conn__label aui-conn__label--connecting">
        <span class="aui-conn__spinner" aria-hidden="true"></span>{@connecting_label}
      </span>
      <span class="aui-conn__label aui-conn__label--disconnected">{@disconnected_label}</span>
    </div>
    """
  end

  defp alert_variant_map, do: Map.new(@alert_variants, &{&1, &1})
  defp severity_map, do: Map.new(@severities, &{&1, &1})
end
