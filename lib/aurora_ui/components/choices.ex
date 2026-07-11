defmodule AuroraUI.Components.Choices do
  @moduledoc """
  Choices family — checkbox, radio group, switch, and segmented control.

  Every control in this family is a **real native form control** styled with
  `appearance: none`, so keyboard behavior, form participation, and assistive
  technology semantics come from the platform rather than from JavaScript. The
  visual box/thumb/segment is drawn with tokens and CSS sibling selectors keyed
  off the input's native `:checked`/`:disabled` state — no hook is required for
  any of these components.

  ## Accessibility

  - `checkbox/1` exposes `checked`, `disabled`, `invalid`, and a tri-state
    `indeterminate`. Because a checkbox's `indeterminate` is a DOM *property*
    (not an attribute) it cannot be set from server-rendered HTML; Aurora renders
    `aria-checked="mixed"` and a visual dash so the mixed state is announced and
    drawn immediately. Set the matching `input.indeterminate = true` property
    client-side when you also need the native pseudo-class.
  - `radio_group/1` renders a `fieldset`/`legend` with `role="radiogroup"`; the
    child `radio/1` controls share a `name`, so native roving arrow-key
    navigation and single-selection come for free.
  - `switch/1` is a checkbox with `role="switch"`; its checked state maps to
    on/off and is announced natively.
  - `segmented_control/1` is a `radiogroup` of exclusive radios styled as a
    single cluster; arrow keys move selection natively.

  All animated affordances (the check draw, the switch thumb) collapse to an
  instant state change under `prefers-reduced-motion: reduce`.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @sizes ~w(sm md lg)

  attr :id, :string, default: nil, doc: "stable id; generated when omitted"
  attr :name, :string, default: nil
  attr :value, :string, default: "true", doc: "submitted value when checked"
  attr :checked, :boolean, default: false
  attr :indeterminate, :boolean, default: false, doc: "renders aria-checked=mixed + a dash"
  attr :disabled, :boolean, default: false
  attr :invalid, :boolean, default: false, doc: "sets aria-invalid and error styling"

  attr :rest, :global,
    include: ~w(form required phx-change phx-click phx-value-id phx-blur phx-focus)

  slot :inner_block, doc: "the checkbox label"
  slot :description, doc: "optional helper text, wired as aria-describedby"

  @doc """
  A single native checkbox with a generous 44px hit area, label, and optional
  description.

  Use for an independent boolean. For one-of-many, reach for `radio_group/1`;
  for an instant-effect setting, `switch/1`.

  ## Examples

      <.checkbox name="terms" checked={@accepted}>I accept the terms</.checkbox>

      <.checkbox name="all" indeterminate={@some_selected}>
        Select all
        <:description>Toggles every row in the table</:description>
      </.checkbox>
  """
  def checkbox(assigns) do
    id = assigns.id || id(nil, "check")

    assigns =
      assign(assigns,
        id: id,
        desc_id: (assigns.description != [] && "#{id}-desc") || nil
      )

    ~H"""
    <label class={
      cx([
        "aui-check",
        {"aui-check--invalid", @invalid},
        {"aui-check--disabled", @disabled},
        {"aui-check--indeterminate", @indeterminate}
      ])
    }>
      <span class="aui-check__control">
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value={@value}
          class="aui-check__input aui-focusable"
          checked={@checked}
          disabled={@disabled}
          aria-checked={@indeterminate && "mixed"}
          aria-invalid={@invalid && "true"}
          aria-describedby={@desc_id}
          {@rest}
        />
        <svg class="aui-check__mark" viewBox="0 0 16 16" fill="none" aria-hidden="true">
          <path
            d="M3.5 8.5 6.5 11.5 12.5 5"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
        <span class="aui-check__dash" aria-hidden="true"></span>
      </span>
      <span :if={@inner_block != [] or @description != []} class="aui-check__text">
        <span :if={@inner_block != []} class="aui-check__title">{render_slot(@inner_block)}</span>
        <span :if={@description != []} id={@desc_id} class="aui-check__description">
          {render_slot(@description)}
        </span>
      </span>
    </label>
    """
  end

  attr :label, :string, default: nil, doc: "group name, rendered as the <legend>"
  attr :name, :string, default: nil, doc: "shared radio name; required when using `options`"
  attr :value, :string, default: nil, doc: "the selected option value"
  attr :description, :string, default: nil, doc: "helper text wired as aria-describedby"
  attr :disabled, :boolean, default: false, doc: "disables the whole group via the fieldset"
  attr :invalid, :boolean, default: false
  attr :id, :string, default: nil

  attr :options, :list,
    default: [],
    doc: "`{label, value}` tuples or maps with :label/:value/:description/:disabled"

  attr :rest, :global

  slot :inner_block, doc: "manual `<.radio>` children, used instead of `options`"

  @doc """
  A labelled group of mutually exclusive radios. Pass `options` for the common
  case, or render `<.radio>` children yourself for full control.

  ## Examples

      <.radio_group label="Plan" name="plan" value={@plan} options={[
        {"Free", "free"},
        %{label: "Pro", value: "pro", description: "Everything in Free, plus…"}
      ]} />
  """
  def radio_group(assigns) do
    id = assigns.id || id(nil, "radio-group")

    assigns =
      assign(assigns,
        id: id,
        desc_id: (assigns.description && "#{id}-desc") || nil,
        options: normalize_options(assigns.options)
      )

    ~H"""
    <fieldset
      class={cx(["aui-radio-group", {"aui-radio-group--invalid", @invalid}])}
      role="radiogroup"
      disabled={@disabled}
      aria-invalid={@invalid && "true"}
      aria-describedby={@desc_id}
      {@rest}
    >
      <legend :if={@label} class="aui-radio-group__legend">{@label}</legend>
      <p :if={@description} id={@desc_id} class="aui-radio-group__description">{@description}</p>
      <div class="aui-radio-group__options">
        <.radio
          :for={opt <- @options}
          name={@name}
          value={opt.value}
          checked={selected?(opt.value, @value)}
          disabled={opt.disabled}
          invalid={@invalid}
          description={opt.description}
        >
          {opt.label}
        </.radio>
        {render_slot(@inner_block)}
      </div>
    </fieldset>
    """
  end

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, required: true
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :invalid, :boolean, default: false
  attr :description, :string, default: nil, doc: "per-option helper text"
  attr :rest, :global, include: ~w(phx-change phx-click phx-value-id)
  slot :inner_block, required: true, doc: "the option label"

  @doc """
  A single radio option. Usually rendered by `radio_group/1`; use it directly
  only when you need a bespoke group layout, remembering to give each radio the
  same `name`.

  ## Examples

      <.radio name="plan" value="pro" checked>Pro</.radio>
  """
  def radio(assigns) do
    id = assigns.id || id(nil, "radio")

    assigns = assign(assigns, id: id, desc_id: (assigns.description && "#{id}-desc") || nil)

    ~H"""
    <label class={
      cx([
        "aui-radio",
        {"aui-radio--invalid", @invalid},
        {"aui-radio--disabled", @disabled}
      ])
    }>
      <span class="aui-radio__control">
        <input
          type="radio"
          id={@id}
          name={@name}
          value={@value}
          class="aui-radio__input aui-focusable"
          checked={@checked}
          disabled={@disabled}
          aria-invalid={@invalid && "true"}
          aria-describedby={@desc_id}
          {@rest}
        />
        <span class="aui-radio__dot" aria-hidden="true"></span>
      </span>
      <span class="aui-radio__text">
        <span class="aui-radio__title">{render_slot(@inner_block)}</span>
        <span :if={@description} id={@desc_id} class="aui-radio__description">{@description}</span>
      </span>
    </label>
    """
  end

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :invalid, :boolean, default: false
  attr :label_on, :string, default: nil, doc: "short on-state text drawn inside the track"
  attr :label_off, :string, default: nil, doc: "short off-state text drawn inside the track"

  attr :rest, :global,
    include: ~w(form required phx-change phx-click phx-value-id phx-blur phx-focus)

  slot :inner_block, doc: "the switch label"
  slot :description

  @doc """
  A toggle switch built on a native checkbox with `role="switch"`. The thumb
  animates between states and snaps instantly under reduced-motion. Use for an
  instantly-applied on/off setting; use `checkbox/1` when the value is only
  committed on form submit.

  ## Examples

      <.switch name="notify" checked={@notify} phx-change="toggle">
        Email notifications
      </.switch>
  """
  def switch(assigns) do
    id = assigns.id || id(nil, "switch")

    assigns =
      assign(assigns,
        id: id,
        desc_id: (assigns.description != [] && "#{id}-desc") || nil
      )

    ~H"""
    <label class={
      cx([
        "aui-switch",
        {"aui-switch--invalid", @invalid},
        {"aui-switch--disabled", @disabled}
      ])
    }>
      <span class="aui-switch__control">
        <input
          type="checkbox"
          role="switch"
          id={@id}
          name={@name}
          value={@value}
          class="aui-switch__input aui-focusable"
          checked={@checked}
          disabled={@disabled}
          aria-invalid={@invalid && "true"}
          aria-describedby={@desc_id}
          {@rest}
        />
        <span class="aui-switch__track" aria-hidden="true">
          <span :if={@label_off} class="aui-switch__state aui-switch__state--off">{@label_off}</span>
          <span :if={@label_on} class="aui-switch__state aui-switch__state--on">{@label_on}</span>
          <span class="aui-switch__thumb"></span>
        </span>
      </span>
      <span :if={@inner_block != [] or @description != []} class="aui-switch__text">
        <span :if={@inner_block != []} class="aui-switch__title">{render_slot(@inner_block)}</span>
        <span :if={@description != []} id={@desc_id} class="aui-switch__description">
          {render_slot(@description)}
        </span>
      </span>
    </label>
    """
  end

  attr :name, :string, required: true, doc: "shared radio name for the cluster"
  attr :value, :string, default: nil, doc: "the selected option value"
  attr :label, :string, default: nil, doc: "accessible name for the radiogroup"

  attr :options, :list,
    required: true,
    doc: "`{label, value}` tuples or maps with :label/:value/:disabled"

  attr :disabled, :boolean, default: false, doc: "disables every segment"
  attr :size, :string, default: "md", values: @sizes
  attr :rest, :global

  @doc """
  A compact set of exclusive options rendered as a single segmented cluster.
  Backed by native radios, so arrow keys move the selection and it participates
  in forms. Use for 2–5 short, peer options (a view toggle, a density switch);
  reach for `radio_group/1` when options need descriptions or wrap.

  ## Examples

      <.segmented_control name="view" value={@view} label="View" options={[
        {"List", "list"}, {"Grid", "grid"}, {"Board", "board"}
      ]} />
  """
  def segmented_control(assigns) do
    assigns = assign(assigns, :options, normalize_options(assigns.options))

    ~H"""
    <div
      class={cx(["aui-segmented", "aui-segmented--#{@size}", {"aui-segmented--disabled", @disabled}])}
      role="radiogroup"
      aria-label={@label}
      {@rest}
    >
      <label
        :for={opt <- @options}
        class={
          cx([
            "aui-segmented__option",
            {"aui-segmented__option--selected", selected?(opt.value, @value)}
          ])
        }
      >
        <input
          type="radio"
          name={@name}
          value={opt.value}
          class="aui-segmented__input aui-focusable"
          checked={selected?(opt.value, @value)}
          disabled={@disabled or opt.disabled}
        />
        <span class="aui-segmented__label">{opt.label}</span>
      </label>
    </div>
    """
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp selected?(_value, nil), do: false
  defp selected?(value, selected), do: to_string(value) == to_string(selected)

  defp normalize_options(options) do
    Enum.map(options, fn
      {label, value} ->
        %{label: label, value: value, description: nil, disabled: false}

      %{} = map ->
        %{
          label: map[:label] || map["label"],
          value: map[:value] || map["value"],
          description: map[:description] || map["description"],
          disabled: map[:disabled] || map["disabled"] || false
        }
    end)
  end
end
