defmodule AuroraUI.Components.Progress do
  @moduledoc """
  Progress family — `spinner`, `progress`, `skeleton`, and an `async_state`
  wrapper for LiveView async assigns and streams.

  Together these cover the "we are working / waiting on data" surface:

  * **`spinner/1`** — an indeterminate busy indicator for short, unmeasurable
    waits (a submit in flight). It always carries a visually-hidden `label` and
    lives in a `role="status"` region so assistive tech announces it. Under
    `prefers-reduced-motion` it slows down rather than stopping, so it never
    reads as frozen.
  * **`progress/1`** — a labelled progress bar. Determinate mode is a real
    `role="progressbar"` with `aria-valuenow/min/max` (and an optional visible
    percentage); the indeterminate variant drops `aria-valuenow` and shows a
    sweeping fill.
  * **`skeleton/1`** — a layout-reserving placeholder. You pass explicit
    `width`/`height`/`shape` so the box occupies the same space the real content
    will, avoiding cumulative layout shift. It is `aria-hidden` and its shimmer
    is disabled under reduced motion.
  * **`async_state/1`** — a single wrapper that renders one of its
    `loading`/`empty`/`error`/`inner_block` slots based on a `state` atom. It is
    designed to sit directly over a LiveView `assign_async`/stream result.

  ## `async_state/1` with LiveView async + streams

  Map the `AsyncResult` (and stream emptiness) to a single `state` atom, then let
  the wrapper pick the branch:

      # mount / handle_params
      socket
      |> assign(:page, AsyncResult.loading())
      |> start_async(:load, fn -> Catalog.list() end)

      def handle_async(:load, {:ok, rows}, socket) do
        {:noreply,
         socket
         |> assign(:page, AsyncResult.ok(socket.assigns.page, :loaded))
         |> stream(:rows, rows)}
      end

      # template — one branch renders at a time; the :ok branch streams
      <.async_state state={async_state(@page, @streams.rows)}>
        <:loading><.skeleton :for={_ <- 1..5} height="2.5rem" /></:loading>
        <:empty><.empty_state title="No results" /></:empty>
        <:error>Could not load. <.button phx-click="retry">Retry</.button></:error>
        <div id="rows" phx-update="stream">
          <div :for={{id, row} <- @streams.rows} id={id}>{row.name}</div>
        </div>
      </.async_state>

      # a tiny mapper in your LiveView keeps the template declarative
      defp async_state(%AsyncResult{loading: l}, _) when not is_nil(l), do: :loading
      defp async_state(%AsyncResult{failed: f}, _) when not is_nil(f), do: :error
      defp async_state(%AsyncResult{ok?: true}, []), do: :empty
      defp async_state(%AsyncResult{ok?: true}, _), do: :ok
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @sizes ~w(sm md lg)

  attr :label, :string,
    default: "Loading…",
    doc: "visually-hidden accessible name announced while busy"

  attr :size, :string, default: "md", values: @sizes
  attr :rest, :global

  @doc """
  An accessible indeterminate busy indicator.

  ## When not to use

  If the wait is measurable, prefer `progress/1` with a `value` so the user sees
  how far along they are.

  ## Examples

      <.spinner label="Saving changes" />
      <.spinner size="lg" label="Loading dashboard" />
  """
  def spinner(assigns) do
    ~H"""
    <span class={"aui-spinner aui-spinner--#{@size}"} role="status" data-aui {@rest}>
      <span class="aui-spinner__track" aria-hidden="true"></span>
      <span class="aui-sr-only">{@label}</span>
    </span>
    """
  end

  attr :value, :integer,
    default: nil,
    doc: "current progress; when nil the bar is indeterminate"

  attr :max, :integer, default: 100
  attr :min, :integer, default: 0
  attr :label, :string, default: nil, doc: "concise visible label describing the task"

  attr :show_value, :boolean,
    default: false,
    doc: "renders the percentage next to the label"

  attr :indeterminate, :boolean,
    default: false,
    doc: "force the indeterminate variant even if a value is present"

  attr :size, :string, default: "md", values: @sizes
  attr :rest, :global

  @doc """
  A progress bar. Determinate by default (pass `value`); becomes indeterminate
  when `value` is nil or `indeterminate` is set.

  Determinate bars are a real `role="progressbar"` exposing
  `aria-valuenow`/`aria-valuemin`/`aria-valuemax`; the indeterminate variant
  omits `aria-valuenow` so AT announces "busy" rather than a false number.

  ## Examples

      <.progress value={64} label="Uploading" show_value />
      <.progress indeterminate label="Processing" />
  """
  def progress(assigns) do
    indeterminate? = assigns.indeterminate or is_nil(assigns.value)

    percent =
      if indeterminate?,
        do: nil,
        else: progress_percent(assigns.value, assigns.min, assigns.max)

    assigns =
      assigns
      |> assign(:indeterminate?, indeterminate?)
      |> assign(:percent, percent)
      |> assign_new(:label_id, fn -> id(nil, "progress-label") end)

    ~H"""
    <div class={"aui-progress aui-progress--#{@size}"} data-aui {@rest}>
      <div :if={@label} class="aui-progress__meta" id={@label_id}>
        <span class="aui-progress__label">{@label}</span>
        <span :if={@show_value and not @indeterminate?} class="aui-progress__value">{@percent}%</span>
      </div>
      <div
        class={cx(["aui-progress__track", {"aui-progress__track--indeterminate", @indeterminate?}])}
        role="progressbar"
        aria-valuemin={@min}
        aria-valuemax={@max}
        aria-valuenow={not @indeterminate? && @value}
        aria-valuetext={not @indeterminate? && @show_value && "#{@percent}%"}
        aria-labelledby={@label && @label_id}
        aria-label={is_nil(@label) && "Progress"}
      >
        <div class="aui-progress__fill" style={not @indeterminate? && "inline-size: #{@percent}%"}>
        </div>
      </div>
    </div>
    """
  end

  attr :width, :string, default: "100%", doc: "explicit width (any CSS length) to reserve layout"
  attr :height, :string, default: "1rem", doc: "explicit height to reserve layout"

  attr :shape, :string,
    default: "rect",
    values: ~w(rect text circle pill),
    doc: "`text` uses a line height + rounded ends; `circle` forces a 1:1 avatar"

  attr :rest, :global

  @doc """
  A layout-reserving placeholder. Always give it the size the real content will
  occupy so it prevents cumulative layout shift. It is decorative
  (`aria-hidden`); announce the overall busy state at a higher level (a
  `role="status"` region, `spinner`, or `async_state`).

  ## Examples

      <.skeleton width="12rem" height="1.25rem" shape="text" />
      <.skeleton width="3rem" height="3rem" shape="circle" />
  """
  def skeleton(assigns) do
    ~H"""
    <span
      class={"aui-skeleton aui-skeleton--#{@shape}"}
      style={skeleton_style(@shape, @width, @height)}
      aria-hidden="true"
      data-aui
      {@rest}
    ></span>
    """
  end

  attr :state, :atom,
    default: :ok,
    values: [:loading, :empty, :error, :ok],
    doc: "which branch to render"

  attr :rest, :global

  slot :loading, doc: "shown while `state` is :loading (defaults to a spinner)"
  slot :empty, doc: "shown while `state` is :empty"
  slot :error, doc: "shown while `state` is :error (rendered in a role=alert region)"
  slot :inner_block, required: true, doc: "the loaded content, shown while `state` is :ok"

  @doc """
  Renders exactly one of its slots based on `state` — the declarative counterpart
  to a `case` over a LiveView async/stream result. See the moduledoc for the
  `assign_async` + streams wiring.

  ## Examples

      <.async_state state={@state}>
        <:loading><.spinner label="Loading orders" /></:loading>
        <:empty>No orders yet.</:empty>
        <:error>Something went wrong.</:error>
        <.orders_table rows={@orders} />
      </.async_state>
  """
  def async_state(assigns) do
    ~H"""
    <div class="aui-async" data-aui-state={@state} data-aui {@rest}>
      <div :if={@state == :loading} class="aui-async__loading" role="status" aria-live="polite">
        <span :if={@loading != []}>{render_slot(@loading)}</span>
        <.spinner :if={@loading == []} label="Loading…" />
      </div>

      <div :if={@state == :empty} class="aui-async__empty" role="status">
        {render_slot(@empty)}
      </div>

      <div :if={@state == :error} class="aui-async__error" role="alert">
        {render_slot(@error)}
      </div>

      <div :if={@state == :ok} class="aui-async__ok">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  ## Helpers

  defp progress_percent(_value, min, max) when min >= max, do: 0

  defp progress_percent(value, min, max) do
    clamped = value |> max(min) |> min(max)
    round((clamped - min) / (max - min) * 100)
  end

  defp skeleton_style("circle", _width, height),
    do: "inline-size: #{height}; block-size: #{height};"

  defp skeleton_style(_shape, width, height),
    do: "inline-size: #{width}; block-size: #{height};"
end
