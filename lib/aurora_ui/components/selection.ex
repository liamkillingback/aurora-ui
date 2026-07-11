defmodule AuroraUI.Components.Selection do
  @moduledoc """
  Selection family — a styled native `select/1` and an accessible, hook-enhanced
  `combobox/1` autocomplete.

  `select/1` is the reliable baseline: a real `<select>` styled with tokens and a
  custom chevron, with label association, `prompt`, sizes, and disabled/invalid
  states. It needs no JavaScript.

  `combobox/1` progressively enhances a text input into an ARIA
  [combobox](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/) with a listbox
  popup. The HEEx renders the full, correct ARIA skeleton; the `AuroraCombobox`
  hook layers on keyboard and pointer behavior.

  ## Combobox DOM & hook contract

  The `phx-hook="AuroraCombobox"` lives on the `<input role="combobox">`, keyed to
  a stable `id`. From that id the component derives deterministic ids so ARIA
  relationships survive LiveView patches:

    * input:      `\#{id}`
    * listbox:    `\#{id}-listbox`  (referenced by `aria-controls`)
    * option `n`: `\#{id}-option-\#{n}`

  The input carries `aria-expanded`, `aria-controls`, `aria-autocomplete="list"`,
  and `aria-busy` while `loading`. Each `<li role="option">` carries a
  deterministic `id`, `data-value`, `aria-selected`, and `aria-disabled`.

  **The hook is responsible for**: keyboard interaction (ArrowUp/ArrowDown,
  Enter, Escape, Home/End, printable-character typeahead), pointer selection,
  click-away dismissal, marking the active option with `data-aui-active`, and
  reflecting the active option into `aria-activedescendant` on the input. It
  respects `prefers-reduced-motion` and cleans up on `destroyed()`.

  **Filtering and selection stay server-driven.** The `AuroraCombobox` hook
  pushes LiveView **server events** (`pushEventTo` on the component root) that you
  handle in `handle_event/3`:

    * `"aui:combobox:filter"` — `%{"id" => id, "query" => query}` (input changed)
    * `"aui:combobox:select"` — `%{"id" => id, "value" => value, "label" => label}`
    * `"aui:combobox:open"` / `"aui:combobox:close"` — `%{"id" => id}`
    * `"aui:combobox:clear"` — `%{"id" => id}`

  By default the hook filters client-side; add `data-aui-remote` to defer
  filtering to the server (it then pushes only `…:filter` and re-reads options
  after the patch). Options come from the `options` attribute (convenience) or one
  or more `<:option>` slots (custom markup); when both are empty and `loading` is
  false a no-results row is shown.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @sizes ~w(sm md lg)

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :label, :string, default: nil, doc: "visible label, associated via for/id"
  attr :value, :string, default: nil, doc: "the selected option value"

  attr :options, :list,
    default: [],
    doc: "`{label, value}` tuples or maps with :label/:value/:disabled"

  attr :prompt, :string, default: nil, doc: "disabled placeholder option shown first"
  attr :disabled, :boolean, default: false
  attr :invalid, :boolean, default: false
  attr :size, :string, default: "md", values: @sizes

  attr :rest, :global,
    include: ~w(form required multiple phx-change phx-blur phx-focus autocomplete)

  slot :description, doc: "helper text wired as aria-describedby"

  @doc """
  A styled native `<select>`. Prefer it over `combobox/1` whenever the full list
  is short and known — it is the most robust, zero-JS option.

  ## Examples

      <.select label="Country" name="country" value={@country} prompt="Choose…"
        options={[{"United States", "us"}, {"United Kingdom", "uk"}]} />
  """
  def select(assigns) do
    id = assigns.id || id(nil, "select")

    assigns =
      assign(assigns,
        id: id,
        desc_id: (assigns.description != [] && "#{id}-desc") || nil,
        options: normalize_options(assigns.options)
      )

    ~H"""
    <div class="aui-select-field">
      <label :if={@label} for={@id} class="aui-select__label">{@label}</label>
      <div class={cx(["aui-select", "aui-select--#{@size}", {"aui-select--invalid", @invalid}])}>
        <select
          id={@id}
          name={@name}
          class="aui-select__input aui-focusable"
          disabled={@disabled}
          aria-invalid={@invalid && "true"}
          aria-describedby={@desc_id}
          {@rest}
        >
          <option :if={@prompt} value="" disabled selected={is_nil(@value) or @value == ""}>
            {@prompt}
          </option>
          <option
            :for={opt <- @options}
            value={opt.value}
            selected={selected?(opt.value, @value)}
            disabled={opt.disabled}
          >
            {opt.label}
          </option>
        </select>
        <span class="aui-select__chevron" aria-hidden="true">
          <svg viewBox="0 0 20 20" fill="none">
            <path
              d="M6 8l4 4 4-4"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
          </svg>
        </span>
      </div>
      <p :if={@description != []} id={@desc_id} class="aui-select__description">
        {render_slot(@description)}
      </p>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :name, :string, default: nil, doc: "form field name for the typed/selected value"
  attr :value, :string, default: "", doc: "current text value of the input"
  attr :selected, :string, default: nil, doc: "committed option value, for aria-selected"
  attr :label, :string, default: nil
  attr :placeholder, :string, default: nil

  attr :options, :list,
    default: [],
    doc: "`{label, value}` tuples or maps; used when no `<:option>` slots are given"

  attr :disabled, :boolean, default: false
  attr :invalid, :boolean, default: false
  attr :loading, :boolean, default: false, doc: "sets aria-busy and shows a spinner"
  attr :required, :boolean, default: false
  attr :open, :boolean, default: false, doc: "server-controlled expanded state"
  attr :clearable, :boolean, default: true, doc: "render the clear button"
  attr :empty_label, :string, default: "No results", doc: "shown when there are no options"

  attr :rest, :global,
    include: ~w(phx-change phx-focus phx-blur phx-debounce autocomplete maxlength)

  slot :option, doc: "custom option markup; overrides `options` when present" do
    attr :value, :string
    attr :disabled, :boolean
    attr :selected, :boolean
  end

  @doc """
  An accessible autocomplete combobox. The server owns the option list (filter it
  in a `phx-change` handler); the `AuroraCombobox` hook owns keyboard, pointer,
  and active-descendant behavior. See the module doc for the full contract.

  Use it when the list is long, remote, or benefits from type-to-filter; for a
  short static list, `select/1` is simpler and needs no JS.

  ## Examples

      <.combobox id="fruit" name="fruit" label="Fruit" value={@query}
        selected={@selected} open={@open} loading={@loading} phx-change="filter"
        options={@matches} />
  """
  def combobox(assigns) do
    id = assigns.id || id(nil, "combobox")

    assigns =
      assign(assigns,
        id: id,
        root_id: "#{id}-root",
        listbox_id: "#{id}-listbox",
        norm_options: normalize_options(assigns.options),
        empty?: assigns.option == [] and assigns.options == []
      )

    ~H"""
    <div
      id={@root_id}
      class={
        cx([
          "aui-combobox",
          {"aui-combobox--invalid", @invalid},
          {"aui-combobox--disabled", @disabled}
        ])
      }
      data-aui-combobox
      phx-hook="AuroraCombobox"
    >
      <label :if={@label} for={@id} class="aui-combobox__label">{@label}</label>
      <div class="aui-combobox__control">
        <input
          type="text"
          id={@id}
          name={@name}
          value={@value}
          role="combobox"
          class="aui-combobox__input aui-focusable"
          placeholder={@placeholder}
          disabled={@disabled}
          required={@required}
          autocomplete="off"
          aria-expanded={to_string(@open)}
          aria-controls={@listbox_id}
          aria-autocomplete="list"
          aria-invalid={@invalid && "true"}
          aria-busy={@loading && "true"}
          data-aui-combobox-input
          {@rest}
        />
        <span :if={@loading} class="aui-combobox__spinner" aria-hidden="true"></span>
        <button
          :if={@clearable and not @disabled}
          type="button"
          class="aui-combobox__clear aui-focusable"
          data-aui-combobox-clear
          aria-label="Clear"
          tabindex="-1"
        >
          <svg viewBox="0 0 20 20" fill="none" aria-hidden="true">
            <path
              d="M6 6l8 8M14 6l-8 8"
              stroke="currentColor"
              stroke-width="1.5"
              stroke-linecap="round"
            />
          </svg>
        </button>
      </div>
      <ul
        id={@listbox_id}
        role="listbox"
        class="aui-combobox__listbox"
        data-aui-combobox-list
        aria-label={@label || "Suggestions"}
        hidden={not @open}
      >
        <li
          :for={{opt, i} <- Enum.with_index(@option)}
          id={"#{@id}-option-s#{i}"}
          role="option"
          class="aui-combobox__option"
          data-value={Map.get(opt, :value)}
          aria-selected={to_string(Map.get(opt, :selected, false) == true)}
          aria-disabled={Map.get(opt, :disabled, false) && "true"}
        >
          {render_slot(opt)}
        </li>
        <li
          :for={{opt, i} <- Enum.with_index(@norm_options)}
          id={"#{@id}-option-#{i}"}
          role="option"
          class="aui-combobox__option"
          data-value={opt.value}
          aria-selected={to_string(selected?(opt.value, @selected))}
          aria-disabled={opt.disabled && "true"}
        >
          {opt.label}
        </li>
        <li :if={@empty? and not @loading} class="aui-combobox__empty" role="presentation">
          {@empty_label}
        </li>
      </ul>
    </div>
    """
  end

  # ── helpers ───────────────────────────────────────────────────────────────

  defp selected?(_value, nil), do: false
  defp selected?(value, selected), do: to_string(value) == to_string(selected)

  defp normalize_options(options) do
    Enum.map(options, fn
      {label, value} ->
        %{label: label, value: value, disabled: false}

      %{} = map ->
        %{
          label: map[:label] || map["label"],
          value: map[:value] || map["value"],
          disabled: map[:disabled] || map["disabled"] || false
        }
    end)
  end
end
