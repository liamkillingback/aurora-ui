defmodule DemoWeb.Funnel do
  @moduledoc """
  The demo's **ethical, opt-in** conversion surface: a newsletter signup and a
  restrained premium CTA. Both are built from real Aurora UI components and
  follow the rules in `docs/privacy.md` and phase-09 evidence:

    * The source, docs, and component lab are never gated behind either of these.
    * The newsletter is explicit opt-in with double-opt-in messaging and clear
      one-click-unsubscribe / no-tracking copy.
    * The premium CTA is a quiet card whose copy never implies the free kit is
      incomplete, and its referral link carries a `?ref=aurora-ui&src=<page>` tag
      only — never any personal data.

  These are plain function components so any LiveView can render them. The
  newsletter form emits `phx-submit="subscribe"` / `phx-change="validate_email"`,
  which the hosting LiveView (`SubscribeLive`, `NimbusLive`) handles by calling
  `Demo.Newsletter`.
  """
  use DemoWeb, :html

  @doc """
  The opt-in newsletter signup, with an idle form state and a confirmed
  success state (double opt-in messaging). Renders inside a card so it sits
  comfortably in a footer or a dedicated page.
  """
  attr :source, :string, required: true, doc: "source tag stored with the lead, e.g. \"footer\""
  attr :email, :string, default: "", doc: "current email value (for re-render on error)"
  attr :error, :string, default: nil, doc: "validation error to show under the field"
  attr :state, :atom, default: :idle, values: [:idle, :subscribed], doc: "form vs. success"
  attr :confirmed_email, :string, default: nil, doc: "the address shown in the success state"
  attr :heading, :string, default: "Get the occasional build note"
  attr :rest, :global

  def newsletter_form(assigns) do
    ~H"""
    <section class="funnel-news" aria-label="Newsletter signup" {@rest}>
      <div :if={@state == :idle} class="funnel-news__idle">
        <div class="funnel-news__intro">
          <span class="funnel-news__eyebrow">
            <.icon name="hero-envelope" class="size-3.5" /> Newsletter · optional
          </span>
          <h2 class="funnel-news__title">{@heading}</h2>
          <p class="funnel-news__lede">
            A short, useful sequence — install help, theming, and accessible LiveView
            recipes. The kit is free and MIT-licensed either way; this is a bonus, never a gate.
          </p>
        </div>

        <form
          class="funnel-news__form"
          phx-submit="subscribe"
          phx-change="validate_email"
          novalidate
        >
          <input type="hidden" name="source" value={@source} />
          <.field
            :let={f}
            id={"news-email-#{@source}"}
            label="Email address"
            error={@error}
            help="Explicit opt-in. One-click unsubscribe in every email. No tracking."
            required
          >
            <.input
              {f}
              type="email"
              name="email"
              value={@email}
              autocomplete="email"
              placeholder="you@example.com"
              phx-debounce="300"
            >
              <:prefix><.icon name="hero-at-symbol" class="size-4" /></:prefix>
            </.input>
          </.field>

          <.button type="submit" variant="primary">
            Subscribe
            <:icon_end><.icon name="hero-arrow-right" class="size-4" /></:icon_end>
          </.button>
        </form>

        <p class="funnel-news__fine">
          We store only your email, a consent timestamp, and where you signed up. See the <.link_text navigate={
            ~p"/docs/privacy"
          }>privacy page</.link_text>.
        </p>
      </div>

      <div :if={@state == :subscribed} class="funnel-news__done">
        <.alert variant="success" title="Almost there — confirm your email">
          We sent a confirmation link to <strong>{@confirmed_email}</strong>. This is a <strong>double opt-in</strong>: you are only added after you click that link, and
          every email has a one-click unsubscribe. (This is a demo, so no real email is sent.)
        </.alert>
        <.button variant="ghost" phx-click="reset_newsletter">
          <:icon_start><.icon name="hero-arrow-uturn-left" class="size-4" /></:icon_start>
          Use a different address
        </.button>
      </div>
    </section>
    """
  end

  @doc """
  A restrained premium CTA — a quiet card, never a modal or a nag. Shown only at
  natural end points (the end of the example app / a complete recipe). Copy must
  not imply the free kit is limited; the referral link carries a tag only.
  """
  attr :src, :string, required: true, doc: "the `src=` referral tag, e.g. \"app\" or \"recipe\""
  attr :rest, :global

  def premium_cta(assigns) do
    assigns = assign(assigns, :href, "https://phxtemplates.com?ref=aurora-ui&src=#{assigns.src}")

    ~H"""
    <aside class="funnel-cta" aria-label="PHXTemplates" {@rest}>
      <div class="funnel-cta__body">
        <span class="funnel-cta__eyebrow">Built on this design language</span>
        <h2 class="funnel-cta__title">Want a full Phoenix product, not just the pieces?</h2>
        <p class="funnel-cta__lede">
          Aurora UI gives you every component you need to build this yourself. If you'd rather
          start from a finished, production-shaped app — auth, billing, teams — PHXTemplates
          ships commercial starters built on the same tokens and components.
        </p>
      </div>
      <div class="funnel-cta__action">
        <.button href={@href} variant="secondary" rel="noopener">
          Explore PHXTemplates
          <:icon_end><.icon name="hero-arrow-top-right-on-square" class="size-4" /></:icon_end>
        </.button>
        <span class="funnel-cta__note">Free kit stays free. No signup required.</span>
      </div>
    </aside>
    """
  end
end
