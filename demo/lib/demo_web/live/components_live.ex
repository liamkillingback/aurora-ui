defmodule DemoWeb.ComponentsLive do
  @moduledoc """
  The component-lab index (`/components`): all 15 families with a one-line
  description and a link into each family's lab page.
  """
  use DemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Components")
     |> assign(
       :page_description,
       "Browse all 15 Aurora UI component families and their live component lab pages."
     )
     |> assign(:families, Nav.families())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active="components">
      <div class="demo-page">
        <div class="demo-pagehead">
          <span class="demo-pagehead__eyebrow">Component lab</span>
          <h1 class="demo-pagehead__title">15 families, every state</h1>
          <p class="demo-pagehead__lede">
            Each family has a lab page with live previews and copyable HEEx for every
            variant, size, and state.
          </p>
        </div>

        <div class="demo-index">
          <.link
            :for={family <- @families}
            navigate={~p"/components/#{family.slug}"}
            class="demo-indexcard aui-focusable"
          >
            <span class="demo-indexcard__name">{family.name}</span>
            <span class="demo-indexcard__tagline">{family.tagline}</span>
            <span class="demo-indexcard__count">
              {length(family.components)} components
            </span>
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
