defmodule DemoWeb.Families.Field do
  @moduledoc """
  Component-lab stories for the Field family — text `input`, `textarea`, the
  `field/1` wrapper that binds label/help/error to a control, and the
  `label`/`help_text`/`field_error` primitives. Follows the structure of
  `DemoWeb.Families.Actions`.
  """
  use DemoWeb, :html

  @code %{
    input_types: ~S|<.input name="text" type="text" value="Ada Lovelace" />
<.input name="email" type="email" placeholder="you@example.com" />
<.input name="password" type="password" value="hunter2" />
<.input name="search" type="search" placeholder="Search" />|,
    affixes: ~S|<.input name="handle" value="ada">
  <:prefix>@</:prefix>
</.input>
<.input name="price" type="number" value="49">
  <:prefix>$</:prefix>
  <:suffix>USD</:suffix>
</.input>|,
    count: ~S|<.input name="title" value="Launch plan" show_count maxlength={40} />|,
    states: ~S|<.input name="ok" value="Looks good" />
<.input name="bad" value="nope" invalid error="That handle is taken." />
<.input name="ro" value="read-only" readonly />
<.input name="off" value="disabled" disabled />|,
    textarea: ~S|<.textarea name="notes" rows={4} placeholder="Add a note…" />
<.textarea name="bio" value="Short bio." show_count maxlength={160} />|,
    field: ~S|<.field :let={f} id="email" label="Email" help="We never share it." required>
  <.input {f} type="email" name="user[email]" value="ada@example.com" />
</.field>|,
    field_error:
      ~S|<.field :let={f} id="username" label="Username" error="That username is taken.">
  <.input {f} name="user[username]" value="ada" />
</.field>|,
    primitives: ~S|<.label for="std" required>Full name</.label>
<.input id="std" name="std" value="Ada" />
<.help_text id="std-help">As it appears on your ID.</.help_text>
<.field_error id="std-error">This field is required.</.field_error>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Input types"
        description="Real <input> elements: text, email, password, url, tel, number, and search."
        code={@code.input_types}
      >
        <div style="display:grid;gap:0.75rem;width:100%;max-width:22rem;">
          <.input name="text" type="text" value="Ada Lovelace" />
          <.input name="email" type="email" placeholder="you@example.com" />
          <.input name="password" type="password" value="hunter2" />
          <.input name="search" type="search" placeholder="Search" />
        </div>
      </.story>

      <.story
        title="Prefix & suffix"
        description="Decorative leading/trailing adornments for units, symbols, or icons."
        code={@code.affixes}
      >
        <div style="display:grid;gap:0.75rem;width:100%;max-width:22rem;">
          <.input name="handle" value="ada">
            <:prefix>@</:prefix>
          </.input>
          <.input name="price" type="number" value="49">
            <:prefix>$</:prefix>
            <:suffix>USD</:suffix>
          </.input>
        </div>
      </.story>

      <.story
        title="Character count"
        description="show_count renders a live-polite counter; pair it with maxlength."
        code={@code.count}
      >
        <div style="width:100%;max-width:22rem;">
          <.input name="title" value="Launch plan" show_count maxlength={40} />
        </div>
      </.story>

      <.story
        title="States"
        description="Filled, invalid (with inline error), readonly, and disabled."
        code={@code.states}
      >
        <div style="display:grid;gap:0.75rem;width:100%;max-width:22rem;">
          <.input name="ok" value="Looks good" />
          <.input name="bad" value="nope" invalid error="That handle is taken." />
          <.input name="ro" value="read-only" readonly />
          <.input name="off" value="disabled" disabled />
        </div>
      </.story>

      <.story
        title="Textarea"
        description="Multi-line control with the same state and count handling as input."
        code={@code.textarea}
      >
        <div style="display:grid;gap:0.75rem;width:100%;max-width:22rem;">
          <.textarea name="notes" rows={4} placeholder="Add a note…" />
          <.textarea name="bio" value="Short bio." show_count maxlength={160} />
        </div>
      </.story>

      <.story
        title="Field wrapper"
        description="field/1 owns the label ↔ control ↔ help association; splat :let onto the control."
        code={@code.field}
      >
        <div style="width:100%;max-width:22rem;">
          <.field :let={f} id="email" label="Email" help="We never share it." required>
            <.input {f} type="email" name="user[email]" value="ada@example.com" />
          </.field>
        </div>
      </.story>

      <.story
        title="Field with error"
        description="Passing error marks the field invalid and wires aria-errormessage to a role=alert."
        code={@code.field_error}
      >
        <div style="width:100%;max-width:22rem;">
          <.field :let={f} id="username" label="Username" error="That username is taken.">
            <.input {f} name="user[username]" value="ada" />
          </.field>
        </div>
      </.story>

      <.story
        title="Label, help & error primitives"
        description="The building blocks field/1 composes — use them directly for bespoke layouts."
        code={@code.primitives}
      >
        <div style="display:grid;gap:0.5rem;width:100%;max-width:22rem;">
          <.label for="std" required>Full name</.label>
          <.input id="std" name="std" value="Ada" />
          <.help_text id="std-help">As it appears on your ID.</.help_text>
          <.field_error id="std-error">This field is required.</.field_error>
        </div>
      </.story>
    </div>
    """
  end
end
