defmodule DemoWeb.Families.Choices do
  @moduledoc """
  Component-lab stories for the Choices family — `checkbox` (incl. the
  indeterminate/mixed visual), `radio_group` + `radio`, `switch`, and
  `segmented_control`. Follows the structure of `DemoWeb.Families.Actions`.
  """
  use DemoWeb, :html

  @code %{
    checkbox: ~S|<.checkbox name="terms" checked>I accept the terms</.checkbox>
<.checkbox name="news">
  Email me product news
  <:description>At most one message a week.</:description>
</.checkbox>|,
    checkbox_states: ~S|<.checkbox name="all" indeterminate>Select all</.checkbox>
<.checkbox name="off" disabled>Disabled, unchecked</.checkbox>
<.checkbox name="on" checked disabled>Disabled, checked</.checkbox>
<.checkbox name="bad" invalid>You must agree to continue</.checkbox>|,
    radio_group: ~S|<.radio_group label="Plan" name="plan" value="pro" options={[
  {"Free", "free"},
  %{label: "Pro", value: "pro", description: "Everything in Free, plus history."},
  %{label: "Enterprise", value: "ent", disabled: true}
]} />|,
    radio_invalid: ~S|<.radio_group label="Delivery" name="ship" value="std" invalid
  description="Choose one to continue." options={[
    {"Standard", "std"}, {"Express", "exp"}
  ]} />|,
    switch: ~S|<.switch name="notify" checked>Email notifications</.switch>
<.switch name="wifi" label_on="On" label_off="Off" checked>Wi-Fi</.switch>
<.switch name="beta" disabled>Beta features (disabled)</.switch>|,
    segmented: ~S|<.segmented_control name="view" value="grid" label="View" options={[
  {"List", "list"}, {"Grid", "grid"}, {"Board", "board"}
]} />
<.segmented_control name="density" value="cozy" size="sm" label="Density"
  options={[{"Compact", "compact"}, {"Cozy", "cozy"}]} />|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Checkbox"
        description="A native checkbox with a 44px hit area, label, and optional description."
        code={@code.checkbox}
      >
        <div style="display:grid;gap:0.75rem;">
          <.checkbox name="terms" checked>I accept the terms</.checkbox>
          <.checkbox name="news">
            Email me product news
            <:description>At most one message a week.</:description>
          </.checkbox>
        </div>
      </.story>

      <.story
        title="Checkbox states"
        description="Indeterminate renders aria-checked=mixed and a dash; plus disabled and invalid."
        code={@code.checkbox_states}
      >
        <div style="display:grid;gap:0.75rem;">
          <.checkbox name="all" indeterminate>Select all</.checkbox>
          <.checkbox name="off" disabled>Disabled, unchecked</.checkbox>
          <.checkbox name="on" checked disabled>Disabled, checked</.checkbox>
          <.checkbox name="bad" invalid>You must agree to continue</.checkbox>
        </div>
      </.story>

      <.story
        title="Radio group"
        description="A fieldset/legend radiogroup; options accept tuples or maps with descriptions."
        code={@code.radio_group}
      >
        <.radio_group
          label="Plan"
          name="plan"
          value="pro"
          options={[
            {"Free", "free"},
            %{label: "Pro", value: "pro", description: "Everything in Free, plus history."},
            %{label: "Enterprise", value: "ent", disabled: true}
          ]}
        />
      </.story>

      <.story
        title="Radio group — invalid"
        description="invalid styles the whole group and sets aria-invalid on the fieldset."
        code={@code.radio_invalid}
      >
        <.radio_group
          label="Delivery"
          name="ship"
          value="std"
          invalid
          description="Choose one to continue."
          options={[{"Standard", "std"}, {"Express", "exp"}]}
        />
      </.story>

      <.story
        title="Switch"
        description="A native checkbox with role=switch for instant on/off settings; optional inline labels."
        code={@code.switch}
      >
        <div style="display:grid;gap:0.75rem;">
          <.switch name="notify" checked>Email notifications</.switch>
          <.switch name="wifi" label_on="On" label_off="Off" checked>Wi-Fi</.switch>
          <.switch name="beta" disabled>Beta features (disabled)</.switch>
        </div>
      </.story>

      <.story
        title="Segmented control"
        description="A radiogroup of exclusive radios drawn as one cluster. Best for 2–5 short options."
        code={@code.segmented}
      >
        <div style="display:grid;gap:0.75rem;justify-items:start;">
          <.segmented_control
            name="view"
            value="grid"
            label="View"
            options={[{"List", "list"}, {"Grid", "grid"}, {"Board", "board"}]}
          />
          <.segmented_control
            name="density"
            value="cozy"
            size="sm"
            label="Density"
            options={[{"Compact", "compact"}, {"Cozy", "cozy"}]}
          />
        </div>
      </.story>
    </div>
    """
  end
end
