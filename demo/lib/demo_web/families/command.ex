defmodule DemoWeb.Families.Command do
  @moduledoc """
  Component-lab stories for the Command family — search field, search results,
  and the command palette. Structure mirrors `DemoWeb.Families.Actions`: a
  `@code` map of copyable HEEx plus a `lab/1` render of `<.story>` blocks.
  """
  use DemoWeb, :html

  @code %{
    search: ~S|<.search_field
  label="Search docs"
  placeholder="Search the docs…"
  value="butto"
  phx-change="search"
  phx-submit="search"
  debounce={200}
/>|,
    search_loading: ~S|<.search_field label="Search docs" value="deploy" loading />|,
    results: ~S|<.search_results count={3}>
  <.search_result navigate={~p"/components/actions"}>
    <:icon><.icon name="hero-cursor-arrow-rays" class="size-4" /></:icon>
    Button
    <:meta>Actions</:meta>
  </.search_result>
  <.search_result navigate={~p"/components/field"}>
    <:icon><.icon name="hero-pencil-square" class="size-4" /></:icon>
    Text input
    <:meta>Field</:meta>
  </.search_result>
  <.search_result navigate={~p"/components/navigation"}>
    <:icon><.icon name="hero-map" class="size-4" /></:icon>
    Breadcrumbs
    <:meta>Navigation</:meta>
  </.search_result>
</.search_results>|,
    empty: ~S|<.search_results count={0}>
  <:empty>
    <p>No matches for <strong>“xylophone”</strong>.</p>
    <p>Try <.search_result>installation</.search_result> or <.search_result>tokens</.search_result>.</p>
  </:empty>
</.search_results>|,
    palette: ~S|<.command_palette id="demo-cmdk" shortcut="⌘K" trigger_label="Search commands">
  <:group label="Navigation">
    <button role="option" data-aui-command-item phx-click="go" phx-value-to="/inbox">
      Go to Inbox
    </button>
    <button role="option" data-aui-command-item phx-click="go" phx-value-to="/settings">
      Go to Settings
    </button>
  </:group>
  <:group label="Actions">
    <button role="option" data-aui-command-item phx-click="new">
      New project
    </button>
  </:group>
  <:empty>No commands match.</:empty>
</.command_palette>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Search field"
        description="A type=search input inside a role=search landmark, with a leading icon and an auto-hiding clear button."
        code={@code.search}
      >
        <div style="width:100%;max-width:26rem;">
          <.search_field
            label="Search docs"
            placeholder="Search the docs…"
            value="butto"
            phx-change="search"
            phx-submit="search"
            debounce={200}
          />
        </div>
      </.story>

      <.story
        title="Loading state"
        description="Set loading to announce aria-busy and show the inline spinner while results resolve."
        code={@code.search_loading}
      >
        <div style="width:100%;max-width:26rem;">
          <.search_field label="Search docs" value="deploy" loading />
        </div>
      </.story>

      <.story
        title="Search results"
        description="A semantic list of result rows with a count. The count feeds a polite aria-live announcement."
        code={@code.results}
      >
        <div style="width:100%;max-width:30rem;">
          <.search_results count={3}>
            <.search_result navigate={~p"/components/actions"}>
              <:icon><.icon name="hero-cursor-arrow-rays" class="size-4" /></:icon>
              Button
              <:meta>Actions</:meta>
            </.search_result>
            <.search_result navigate={~p"/components/field"}>
              <:icon><.icon name="hero-pencil-square" class="size-4" /></:icon>
              Text input
              <:meta>Field</:meta>
            </.search_result>
            <.search_result navigate={~p"/components/navigation"}>
              <:icon><.icon name="hero-map" class="size-4" /></:icon>
              Breadcrumbs
              <:meta>Navigation</:meta>
            </.search_result>
          </.search_results>
        </div>
      </.story>

      <.story
        title="No results"
        description="When count is 0 the empty slot renders. Put suggested queries or recovery actions here."
        code={@code.empty}
      >
        <div style="width:100%;max-width:30rem;">
          <.search_results count={0}>
            <:empty>
              <p style="color:rgb(var(--aui-text));">No matches for <strong>“xylophone”</strong>.</p>
              <p style="color:rgb(var(--aui-text-muted));">
                Try
                <.search_result>installation</.search_result>
                or <.search_result>tokens</.search_result>.
              </p>
            </:empty>
          </.search_results>
        </div>
      </.story>

      <.story
        title="Command palette"
        description="Opened from a visible trigger button (never a shortcut alone). Click it to open the dialog; the ⌘K hint is discoverable and configurable."
        code={@code.palette}
      >
        <.command_palette id="demo-cmdk" shortcut="⌘K" trigger_label="Search commands">
          <:group label="Navigation">
            <button role="option" data-aui-command-item phx-click="go" phx-value-to="/inbox">
              Go to Inbox
            </button>
            <button role="option" data-aui-command-item phx-click="go" phx-value-to="/settings">
              Go to Settings
            </button>
          </:group>
          <:group label="Actions">
            <button role="option" data-aui-command-item phx-click="new">
              New project
            </button>
          </:group>
          <:empty>No commands match.</:empty>
        </.command_palette>
      </.story>
    </div>
    """
  end
end
