defmodule DemoWeb.Families.Navigation do
  @moduledoc """
  Component-lab stories for the Navigation family — skip link, navbar, sidebar,
  breadcrumbs, pagination, and steps. Follows the `DemoWeb.Families.Actions`
  exemplar: a `@code` map of copyable HEEx plus `lab/1`, which renders a
  `<div class="demo-stories">` of `<.story>` blocks with live previews.
  """
  use DemoWeb, :html

  # Copyable HEEx per story, kept in an attribute so the template has no
  # unindented heredoc lines.
  @code %{
    skip_link: ~S|<.skip_link href="#main">Skip to content</.skip_link>|,
    navbar: ~S|<.navbar id="site-nav" label="Primary">
  <:brand><.link navigate={~p"/"}>Aurora</.link></:brand>
  <:link navigate={~p"/app"} current>Dashboard</:link>
  <:link navigate={~p"/app/projects"}>Projects</:link>
  <:link navigate={~p"/app/team"}>Team</:link>
  <:actions><.button size="sm">Sign in</.button></:actions>
</.navbar>|,
    sidebar: ~S|<.sidebar label="App">
  <:section label="Workspace">
    <.sidebar_item navigate={~p"/app"} current>
      <:icon><.icon name="hero-home" class="size-4" /></:icon>
      Dashboard
    </.sidebar_item>
    <.sidebar_item navigate={~p"/app/projects"}>
      <:icon><.icon name="hero-folder" class="size-4" /></:icon>
      Projects
    </.sidebar_item>
  </:section>
  <.sidebar_group label="Settings">
    <.sidebar_item navigate={~p"/app/team"}>Team</.sidebar_item>
    <.sidebar_item navigate={~p"/app/settings"}>Preferences</.sidebar_item>
  </.sidebar_group>
</.sidebar>|,
    breadcrumbs: ~S|<.breadcrumbs>
  <:crumb navigate={~p"/"}>Home</:crumb>
  <:crumb navigate={~p"/components"}>Components</:crumb>
  <:crumb>Navigation</:crumb>
</.breadcrumbs>|,
    pagination: ~S|<.pagination page={6} total_pages={20} path={fn p -> "?page=#{p}" end} />|,
    steps_horizontal: ~S|<.steps current={2}>
  <:step label="Account" description="Create your account" />
  <:step label="Profile" description="Add your details" />
  <:step label="Review" description="Confirm and finish" />
</.steps>|,
    steps_vertical: ~S|<.steps current={3} orientation="vertical">
  <:step label="Plan" description="Pick a subscription" />
  <:step label="Payment" description="Add a card" />
  <:step label="Provision" description="Spinning up resources" />
  <:step label="Done" description="Ready to go" />
</.steps>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Skip link"
        description="A visually-hidden-until-focused link that jumps past the navbar to <main>. Tab into the preview to reveal it."
        code={@code.skip_link}
      >
        <.skip_link href="#main">Skip to content</.skip_link>
      </.story>

      <.story
        title="Navbar"
        description={"Top bar with brand, primary links, and trailing actions. Links collapse behind a JS-free <details> disclosure on narrow viewports; the current link gets aria-current=\"page\"."}
        code={@code.navbar}
      >
        <.navbar id="lab-site-nav" label="Primary">
          <:brand><.link navigate={~p"/"}>Aurora</.link></:brand>
          <:link navigate={~p"/app"} current>Dashboard</:link>
          <:link navigate={~p"/app/projects"}>Projects</:link>
          <:link navigate={~p"/app/team"}>Team</:link>
          <:actions><.button size="sm">Sign in</.button></:actions>
        </.navbar>
      </.story>

      <.story
        title="Sidebar"
        description={"Vertical rail composed of sidebar_item leaves and a collapsible sidebar_group. Sections carry optional headings; the active item is marked aria-current=\"page\"."}
        code={@code.sidebar}
      >
        <div style="max-width:18rem;">
          <.sidebar label="App">
            <:section label="Workspace">
              <.sidebar_item navigate={~p"/app"} current>
                <:icon><.icon name="hero-home" class="size-4" /></:icon>
                Dashboard
              </.sidebar_item>
              <.sidebar_item navigate={~p"/app/projects"}>
                <:icon><.icon name="hero-folder" class="size-4" /></:icon>
                Projects
              </.sidebar_item>
              <.sidebar_item navigate={~p"/app/reports"}>
                <:icon><.icon name="hero-chart-bar" class="size-4" /></:icon>
                Reports
              </.sidebar_item>
            </:section>
            <.sidebar_group label="Settings">
              <.sidebar_item navigate={~p"/app/team"}>Team</.sidebar_item>
              <.sidebar_item navigate={~p"/app/settings"}>Preferences</.sidebar_item>
            </.sidebar_group>
          </.sidebar>
        </div>
      </.story>

      <.story
        title="Breadcrumbs"
        description={"An ordered trail; the final crumb is a plain aria-current=\"page\" element, never a link to the page you are already on."}
        code={@code.breadcrumbs}
      >
        <.breadcrumbs>
          <:crumb navigate={~p"/"}>Home</:crumb>
          <:crumb navigate={~p"/components"}>Components</:crumb>
          <:crumb>Navigation</:crumb>
        </.breadcrumbs>
      </.story>

      <.story
        title="Pagination"
        description={"Numbered pages with truncated ranges (1 … 5 6 7 … 20) around the current page. Pass path as a 1-arity page → href function; the current page is aria-current=\"page\"."}
        code={@code.pagination}
      >
        <.pagination page={6} total_pages={20} path={fn p -> "?page=#{p}" end} />
      </.story>

      <.story
        title="Steps — horizontal"
        description={"A process stepper. State (complete / current / upcoming) is derived from current; the active step carries aria-current=\"step\" and completed steps show a check."}
        code={@code.steps_horizontal}
      >
        <.steps current={2}>
          <:step label="Account" description="Create your account" />
          <:step label="Profile" description="Add your details" />
          <:step label="Review" description="Confirm and finish" />
        </.steps>
      </.story>

      <.story
        title="Steps — vertical"
        description={"The same stepper with orientation=\"vertical\". Logical properties keep it mirrored correctly in RTL."}
        code={@code.steps_vertical}
      >
        <.steps current={3} orientation="vertical">
          <:step label="Plan" description="Pick a subscription" />
          <:step label="Payment" description="Add a card" />
          <:step label="Provision" description="Spinning up resources" />
          <:step label="Done" description="Ready to go" />
        </.steps>
      </.story>
    </div>
    """
  end
end
