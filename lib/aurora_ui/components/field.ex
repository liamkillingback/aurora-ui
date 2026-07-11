defmodule AuroraUI.Components.Field do
  @moduledoc """
  Field family — text `input`, `textarea`, and the wiring that binds a label,
  help text, and validation message to a control.

  A form control is only accessible if its accessible name, its description, and
  its error are programmatically associated. `field/1` owns that association: it
  derives deterministic ids from a single base and hands them down to whatever
  control the caller places in its slot, so the label points at the control, the
  help is referenced through `aria-describedby`, and the error is referenced
  through `aria-errormessage` alongside `aria-invalid`.

  ## Semantics

  `input/1` and `textarea/1` render real `<input>` / `<textarea>` elements so
  browser and assistive-technology behavior (typing, autofill, form
  submission, validation) come from the platform. They integrate with a
  `Phoenix.HTML.FormField` (deriving `id`/`name`/`value`/errors) or with explicit
  `name`/`value`. Used standalone they can render their own help/error/count;
  used inside `field/1` they receive the association ids and let the wrapper own
  the surrounding text. `field_error/1` uses `role="alert"` so a newly rendered
  validation message is announced.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @input_types ~w(text email password url tel number search)

  attr :id, :string,
    default: nil,
    doc: "base id; control/label/help/error ids derive from it deterministically"

  attr :label, :string, default: nil, doc: "visible label text"
  attr :help, :string, default: nil, doc: "supporting hint rendered under the control"

  attr :error, :string,
    default: nil,
    doc:
      "validation message; when present the field is marked invalid and wired via aria-errormessage"

  attr :required, :boolean, default: false, doc: "shows a required indicator on the label"

  attr :optional, :boolean,
    default: false,
    doc: "shows an (optional) hint on the label; ignored when required"

  attr :rest, :global

  slot :inner_block,
    required: true,
    doc: """
    The control. Receives a map `%{id, invalid, describedby, errormessage, required}`
    that can be splatted onto `input/1` or `textarea/1` to complete the wiring.
    """

  @doc """
  Wraps a control with an associated label, help text, and error message.

  Splat the slot argument onto the control so the ids line up:

  ## Examples

      <.field :let={f} id="email" label="Email" help="We never share it." required>
        <.input {f} type="email" name="user[email]" />
      </.field>

      <.field :let={f} id="bio" label="Bio" error={@errors[:bio]}>
        <.textarea {f} name="user[bio]" />
      </.field>
  """
  def field(assigns) do
    base = assigns.id || id(nil, "field")
    has_help? = present?(assigns.help)
    invalid? = present?(assigns.error)

    label_id = id(base, "label")
    help_id = has_help? && id(base, "help")
    error_id = invalid? && id(base, "error")

    control = %{
      id: base,
      invalid: invalid?,
      describedby: help_id || nil,
      errormessage: error_id || nil,
      required: assigns.required
    }

    assigns =
      assigns
      |> assign(:base, base)
      |> assign(:has_label, present?(assigns.label))
      |> assign(:has_help, has_help?)
      |> assign(:invalid, invalid?)
      |> assign(:label_id, label_id)
      |> assign(:help_id, help_id || nil)
      |> assign(:error_id, error_id || nil)
      |> assign(:control, control)
      |> assign(
        :class,
        cx([
          "aui-field",
          {"aui-field--invalid", invalid?},
          {"aui-field--required", assigns.required}
        ])
      )

    ~H"""
    <div class={@class} data-aui data-invalid={@invalid && "true"} {@rest}>
      <.label
        :if={@has_label}
        for={@base}
        id={@label_id}
        required={@required}
        optional={@optional && !@required}
      >
        {@label}
      </.label>
      {render_slot(@inner_block, @control)}
      <.help_text :if={@has_help} id={@help_id}>{@help}</.help_text>
      <.field_error :if={@invalid} id={@error_id}>{@error}</.field_error>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :type, :string, default: "text", values: @input_types

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field; derives id/name/value and errors when set"

  attr :placeholder, :string, default: nil
  attr :autocomplete, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :readonly, :boolean, default: false
  attr :invalid, :boolean, default: false, doc: "force the invalid visual + aria-invalid"
  attr :required, :boolean, default: false

  attr :maxlength, :integer, default: nil, doc: "native max length; also caps the count display"

  attr :show_count, :boolean,
    default: false,
    doc: "render a character count (needs a value; pairs with maxlength)"

  attr :help, :string,
    default: nil,
    doc: "inline help when used standalone (omit inside <.field>)"

  attr :error, :string,
    default: nil,
    doc: "inline error when used standalone (omit inside <.field>)"

  attr :describedby, :string, default: nil, doc: "extra id(s) to reference; supplied by <.field>"

  attr :errormessage, :string,
    default: nil,
    doc: "id of an external error node; supplied by <.field>"

  attr :rest, :global,
    include: ~w(autocapitalize autocorrect spellcheck inputmode pattern min max step list form
         phx-debounce phx-change phx-blur phx-focus phx-keyup phx-keydown)

  slot :prefix, doc: "leading adornment (icon/text); decorative"
  slot :suffix, doc: "trailing adornment (icon/text); decorative"

  @doc """
  A single-line text control. Supports `type` (#{Enum.join(@input_types, "/")}),
  prefix/suffix adornments, a live-ready character count, and every relevant
  state: hover, focus, filled, disabled, readonly, and invalid.

  ## Examples

      <.input name="q" type="search" placeholder="Search" />
      <.input field={@form[:email]} type="email" autocomplete="email" />
      <.input name="handle" show_count maxlength={30} value={@handle}>
        <:prefix>@</:prefix>
      </.input>
  """
  def input(assigns) do
    assigns = normalize(assigns)

    ~H"""
    <div class="aui-field__block" data-aui>
      <div
        class={
          cx([
            "aui-field__control",
            {"aui-field__control--prefixed", @prefix != []},
            {"aui-field__control--suffixed", @suffix != []}
          ])
        }
        data-invalid={@invalid_flag && "true"}
        data-disabled={@disabled && "true"}
        data-readonly={@readonly && "true"}
      >
        <span :if={@prefix != []} class="aui-field__affix aui-field__affix--prefix" aria-hidden="true">
          {render_slot(@prefix)}
        </span>
        <input
          type={@type}
          id={@control_id}
          name={@name}
          value={@value}
          class="aui-field__input aui-focusable"
          placeholder={@placeholder}
          disabled={@disabled}
          readonly={@readonly}
          required={@required}
          autocomplete={@autocomplete}
          maxlength={@maxlength}
          aria-invalid={@aria_invalid}
          aria-describedby={@aria_describedby}
          aria-errormessage={@aria_errormessage}
          {@rest}
        />
        <span :if={@suffix != []} class="aui-field__affix aui-field__affix--suffix" aria-hidden="true">
          {render_slot(@suffix)}
        </span>
      </div>
      <div :if={@show_help || @show_error || @show_count} class="aui-field__meta">
        <.help_text :if={@show_help} id={@help_id}>{@help}</.help_text>
        <.field_error :if={@show_error} id={@error_id}>{@error_text}</.field_error>
        <span :if={@show_count} class="aui-field__count" id={@count_id} aria-live="polite">
          {@count_text}
        </span>
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :any, default: nil
  attr :field, Phoenix.HTML.FormField, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 3
  attr :disabled, :boolean, default: false
  attr :readonly, :boolean, default: false
  attr :invalid, :boolean, default: false
  attr :required, :boolean, default: false
  attr :maxlength, :integer, default: nil
  attr :show_count, :boolean, default: false

  attr :autosize, :boolean,
    default: false,
    doc:
      "adds data-aui-autosize so an optional JS hook can grow the box; height still works without JS"

  attr :help, :string, default: nil
  attr :error, :string, default: nil
  attr :describedby, :string, default: nil
  attr :errormessage, :string, default: nil

  attr :rest, :global,
    include: ~w(spellcheck wrap form phx-debounce phx-change phx-blur phx-focus phx-keyup)

  @doc """
  A multi-line text control. Same association, count, and state handling as
  `input/1`. Set `autosize` to opt into an optional grow-to-fit enhancement.

  ## Examples

      <.textarea name="notes" rows={5} placeholder="Notes" />
      <.textarea field={@form[:bio]} show_count maxlength={280} autosize />
  """
  def textarea(assigns) do
    assigns = normalize(assigns)

    ~H"""
    <div class="aui-field__block" data-aui>
      <div
        class="aui-field__control aui-field__control--multiline"
        data-invalid={@invalid_flag && "true"}
        data-disabled={@disabled && "true"}
        data-readonly={@readonly && "true"}
      >
        <textarea
          id={@control_id}
          name={@name}
          rows={@rows}
          class="aui-field__input aui-field__textarea aui-focusable"
          placeholder={@placeholder}
          disabled={@disabled}
          readonly={@readonly}
          required={@required}
          maxlength={@maxlength}
          data-aui-autosize={@autosize && "true"}
          aria-invalid={@aria_invalid}
          aria-describedby={@aria_describedby}
          aria-errormessage={@aria_errormessage}
          {@rest}
        >{@value}</textarea>
      </div>
      <div :if={@show_help || @show_error || @show_count} class="aui-field__meta">
        <.help_text :if={@show_help} id={@help_id}>{@help}</.help_text>
        <.field_error :if={@show_error} id={@error_id}>{@error_text}</.field_error>
        <span :if={@show_count} class="aui-field__count" id={@count_id} aria-live="polite">
          {@count_text}
        </span>
      </div>
    </div>
    """
  end

  attr :for, :string, default: nil, doc: "id of the control this labels"
  attr :id, :string, default: nil
  attr :required, :boolean, default: false
  attr :optional, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A control label. Renders a real `<label for>` and, when asked, a required or
  optional indicator with a screen-reader-friendly equivalent.

  ## Examples

      <.label for="email" required>Email</.label>
  """
  def label(assigns) do
    ~H"""
    <label for={@for} id={@id} class="aui-field__label" {@rest}>
      <span class="aui-field__label-text">{render_slot(@inner_block)}</span>
      <span :if={@required} class="aui-field__required" aria-hidden="true">*</span>
      <span :if={@required} class="aui-sr-only">required</span>
      <span :if={@optional} class="aui-field__optional">(optional)</span>
    </label>
    """
  end

  attr :id, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Supporting help text for a control. Give it an id and reference that id from
  the control's `aria-describedby`.

  ## Examples

      <.help_text id="pw-help">Use at least 12 characters.</.help_text>
  """
  def help_text(assigns) do
    ~H"""
    <p id={@id} class="aui-field__help" {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  attr :id, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A validation message. Uses `role="alert"` so it is announced when it appears;
  reference its id from the control's `aria-errormessage`.

  ## Examples

      <.field_error id="email-error">Enter a valid email.</.field_error>
  """
  def field_error(assigns) do
    ~H"""
    <p id={@id} class="aui-field__error" role="alert" {@rest}>{render_slot(@inner_block)}</p>
    """
  end

  # ── internals ──────────────────────────────────────────────────────────────

  # Derives all display + aria state shared by input/1 and textarea/1.
  defp normalize(assigns) do
    {name, value, base_id, field_errors} = from_field(assigns)

    control_id = base_id || id(nil, "field")
    error_text = assigns.error || first_error(field_errors)
    invalid? = assigns.invalid || present?(assigns.errormessage) || present?(error_text)

    # A control owns the help/error text it renders itself. When <.field> passes
    # the association ids down it also renders those nodes, so we only render our
    # own when the wrapper has not claimed them.
    show_help = present?(assigns.help)
    show_error = present?(error_text) && !present?(assigns.errormessage)

    help_id = control_id <> "-help"
    error_id = control_id <> "-error"
    count_id = control_id <> "-count"

    described =
      join_ids([
        assigns.describedby,
        show_help && help_id,
        assigns.show_count && count_id
      ])

    assigns
    |> assign(:name, name)
    |> assign(:value, value)
    |> assign(:control_id, control_id)
    |> assign(:invalid_flag, invalid?)
    |> assign(:error_text, error_text)
    |> assign(:show_help, show_help)
    |> assign(:show_error, show_error)
    |> assign(:help_id, help_id)
    |> assign(:error_id, error_id)
    |> assign(:count_id, count_id)
    |> assign(:aria_invalid, (invalid? && "true") || nil)
    |> assign(:aria_describedby, described)
    |> assign(:aria_errormessage, assigns.errormessage || (show_error && error_id) || nil)
    |> assign(:count_text, count_text(value, assigns.maxlength))
  end

  defp from_field(%{field: %Phoenix.HTML.FormField{} = f} = assigns) do
    value = if is_nil(assigns.value), do: f.value, else: assigns.value
    {assigns.name || f.name, value, assigns.id || f.id, f.errors}
  end

  defp from_field(assigns), do: {assigns.name, assigns.value, assigns.id, []}

  defp first_error([{msg, _opts} | _]) when is_binary(msg), do: msg
  defp first_error([msg | _]) when is_binary(msg), do: msg
  defp first_error(_), do: nil

  defp count_text(value, nil), do: Integer.to_string(value_length(value))
  defp count_text(value, max), do: "#{value_length(value)}/#{max}"

  defp value_length(value) when is_binary(value), do: String.length(value)
  defp value_length(_), do: 0

  defp join_ids(ids) do
    case ids |> Enum.filter(&(is_binary(&1) and &1 != "")) do
      [] -> nil
      list -> Enum.join(list, " ")
    end
  end

  defp present?(value), do: is_binary(value) and String.trim(value) != ""
end
