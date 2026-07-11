defmodule DemoWeb.FamilyLive do
  @moduledoc """
  A component-lab page for one family (`/components/:family`).

  The **actions** family is built out fully as the exemplar every other family
  page will follow: one `<.story>` per variant/size/state cluster, each with a
  live preview and copyable HEEx. The remaining 14 families render a
  placeholder that still lists their components (so routes and nav work); a
  later agent fills them in.

  The top bar carries a viewport control that constrains the preview width by
  setting `data-viewport` on the page's `[data-preview-root]` wrapper.
  """
  use DemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  # The command palette and combobox hooks push server events (aui:command:*,
  # aui:combobox:*) so a real app can filter/act on the server. The lab shows
  # them statically, so we accept and ignore those events rather than crash.
  @impl true
  def handle_event("aui:" <> _, _params, socket), do: {:noreply, socket}

  @impl true
  def handle_params(%{"family" => slug}, _uri, socket) do
    case Nav.family(slug) do
      nil ->
        {:noreply,
         socket
         |> assign(:page_title, "Not found")
         |> assign(:page_description, "Unknown component family.")
         |> assign(:family, nil)
         |> assign(:nav_active, slug)}

      family ->
        {:noreply,
         socket
         |> assign(:page_title, "#{family.name} components")
         |> assign(:page_description, "#{family.name} — #{family.tagline}")
         |> assign(:family, family)
         |> assign(:nav_active, slug)}
    end
  end

  @impl true
  def render(%{family: nil} = assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active={@nav_active}>
      <div class="demo-page">
        <.empty_state title="Unknown family" description="That component family does not exist.">
          <:icon><.icon name="hero-cube-transparent" class="size-8" /></:icon>
          <:actions><.button navigate={~p"/components"}>All components</.button></:actions>
        </.empty_state>
      </div>
    </Layouts.app>
    """
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active={@nav_active}>
      <:toolbar>
        <div id="demo-viewport" class="demo-viewport" role="group" aria-label="Preview width">
          <button
            type="button"
            class="demo-viewport__btn aui-focusable"
            aria-label="Mobile width"
            phx-click={set_viewport("mobile")}
          >
            <.icon name="hero-device-phone-mobile" class="size-4" />
          </button>
          <button
            type="button"
            class="demo-viewport__btn aui-focusable"
            aria-label="Tablet width"
            phx-click={set_viewport("tablet")}
          >
            <.icon name="hero-device-tablet" class="size-4" />
          </button>
          <button
            type="button"
            class="demo-viewport__btn aui-focusable"
            aria-label="Desktop width"
            aria-pressed="true"
            phx-click={set_viewport("desktop")}
          >
            <.icon name="hero-computer-desktop" class="size-4" />
          </button>
        </div>
      </:toolbar>

      <div class="demo-page" data-preview-root data-viewport="desktop">
        <div class="demo-pagehead">
          <span class="demo-pagehead__eyebrow">{@family.module}</span>
          <h1 class="demo-pagehead__title">{@family.name}</h1>
          <p class="demo-pagehead__lede">{@family.tagline}</p>
          <div class="demo-chips">
            <span :for={c <- @family.components} class="demo-chip">{c}</span>
          </div>
        </div>

        <%= if lab_module(@family.slug) do %>
          {apply(lab_module(@family.slug), :lab, [assigns])}
        <% else %>
          {placeholder(assigns)}
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  # Dispatch to the per-family lab module (one file per family in
  # `lib/demo_web/families/`) so each family's stories are isolated. Returns the
  # module if it exists and exports `lab/1`, else nil (→ placeholder).
  defp lab_module(slug) do
    mod =
      Module.concat(DemoWeb.Families, slug |> String.replace("-", "_") |> Macro.camelize())

    if Code.ensure_loaded?(mod) and function_exported?(mod, :lab, 1), do: mod
  end

  # ── Placeholder for families not yet built out ───────────────────────────
  defp placeholder(assigns) do
    ~H"""
    <div class="demo-stories">
      <.callout variant="note" title="Coming together">
        This family's lab page is being assembled. Its components are listed above and the
        route is live — interactive stories with copyable HEEx land here next, built from the
        same <code>&lt;.story&gt;</code>
        pattern as the <.link_text navigate={~p"/components/actions"}>Actions</.link_text>
        page.
      </.callout>

      <.story
        title="Components in this family"
        description={"Every public component in #{@family.name}."}
      >
        <div class="demo-chips">
          <span :for={c <- @family.components} class="demo-chip">{c}</span>
        </div>
      </.story>
    </div>
    """
  end

  # Viewport control: set data-viewport on the page's preview root and reflect
  # the pressed state across the button group.
  defp set_viewport(value) do
    JS.set_attribute({"data-viewport", value}, to: "[data-preview-root]")
    |> JS.set_attribute({"aria-pressed", "false"}, to: "#demo-viewport button")
    |> JS.set_attribute({"aria-pressed", "true"})
  end
end
