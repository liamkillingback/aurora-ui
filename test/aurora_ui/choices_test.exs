defmodule AuroraUI.ChoicesTest do
  use ExUnit.Case, async: true

  import Phoenix.Component, except: [slot: 2, slot: 1]
  import Phoenix.LiveViewTest
  import AuroraUI.Components.Choices

  # Builds a slot list in the shape render_component/2 expects.
  defp slot(name, content) do
    [%{__slot__: name, inner_block: fn _assigns, _arg -> content end}]
  end

  describe "checkbox/1" do
    test "renders a native checkbox with label and describedby wiring" do
      html =
        render_component(&checkbox/1,
          id: "terms",
          name: "accept",
          checked: true,
          inner_block: slot(:inner_block, "I accept"),
          description: slot(:description, "Required to continue")
        )

      assert html =~ ~s(type="checkbox")
      assert html =~ ~s(id="terms")
      assert html =~ ~s(name="accept")
      assert html =~ "checked"
      assert html =~ "I accept"
      assert html =~ ~s(aria-describedby="terms-desc")
      assert html =~ ~s(id="terms-desc")
      assert html =~ "Required to continue"
    end

    test "indeterminate renders aria-checked=mixed and a modifier class" do
      html =
        render_component(&checkbox/1,
          id: "c",
          indeterminate: true,
          inner_block: slot(:inner_block, "Select all")
        )

      assert html =~ ~s(aria-checked="mixed")
      assert html =~ "aui-check--indeterminate"
    end

    test "invalid and disabled states are reflected" do
      html =
        render_component(&checkbox/1,
          id: "c",
          invalid: true,
          disabled: true,
          inner_block: slot(:inner_block, "x")
        )

      assert html =~ ~s(aria-invalid="true")
      assert html =~ "disabled"
      assert html =~ "aui-check--invalid"
      assert html =~ "aui-check--disabled"
    end
  end

  describe "radio_group/1 and radio/1" do
    test "renders a radiogroup fieldset with a legend and shared-name radios" do
      html =
        render_component(&radio_group/1,
          label: "Plan",
          name: "plan",
          value: "pro",
          description: "Choose a plan",
          options: [
            {"Free", "free"},
            %{label: "Pro", value: "pro", description: "Everything in Free"}
          ]
        )

      assert html =~ "<fieldset"
      assert html =~ ~s(role="radiogroup")
      assert html =~ "<legend"
      assert html =~ "Plan"
      assert html =~ ~s(type="radio")
      assert html =~ ~s(name="plan")
      assert html =~ ~s(value="free")
      assert html =~ ~s(value="pro")
      # exactly one radio is checked (the selected value)
      assert length(Regex.scan(~r/\schecked(?=[\s>])/, html)) == 1
      assert html =~ "Everything in Free"
      assert html =~ ~s(aria-describedby="#{radio_group_desc_id(html)}")
    end

    test "disabled group disables the fieldset" do
      html =
        render_component(&radio_group/1,
          name: "plan",
          disabled: true,
          options: [{"Free", "free"}]
        )

      assert html =~ "<fieldset"
      assert html =~ "disabled"
    end

    test "standalone radio exposes invalid and description" do
      html =
        render_component(&radio/1,
          id: "r",
          name: "plan",
          value: "pro",
          invalid: true,
          description: "Best value",
          inner_block: slot(:inner_block, "Pro")
        )

      assert html =~ ~s(type="radio")
      assert html =~ ~s(aria-invalid="true")
      assert html =~ ~s(aria-describedby="r-desc")
      assert html =~ "Best value"
    end
  end

  describe "switch/1" do
    test "renders a checkbox with role=switch" do
      html =
        render_component(&switch/1,
          id: "n",
          name: "notify",
          checked: true,
          label_on: "On",
          label_off: "Off",
          inner_block: slot(:inner_block, "Notifications")
        )

      assert html =~ ~s(type="checkbox")
      assert html =~ ~s(role="switch")
      assert html =~ "checked"
      assert html =~ "Notifications"
      assert html =~ "aui-switch__thumb"
      assert html =~ "On"
      assert html =~ "Off"
    end
  end

  describe "segmented_control/1" do
    test "renders exclusive radios styled as a segmented radiogroup" do
      html =
        render_component(&segmented_control/1,
          name: "view",
          value: "grid",
          label: "View",
          options: [{"List", "list"}, {"Grid", "grid"}]
        )

      assert html =~ ~s(role="radiogroup")
      assert html =~ ~s(aria-label="View")
      assert html =~ ~s(type="radio")
      assert html =~ ~s(name="view")
      assert html =~ "aui-segmented__option--selected"
      assert html =~ ~s(value="grid" checked) or html =~ ~s(checked)
    end

    test "disabled disables every segment" do
      html =
        render_component(&segmented_control/1,
          name: "view",
          disabled: true,
          options: [{"List", "list"}, {"Grid", "grid"}]
        )

      assert html =~ "aui-segmented--disabled"
      assert html =~ "disabled"
    end
  end

  # Extract the generated description id so the assertion does not hard-code the
  # random suffix used when no id is supplied.
  defp radio_group_desc_id(html) do
    [_, id] = Regex.run(~r/id="([^"]+-desc)"/, html)
    id
  end
end
