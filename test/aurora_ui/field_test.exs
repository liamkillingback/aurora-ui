defmodule AuroraUI.Components.FieldTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  import AuroraUI.Components.Field

  # A field wrapping an input, splatting the association map onto the control.
  defp wired_field(assigns) do
    ~H"""
    <.field
      :let={f}
      id="email"
      label="Email"
      help="We never share it."
      error="Enter a valid email"
      required
    >
      <.input {f} type="email" name="user[email]" />
    </.field>
    """
  end

  describe "field/1 association" do
    test "wires label, help (describedby) and error (errormessage + invalid) by id" do
      html = render_component(&wired_field/1, %{})

      # Label points at the control.
      assert html =~ ~s(for="email")
      assert html =~ ~s(id="email-label")

      # Help referenced via aria-describedby.
      assert html =~ ~s(id="email-help")
      assert html =~ ~s(aria-describedby="email-help")

      # Error referenced via aria-errormessage, and control marked invalid.
      assert html =~ ~s(id="email-error")
      assert html =~ ~s(aria-errormessage="email-error")
      assert html =~ ~s(aria-invalid="true")

      # Required indicator with a screen-reader equivalent.
      assert html =~ "aui-field__required"
      assert html =~ "required</span>"
    end

    test "optional hint renders when not required" do
      assigns = %{}

      html =
        render_component(
          fn assigns ->
            ~H"""
            <.field :let={f} id="nick" label="Nickname" optional>
              <.input {f} name="nick" />
            </.field>
            """
          end,
          assigns
        )

      assert html =~ "(optional)"
      refute html =~ ~s(aria-invalid="true")
    end
  end

  describe "input/1" do
    test "standalone help wires aria-describedby to the generated help id" do
      html = render_component(&input/1, id: "email", name: "email", help: "We never share it")

      assert html =~ ~s(aria-describedby="email-help")
      assert html =~ ~s(id="email-help")
      assert html =~ "aui-field__help"
    end

    test "renders a real input of the requested type" do
      html = render_component(&input/1, id: "phone", name: "phone", type: "tel")
      assert html =~ ~s(<input)
      assert html =~ ~s(type="tel")
      assert html =~ "aui-focusable"
    end

    test "disabled and readonly reflect onto the control box" do
      disabled = render_component(&input/1, id: "a", name: "a", disabled: true)
      assert disabled =~ ~s(disabled)
      assert disabled =~ ~s(data-disabled="true")

      readonly = render_component(&input/1, id: "b", name: "b", readonly: true)
      assert readonly =~ ~s(readonly)
      assert readonly =~ ~s(data-readonly="true")
    end

    test "invalid state sets aria-invalid and the invalid data hook" do
      html = render_component(&input/1, id: "c", name: "c", invalid: true)
      assert html =~ ~s(aria-invalid="true")
      assert html =~ ~s(data-invalid="true")
    end

    test "prefix and suffix render as decorative affixes" do
      assigns = %{}

      html =
        render_component(
          fn assigns ->
            ~H"""
            <.input id="handle" name="handle">
              <:prefix>@</:prefix>
              <:suffix>.dev</:suffix>
            </.input>
            """
          end,
          assigns
        )

      assert html =~ "aui-field__affix--prefix"
      assert html =~ "aui-field__affix--suffix"
      assert html =~ ~s(aria-hidden="true")
    end

    test "character count references the input and shows length/max" do
      html =
        render_component(&input/1,
          id: "bio",
          name: "bio",
          value: "hello",
          show_count: true,
          maxlength: 30
        )

      assert html =~ ~s(id="bio-count")
      assert html =~ ~s(aria-describedby="bio-count")
      assert html =~ "5/30"
      assert html =~ ~s(maxlength="30")
    end

    test "derives name, value, invalid and error from a form field" do
      form = to_form(%{"email" => "bad"}, as: :user, errors: [email: {"is required", []}])

      html = render_component(&input/1, field: form[:email])

      assert html =~ ~s(name="user[email]")
      assert html =~ ~s(value="bad")
      assert html =~ ~s(aria-invalid="true")
      assert html =~ "is required"
    end
  end

  describe "textarea/1" do
    test "renders a multiline control with count and autosize hook" do
      html =
        render_component(&textarea/1,
          id: "notes",
          name: "notes",
          value: "abc",
          show_count: true,
          maxlength: 100,
          autosize: true
        )

      assert html =~ ~s(<textarea)
      assert html =~ ~s(data-aui-autosize="true")
      assert html =~ "3/100"
      assert html =~ "aui-field__textarea"
    end
  end

  describe "standalone pieces" do
    test "label renders for + required affordances" do
      assigns = %{}

      html =
        render_component(
          fn assigns ->
            ~H"""
            <.label for="x" required>Name</.label>
            """
          end,
          assigns
        )

      assert html =~ ~s(<label)
      assert html =~ ~s(for="x")
      assert html =~ "aui-field__required"
      assert html =~ "required</span>"
    end

    test "help_text carries its id" do
      assigns = %{}

      html =
        render_component(
          fn assigns ->
            ~H"""
            <.help_text id="h">Use 12+ chars.</.help_text>
            """
          end,
          assigns
        )

      assert html =~ ~s(id="h")
      assert html =~ "aui-field__help"
    end

    test "field_error uses role=alert for validation messaging" do
      assigns = %{}

      html =
        render_component(
          fn assigns ->
            ~H"""
            <.field_error id="e">Enter a valid email.</.field_error>
            """
          end,
          assigns
        )

      assert html =~ ~s(role="alert")
      assert html =~ ~s(id="e")
      assert html =~ "aui-field__error"
    end
  end
end
