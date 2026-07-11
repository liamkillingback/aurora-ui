defmodule DemoWeb.LandingLive do
  @moduledoc """
  The landing page (`/`). A hero built from real Aurora UI components that puts
  the visitor inside the design system, with the install commands always
  visible and clear paths into the docs and the component lab.
  """
  use DemoWeb, :live_view

  @install_code ~S|# mix.exs
def deps do
  [
    {:aurora_ui, "~> 0.1"}
  ]
end|

  @js_code ~S|// assets/js/app.js
import { AuroraHooks } from "aurora_ui"

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: { ...AuroraHooks }
})|

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Aurora UI — Phoenix LiveView component kit")
     |> assign(
       :page_description,
       "Aurora UI is a free, MIT-licensed Phoenix LiveView + Tailwind component kit: 15 accessible, themeable, server-rendered families."
     )
     |> assign(:install_code, @install_code)
     |> assign(:js_code, @js_code)
     |> assign(:families, Nav.families())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active="home">
      <div class="demo-page">
        <.spotlight as="section" class="demo-hero">
          <span class="demo-hero__eyebrow">
            <.icon name="hero-sparkles" class="size-3.5" /> Free · MIT licensed · 15 families
          </span>

          <h1 class="demo-hero__title">
            The Phoenix component kit that feels like a <em>design system</em>.
          </h1>

          <p class="demo-hero__lede">
            Server-rendered HEEx components with complete states, WCAG 2.2 AA accessibility,
            reduced-motion equivalents, and a fully themeable token layer. JavaScript only
            enhances — nothing breaks without it.
          </p>

          <div class="demo-hero__actions">
            <.button variant="primary" navigate={~p"/components/actions"}>
              Explore the lab
              <:icon_end><.icon name="hero-arrow-right" class="size-4" /></:icon_end>
            </.button>
            <.button variant="secondary" navigate={~p"/docs/getting-started"}>
              Getting started
            </.button>
            <.button variant="ghost" navigate={~p"/components"}>
              All components
            </.button>
          </div>

          <div class="demo-hero__install">
            <.code_block code={@install_code} language="elixir" filename="mix.exs" />
          </div>
        </.spotlight>

        <section class="demo-page">
          <div class="demo-pagehead">
            <span class="demo-pagehead__eyebrow">Why Aurora</span>
            <h2 class="demo-pagehead__title">Batteries included, opinions optional</h2>
            <p class="demo-pagehead__lede">
              Every family ships the states real apps need and stays out of your way when
              you want to theme, extend, or remove it.
            </p>
          </div>

          <.stagger as="div" class="demo-featuregrid">
            <.card :for={f <- features()} elevation="sm">
              <:header>
                <div style="display:flex;align-items:center;gap:0.5rem;">
                  <.icon name={f.icon} class="size-5" />
                  <strong>{f.title}</strong>
                </div>
              </:header>
              {f.body}
            </.card>
          </.stagger>
        </section>

        <section class="demo-page">
          <div class="demo-pagehead">
            <span class="demo-pagehead__eyebrow">Register the hooks</span>
            <h2 class="demo-pagehead__title">One import, every family</h2>
            <p class="demo-pagehead__lede">
              Import <code>use AuroraUI</code> in your <code>html_helpers/0</code> and register
              the hooks. Lazy entry points (command palette, 3D scene, advanced motion) stay out
              of your bundle until a component needs them.
            </p>
          </div>
          <.code_block code={@js_code} language="javascript" filename="assets/js/app.js" />
        </section>

        <section class="demo-page">
          <div class="demo-pagehead">
            <span class="demo-pagehead__eyebrow">15 families</span>
            <h2 class="demo-pagehead__title">Browse the component lab</h2>
          </div>
          <div class="demo-chips">
            <.link
              :for={f <- @families}
              navigate={~p"/components/#{f.slug}"}
              class="demo-chip aui-focusable"
            >
              {f.name}
            </.link>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  defp features do
    [
      %{
        icon: "hero-check-badge",
        title: "Every state, shipped",
        body:
          "Default, hover, focus, loading, disabled, error, empty, offline — designed, not left to you."
      },
      %{
        icon: "hero-swatch",
        title: "Themeable tokens",
        body:
          "Override CSS custom properties to rebrand. No recompile, no forked source, light and dark built in."
      },
      %{
        icon: "hero-finger-print",
        title: "Accessible by default",
        body:
          "WCAG 2.2 AA: keyboard + touch parity, correct ARIA, visible focus, forced-colors and RTL safe."
      },
      %{
        icon: "hero-bolt",
        title: "Motion with respect",
        body:
          "Reveal, spotlight, and tilt enhance the page but collapse to calm equivalents under reduced motion."
      }
    ]
  end
end
