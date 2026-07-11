defmodule DemoWeb.Families.Selection do
  @moduledoc """
  Component-lab stories for the Selection family — the styled native `select`
  and the accessible, hook-enhanced `combobox`. Follows the structure of
  `DemoWeb.Families.Actions`.
  """
  use DemoWeb, :html

  @code %{
    select: ~S|<.select label="Country" name="country" value="us" options={[
  {"United States", "us"}, {"United Kingdom", "uk"}, {"Germany", "de"}
]} />|,
    select_prompt: ~S|<.select label="Role" name="role" prompt="Choose a role…" options={[
  {"Owner", "owner"}, {"Admin", "admin"}, {"Member", "member"}
]}>
  <:description>Owners can delete the workspace.</:description>
</.select>|,
    select_sizes: ~S|<.select name="sm" size="sm" value="a" options={[{"Small", "a"}]} />
<.select name="md" size="md" value="a" options={[{"Medium", "a"}]} />
<.select name="lg" size="lg" value="a" options={[{"Large", "a"}]} />|,
    select_states: ~S|<.select label="Timezone" name="tz" value="utc" invalid
  options={[{"UTC", "utc"}, {"CET", "cet"}]} />
<.select label="Plan" name="plan" value="pro" disabled
  options={[{"Pro", "pro"}]} />|,
    combobox: ~S|<.combobox id="fruit" name="fruit" label="Fruit" value="Ap" selected="apple"
  placeholder="Type to filter…" open options={[
    {"Apple", "apple"}, {"Apricot", "apricot"}, {"Avocado", "avocado"}
  ]} />|,
    combobox_loading: ~S|<.combobox id="city" name="city" label="City" value="lon"
  loading placeholder="Searching…" />|,
    combobox_empty: ~S|<.combobox id="tag" name="tag" label="Tag" value="zzz" open
  empty_label="No matching tags" options={[]} />|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Select"
        description="A styled native <select> — the robust, zero-JS baseline for a short known list."
        code={@code.select}
      >
        <div style="width:100%;max-width:22rem;">
          <.select
            label="Country"
            name="country"
            value="us"
            options={[{"United States", "us"}, {"United Kingdom", "uk"}, {"Germany", "de"}]}
          />
        </div>
      </.story>

      <.story
        title="Prompt & description"
        description="prompt renders a disabled placeholder option; the :description slot wires aria-describedby."
        code={@code.select_prompt}
      >
        <div style="width:100%;max-width:22rem;">
          <.select
            label="Role"
            name="role"
            prompt="Choose a role…"
            options={[{"Owner", "owner"}, {"Admin", "admin"}, {"Member", "member"}]}
          >
            <:description>Owners can delete the workspace.</:description>
          </.select>
        </div>
      </.story>

      <.story title="Sizes" description="sm, md (default), and lg." code={@code.select_sizes}>
        <div style="display:grid;gap:0.75rem;width:100%;max-width:22rem;">
          <.select name="sm" size="sm" value="a" options={[{"Small", "a"}]} />
          <.select name="md" size="md" value="a" options={[{"Medium", "a"}]} />
          <.select name="lg" size="lg" value="a" options={[{"Large", "a"}]} />
        </div>
      </.story>

      <.story
        title="Invalid & disabled"
        description="invalid sets aria-invalid and error styling; disabled greys the whole control."
        code={@code.select_states}
      >
        <div style="display:grid;gap:0.75rem;width:100%;max-width:22rem;">
          <.select
            label="Timezone"
            name="tz"
            value="utc"
            invalid
            options={[{"UTC", "utc"}, {"CET", "cet"}]}
          />
          <.select label="Plan" name="plan" value="pro" disabled options={[{"Pro", "pro"}]} />
        </div>
      </.story>

      <.story
        title="Combobox"
        description="An ARIA autocomplete. HEEx renders the full listbox skeleton; the AuroraCombobox hook adds keyboard/pointer behavior. Shown open with options."
        code={@code.combobox}
      >
        <div style="width:100%;max-width:22rem;">
          <.combobox
            id="fruit"
            name="fruit"
            label="Fruit"
            value="Ap"
            selected="apple"
            placeholder="Type to filter…"
            open
            options={[{"Apple", "apple"}, {"Apricot", "apricot"}, {"Avocado", "avocado"}]}
          />
        </div>
      </.story>

      <.story
        title="Combobox — loading"
        description="loading sets aria-busy and shows a spinner while the server fetches matches."
        code={@code.combobox_loading}
      >
        <div style="width:100%;max-width:22rem;">
          <.combobox
            id="city"
            name="city"
            label="City"
            value="lon"
            loading
            placeholder="Searching…"
          />
        </div>
      </.story>

      <.story
        title="Combobox — no results"
        description="With no options and not loading, the listbox shows the empty_label row."
        code={@code.combobox_empty}
      >
        <div style="width:100%;max-width:22rem;">
          <.combobox
            id="tag"
            name="tag"
            label="Tag"
            value="zzz"
            open
            empty_label="No matching tags"
            options={[]}
          />
        </div>
      </.story>
    </div>
    """
  end
end
