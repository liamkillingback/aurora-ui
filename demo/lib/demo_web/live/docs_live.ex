defmodule DemoWeb.DocsLive do
  @moduledoc """
  Prose documentation pages (`/docs/:page`). Reads the whitelisted markdown
  file from the library's `docs/` directory, converts it to HTML server-side
  with `DemoWeb.Markdown`, and wraps the result in Aurora's `<.prose>`. Renders
  fully without JavaScript and is deep-linkable per page.
  """
  use DemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def handle_params(%{"page" => slug}, _uri, socket) do
    case Nav.doc_page(slug) do
      nil ->
        {:noreply,
         socket
         |> assign(:page_title, "Not found")
         |> assign(:page_description, "This documentation page could not be found.")
         |> assign(:nav_active, slug)
         |> assign(:doc, nil)
         |> assign(:content, nil)}

      %{title: title} = doc ->
        {:ok, content} = DemoWeb.Markdown.render_page(slug)

        {:noreply,
         socket
         |> assign(:page_title, "#{title} — Docs")
         |> assign(:page_description, "Aurora UI documentation: #{title}.")
         |> assign(:nav_active, slug)
         |> assign(:doc, doc)
         |> assign(:content, content)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active={@nav_active}>
      <div class="demo-page">
        <%= if @doc do %>
          <div class="demo-pagehead">
            <span class="demo-pagehead__eyebrow">Documentation</span>
            <h1 class="demo-pagehead__title">{@doc.title}</h1>
          </div>
          <.prose>
            {@content}
          </.prose>
        <% else %>
          <.empty_state
            title="Page not found"
            description="We couldn't find that documentation page."
          >
            <:icon><.icon name="hero-document-magnifying-glass" class="size-8" /></:icon>
            <:actions>
              <.button navigate={~p"/docs/getting-started"}>Getting started</.button>
            </:actions>
          </.empty_state>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
