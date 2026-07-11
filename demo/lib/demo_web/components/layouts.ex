defmodule DemoWeb.Layouts do
  @moduledoc """
  App-shell layout for the Aurora UI docs site.

  `app/1` renders the persistent chrome every page shares: a top bar (brand,
  search, and the global theme / motion / viewport controls) and a left
  component-nav grouped by the 15 families and the docs pages. The global
  controls are wired by a colocated `.AuroraDocsShell` hook that reflects and
  persists user choices onto `<html>` — the library reads `data-aui-theme`, the
  demo CSS reads `data-motion`, and lab pages read `data-viewport`.
  """
  use DemoWeb, :html

  embed_templates "layouts/*"

  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :nav_active, :string,
    default: nil,
    doc: "the active nav key: a family slug, a docs slug, \"home\", or \"components\""

  slot :toolbar, doc: "page-scoped controls shown in the top bar (e.g. viewport buttons)"
  slot :inner_block, required: true

  @doc """
  Renders the docs app shell around `inner_block`.

      <Layouts.app flash={@flash} nav_active="actions">
        …page…
      </Layouts.app>
  """
  def app(assigns) do
    ~H"""
    <div id="demo-shell" class="demo-shell" phx-hook=".AuroraDocsShell">
      <a href="#main" class="demo-skip aui-focusable">Skip to content</a>

      <header class="demo-topbar">
        <.link navigate={~p"/"} class="demo-brand aui-focusable">
          <span class="demo-brand__mark" aria-hidden="true"></span>
          <span class="demo-brand__name">Aurora UI</span>
        </.link>

        <div class="demo-search" role="search">
          <.icon name="hero-magnifying-glass" class="demo-search__icon" />
          <input
            type="search"
            name="q"
            class="demo-search__input"
            placeholder="Search components…"
            aria-label="Search components"
            autocomplete="off"
          />
          <kbd class="demo-search__kbd" aria-hidden="true">/</kbd>
        </div>

        <div class="demo-controls">
          {render_slot(@toolbar)}

          <div class="demo-seg" role="group" aria-label="Color theme">
            <button
              type="button"
              class="demo-seg__btn aui-focusable"
              data-theme-btn="system"
              aria-label="Match system theme"
              phx-click={JS.dispatch("aui:theme", detail: %{value: "system"})}
            >
              <.icon name="hero-computer-desktop" class="size-4" />
            </button>
            <button
              type="button"
              class="demo-seg__btn aui-focusable"
              data-theme-btn="light"
              aria-label="Light theme"
              phx-click={JS.dispatch("aui:theme", detail: %{value: "light"})}
            >
              <.icon name="hero-sun" class="size-4" />
            </button>
            <button
              type="button"
              class="demo-seg__btn aui-focusable"
              data-theme-btn="dark"
              aria-label="Dark theme"
              phx-click={JS.dispatch("aui:theme", detail: %{value: "dark"})}
            >
              <.icon name="hero-moon" class="size-4" />
            </button>
          </div>

          <button
            type="button"
            class="demo-toggle aui-focusable"
            data-motion-btn
            aria-label="Toggle reduced motion"
            title="Toggle reduced motion"
            phx-click={JS.dispatch("aui:motion")}
          >
            <.icon name="hero-bolt" class="size-4" />
          </button>

          <a
            href="https://github.com/liamkillingback/aurora-ui"
            class="demo-toggle aui-focusable"
            aria-label="Aurora UI on GitHub"
            title="GitHub"
          >
            <.icon name="hero-code-bracket" class="size-4" />
          </a>
        </div>
      </header>

      <div class="demo-body">
        <nav class="demo-sidebar" aria-label="Documentation">
          <div class="demo-navgroup">
            <span class="demo-navgroup__label">Overview</span>
            <ul class="demo-navlist">
              <li>
                <.link navigate={~p"/"} class={demo_navlink(@nav_active == "home")}>
                  Home
                </.link>
              </li>
              <li>
                <.link
                  navigate={~p"/components"}
                  class={demo_navlink(@nav_active == "components")}
                >
                  All components
                </.link>
              </li>
              <li>
                <.link navigate={~p"/lab"} class={demo_navlink(@nav_active == "lab")}>
                  The Lab
                </.link>
              </li>
              <li>
                <.link navigate={~p"/app"} class={demo_navlink(@nav_active == "app")}>
                  Example app
                </.link>
              </li>
              <li>
                <.link navigate={~p"/subscribe"} class={demo_navlink(@nav_active == "subscribe")}>
                  Subscribe
                </.link>
              </li>
            </ul>
          </div>

          <div class="demo-navgroup">
            <span class="demo-navgroup__label">Documentation</span>
            <ul class="demo-navlist">
              <li :for={page <- Nav.doc_pages()}>
                <.link
                  navigate={~p"/docs/#{page.slug}"}
                  class={demo_navlink(@nav_active == page.slug)}
                >
                  {page.title}
                </.link>
              </li>
            </ul>
          </div>

          <div class="demo-navgroup">
            <span class="demo-navgroup__label">Components</span>
            <ul class="demo-navlist">
              <li :for={family <- Nav.families()}>
                <.link
                  navigate={~p"/components/#{family.slug}"}
                  class={demo_navlink(@nav_active == family.slug)}
                  aria-current={@nav_active == family.slug && "page"}
                >
                  {family.name}
                </.link>
              </li>
            </ul>
          </div>
        </nav>

        <main id="main" class="demo-main">
          {render_slot(@inner_block)}
        </main>
      </div>

      <footer class="demo-footer">
        <div class="demo-footer__inner">
          <div class="demo-footer__col">
            <span class="demo-footer__brand">Aurora UI</span>
            <p class="demo-footer__note">
              Free, MIT-licensed Phoenix LiveView components. The source is never gated.
            </p>
          </div>
          <nav class="demo-footer__links" aria-label="Footer">
            <.link navigate={~p"/subscribe"} class="demo-footer__link aui-focusable">
              <.icon name="hero-envelope" class="size-4" /> Newsletter (opt-in)
            </.link>
            <.link navigate={~p"/docs/privacy"} class="demo-footer__link aui-focusable">
              Privacy
            </.link>
            <a
              href="https://phxtemplates.com?ref=aurora-ui&src=docs-footer"
              class="demo-footer__link aui-focusable"
              rel="noopener"
            >
              PHXTemplates <.icon name="hero-arrow-top-right-on-square" class="size-3.5" />
            </a>
          </nav>
        </div>
      </footer>

      <.flash_group flash={@flash} />
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".AuroraDocsShell">
      export default {
        mounted() {
          this.root = document.documentElement
          this.onTheme = (e) => this.setTheme(e.detail && e.detail.value)
          this.onMotion = () => this.toggleMotion()
          window.addEventListener("aui:theme", this.onTheme)
          window.addEventListener("aui:motion", this.onMotion)
          this.sync()
        },
        updated() { this.sync() },
        destroyed() {
          window.removeEventListener("aui:theme", this.onTheme)
          window.removeEventListener("aui:motion", this.onMotion)
        },
        setTheme(value) {
          if (value === "system") {
            this.root.removeAttribute("data-aui-theme")
            localStorage.setItem("aui-theme", "system")
          } else if (value) {
            this.root.setAttribute("data-aui-theme", value)
            localStorage.setItem("aui-theme", value)
          }
          this.sync()
        },
        toggleMotion() {
          const reduced = this.root.getAttribute("data-motion") === "reduce"
          if (reduced) {
            this.root.removeAttribute("data-motion")
            localStorage.removeItem("aui-motion")
          } else {
            this.root.setAttribute("data-motion", "reduce")
            localStorage.setItem("aui-motion", "reduce")
          }
          this.sync()
        },
        sync() {
          const theme = this.root.getAttribute("data-aui-theme") || "system"
          this.el.querySelectorAll("[data-theme-btn]").forEach((b) => {
            b.setAttribute("aria-pressed", String(b.dataset.themeBtn === theme))
          })
          const reduced = this.root.getAttribute("data-motion") === "reduce"
          this.el.querySelectorAll("[data-motion-btn]").forEach((b) => {
            b.setAttribute("aria-pressed", String(reduced))
          })
        }
      }
    </script>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  # Classes for a sidebar nav link, with an active variant.
  defp demo_navlink(active?) do
    ["demo-navlink", "aui-focusable", active? && "demo-navlink--active"]
  end
end
