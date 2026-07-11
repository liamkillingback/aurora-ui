defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoWeb do
    pipe_through :browser

    live "/", LandingLive, :index
    live "/docs/:page", DocsLive, :show
    live "/components", ComponentsLive, :index
    live "/components/:family", FamilyLive, :show

    # The immersive component-constellation.
    live "/lab", LabLive, :index

    # "Nimbus" — the small, coherent example application built from the kit.
    live "/app", NimbusLive, :index
    live "/app/new", NimbusLive, :new
    # Illustrative section links (used by the Navigation lab stories) resolve to
    # the dashboard so example nav is never a dead link.
    live "/app/:section", NimbusLive, :index

    # The ethical, opt-in newsletter funnel.
    live "/subscribe", SubscribeLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoWeb do
  #   pipe_through :api
  # end
end
