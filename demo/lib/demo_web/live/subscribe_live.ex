defmodule DemoWeb.SubscribeLive do
  @moduledoc """
  The dedicated newsletter page (`/subscribe`). A single, honest opt-in form
  backed by `Demo.Newsletter` — validates the email, stores the minimal
  `{email, consent_at, source}` lead, and shows a double-opt-in confirmation
  state. Nothing here gates the free kit; it is linked, never interrupting.
  """
  use DemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Subscribe")
     |> assign(
       :page_description,
       "Opt in to the Aurora UI newsletter: install help, theming, and accessible LiveView recipes. Explicit opt-in, one-click unsubscribe, no tracking."
     )
     |> assign(:nav_active, "subscribe")
     |> reset_form()}
  end

  @impl true
  def handle_event("validate_email", %{"email" => email}, socket) do
    {:noreply, assign(socket, email: email, error: live_error(email))}
  end

  def handle_event("subscribe", %{"email" => email} = params, socket) do
    source = Map.get(params, "source", "subscribe")

    case Demo.Newsletter.subscribe(%{email: email, source: source}) do
      {:ok, subscriber} ->
        {:noreply,
         socket
         |> assign(:state, :subscribed)
         |> assign(:confirmed_email, subscriber.email)}

      {:error, :invalid_email} ->
        {:noreply, assign(socket, email: email, error: "Enter a valid email address.")}

      {:error, :suppressed} ->
        {:noreply,
         socket
         |> assign(email: email)
         |> assign(
           :error,
           "This address previously unsubscribed and won't be re-added automatically."
         )}
    end
  end

  def handle_event("reset_newsletter", _params, socket) do
    {:noreply, reset_form(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} nav_active={@nav_active}>
      <div class="demo-page">
        <div class="demo-pagehead">
          <span class="demo-pagehead__eyebrow">Newsletter</span>
          <h1 class="demo-pagehead__title">Stay in the loop, on your terms</h1>
          <p class="demo-pagehead__lede">
            An opt-in sequence that helps first and sells last. The source is free regardless —
            this is a bonus you can leave any time.
          </p>
        </div>

        <div class="funnel-subscribe">
          <.card elevation="sm">
            <DemoWeb.Funnel.newsletter_form
              source="subscribe"
              email={@email}
              error={@error}
              state={@state}
              confirmed_email={@confirmed_email}
            />
          </.card>

          <.card elevation="flat">
            <:header>
              <div class="funnel-subscribe__promise-head">
                <.icon name="hero-shield-check" class="size-5" />
                <strong>What you're agreeing to</strong>
              </div>
            </:header>
            <.description_list>
              <:item term="Consent">Explicit opt-in. We store a consent timestamp as proof.</:item>
              <:item term="Confirmation">
                Double opt-in — you confirm via a link before you're added.
              </:item>
              <:item term="Unsubscribe">
                One click, in every email. Then you're suppressed, not re-added.
              </:item>
              <:item term="Data stored">
                Only your email, consent time, and signup source. No tracking.
              </:item>
            </.description_list>
          </.card>
        </div>
      </div>
    </Layouts.app>
    """
  end

  # Only surface a validation hint once the user has typed something plausible;
  # never nag an empty field mid-typing.
  defp live_error(""), do: nil

  defp live_error(email) do
    if Demo.Newsletter.valid_email?(email), do: nil, else: "That doesn't look like an email yet."
  end

  defp reset_form(socket) do
    socket
    |> assign(:state, :idle)
    |> assign(:email, "")
    |> assign(:error, nil)
    |> assign(:confirmed_email, nil)
  end
end
