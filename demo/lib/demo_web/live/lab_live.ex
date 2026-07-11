defmodule DemoWeb.LabLive do
  @moduledoc """
  The immersive **component constellation** (`/lab`).

  Each node is a component family; families are grouped into clusters (the
  "states" of building an interface). The primary UI is a real, keyboard-navigable
  semantic map — a grid of links into each family's docs — that works with **no
  canvas, JS, or WebGL**. That same map is the `scene_host`'s `:semantic` slot, so
  assistive-technology, no-JS, and no-WebGL users get the full experience.

  The `:fallback` slot is an intentionally-designed static CSS constellation (not
  a blank gradient): positioned, colored nodes with connecting lines. It is the
  reduced-motion experience and is shown until — and unless — the optional
  Three.js scene initializes. Hovering or focusing a family in the list emphasizes
  the matching constellation node via `Phoenix.LiveView.JS` (client-side, no round
  trip), so the link between map and art needs no canvas.
  """
  use DemoWeb, :live_view

  # Families are grouped into six clusters; each maps to a --aui-data-N accent.
  @clusters [
    {"Input & forms", "The controls people type and choose with.", 1,
     ~w(actions field choices selection)},
    {"Structure & flow", "Getting around and revealing content.", 2, ~w(navigation tabs)},
    {"Overlays & command", "Layered surfaces and find-and-act.", 3, ~w(overlay floating command)},
    {"Feedback & progress", "Telling people what just happened.", 4, ~w(feedback progress)},
    {"Data", "Presenting and navigating records.", 5, ~w(data-display data-navigation media)},
    {"Experience", "The signature motion and 3D layer.", 6, ~w(experience)}
  ]

  # Deterministic scatter for the static constellation, one {x%, y%} per family
  # slug. Hand-placed so clusters read as loose groupings rather than a grid.
  @positions %{
    "actions" => {14, 22},
    "field" => {26, 40},
    "choices" => {12, 58},
    "selection" => {24, 74},
    "navigation" => {42, 18},
    "tabs" => {40, 40},
    "overlay" => {58, 26},
    "floating" => {70, 42},
    "command" => {60, 60},
    "feedback" => {46, 66},
    "progress" => {40, 84},
    "data-display" => {80, 22},
    "data-navigation" => {88, 46},
    "media" => {82, 70},
    "experience" => {66, 82}
  }

  @install_code ~S|<.scene_host scene="constellation">
  <:fallback><%!-- designed static art --%></:fallback>
  <:semantic><%!-- the real, keyboard-navigable family map --%></:semantic>
</.scene_host>|

  @impl true
  def mount(_params, _session, socket) do
    families = Nav.families()
    by_slug = Map.new(families, &{&1.slug, &1})

    clusters =
      for {label, blurb, color, slugs} <- @clusters do
        %{
          label: label,
          blurb: blurb,
          color: color,
          families: Enum.map(slugs, &Map.fetch!(by_slug, &1))
        }
      end

    nodes =
      for {label, _blurb, color, slugs} <- @clusters, slug <- slugs do
        fam = Map.fetch!(by_slug, slug)
        {x, y} = Map.fetch!(@positions, slug)
        %{slug: slug, name: fam.name, cluster: label, color: color, x: x, y: y}
      end

    {:ok,
     socket
     |> assign(:page_title, "The Lab — component constellation")
     |> assign(
       :page_description,
       "An immersive map of Aurora UI's 15 component families. Each node is a family; each cluster is a state. Fully keyboard-navigable with no canvas required."
     )
     |> assign(:nav_active, "lab")
     |> assign(:clusters, clusters)
     |> assign(:nodes, nodes)
     |> assign(:install_code, @install_code)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active={@nav_active}>
      <div class="demo-page lab">
        <div class="demo-pagehead">
          <span class="demo-pagehead__eyebrow">The Lab</span>
          <h1 class="demo-pagehead__title">The component constellation</h1>
          <p class="demo-pagehead__lede">
            Each node is a component family; each cluster is a state of building an interface —
            input, structure, overlays, feedback, data, and experience. Select any node to open
            that family's docs. This map is fully usable with your keyboard and needs no canvas,
            JavaScript, or WebGL — the 3D scene, if your device supports it, is only a layer on top.
          </p>
        </div>

        <.callout variant="note" title="A calm, optional enhancement">
          The moving scene pauses when it scrolls off-screen and never runs under
          <.link_text navigate={~p"/docs/motion"}>reduced motion</.link_text>
          — in that case you see the static constellation below, which is the real experience, not
          a downgrade. Nothing here hides the install command or navigation. Toggle motion any time
          with the <.icon name="hero-bolt" class="size-4" /> control in the top bar.
        </.callout>

        <div class="lab-scene-wrap">
          <.scene_host id="lab-scene" scene="constellation" dpr_cap={1.5}>
            <:fallback>
              <div class="lab-constellation">
                <svg
                  class="lab-constellation__links"
                  viewBox="0 0 100 100"
                  preserveAspectRatio="none"
                  aria-hidden="true"
                >
                  <line
                    :for={node <- @nodes}
                    x1="50"
                    y1="50"
                    x2={node.x}
                    y2={node.y}
                    class={"lab-constellation__link lab-constellation__link--#{node.color}"}
                  />
                </svg>
                <span class="lab-constellation__core" aria-hidden="true">
                  <span class="lab-constellation__core-label">Aurora UI</span>
                </span>
                <span
                  :for={node <- @nodes}
                  id={"lab-node-#{node.slug}"}
                  class={"lab-constellation__node lab-constellation__node--#{node.color}"}
                  style={"--x: #{node.x}%; --y: #{node.y}%;"}
                >
                  <span class="lab-constellation__dot"></span>
                  <span class="lab-constellation__name">{node.name}</span>
                </span>
              </div>
            </:fallback>

            <:semantic>
              <nav class="lab-map" aria-label="Component families">
                <p class="lab-map__hint">
                  15 families, grouped into 6 clusters. Every family links to its live docs.
                </p>
                <div class="lab-map__clusters">
                  <section
                    :for={cluster <- @clusters}
                    class={"lab-cluster lab-cluster--#{cluster.color}"}
                    aria-label={cluster.label}
                  >
                    <header class="lab-cluster__head">
                      <span class="lab-cluster__dot" aria-hidden="true"></span>
                      <h2 class="lab-cluster__title">{cluster.label}</h2>
                      <p class="lab-cluster__blurb">{cluster.blurb}</p>
                    </header>
                    <ul class="lab-cluster__list" role="list">
                      <li :for={family <- cluster.families}>
                        <.link
                          navigate={~p"/components/#{family.slug}"}
                          class="lab-node-link aui-focusable"
                          data-slug={family.slug}
                          phx-focus={activate(family.slug)}
                          phx-blur={deactivate(family.slug)}
                        >
                          <span class="lab-node-link__name">{family.name}</span>
                          <span class="lab-node-link__tagline">{family.tagline}</span>
                          <span class="lab-node-link__cue" aria-hidden="true">
                            <.icon name="hero-arrow-up-right" class="size-4" />
                          </span>
                        </.link>
                      </li>
                    </ul>
                  </section>
                </div>
              </nav>
            </:semantic>
          </.scene_host>
        </div>

        <section class="demo-page">
          <div class="demo-pagehead">
            <span class="demo-pagehead__eyebrow">How it's built</span>
            <h2 class="demo-pagehead__title">One host, three honest layers</h2>
            <p class="demo-pagehead__lede">
              The <code>scene_host</code>
              always ships a designed static fallback and real semantic HTML; the WebGL scene is
              lazy-loaded and only fades in once it succeeds. Read the
              <.link_text navigate={~p"/components/experience"}>Experience family</.link_text>
              for the full progressive-enhancement contract.
            </p>
          </div>
          <.code_block code={@install_code} language="heex" filename="lab.html.heex" />
        </section>
      </div>
    </Layouts.app>
    """
  end

  # Client-side emphasis of the matching constellation node — no server round trip
  # and no dependency on the canvas.
  defp activate(slug),
    do: JS.set_attribute({"data-active", "true"}, to: "#lab-node-#{slug}")

  defp deactivate(slug),
    do: JS.remove_attribute("data-active", to: "#lab-node-#{slug}")
end
