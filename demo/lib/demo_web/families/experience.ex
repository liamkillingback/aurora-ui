defmodule DemoWeb.Families.Experience do
  @moduledoc """
  Component-lab stories for the Experience family — scroll reveals, pointer
  spotlight, tilt, and the Three.js scene host. Structure mirrors
  `DemoWeb.Families.Actions`.

  Every preview here is progressive enhancement: the content renders and is
  fully usable server-side, and all large motion collapses to a plain state
  change under `prefers-reduced-motion`.
  """
  use DemoWeb, :html

  @code %{
    reveal: ~S|<.reveal>
  <h3>Built for teams</h3>
  <p>Everything renders server-side first, then animates into view.</p>
</.reveal>|,
    stagger: ~S|<.stagger as="ul" class="demo-exp-cards">
  <li :for={card <- ["Fast", "Accessible", "Removable"]}>{card}</li>
</.stagger>|,
    spotlight: ~S|<.spotlight class="demo-exp-card">
  <h3>Hover me</h3>
  <p>A soft radial glow tracks your pointer. It is purely decorative.</p>
</.spotlight>|,
    tilt: ~S|<.tilt class="demo-exp-card" max_deg={8}>
  <h3>Tilt</h3>
  <p>Subtle 3D tilt toward the pointer — feedback, not spectacle.</p>
</.tilt>|,
    scene: ~S|<.scene_host scene="aurora-globe" dpr_cap={1.75}>
  <:fallback>
    <div class="demo-exp-poster" aria-hidden="true"></div>
  </:fallback>
  <:semantic>
    <h3>Global edge network</h3>
    <p>Requests are served from 34 regions worldwide.</p>
  </:semantic>
</.scene_host>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <style>
      .demo-exp-card {
        display: block;
        padding: 1.25rem 1.5rem;
        border-radius: 0.9rem;
        border: 1px solid rgb(var(--aui-border));
        background: rgb(var(--aui-surface));
        color: rgb(var(--aui-text));
        max-width: 22rem;
      }
      .demo-exp-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(9rem, 1fr));
        gap: 0.75rem;
        list-style: none;
        margin: 0;
        padding: 0;
        width: 100%;
      }
      .demo-exp-cards > li {
        padding: 1rem 1.1rem;
        border-radius: 0.75rem;
        border: 1px solid rgb(var(--aui-border));
        background: rgb(var(--aui-surface));
        color: rgb(var(--aui-text));
        text-align: center;
        font-weight: 600;
      }
      .demo-exp-poster {
        width: 100%;
        height: 100%;
        min-height: 12rem;
        border-radius: 0.9rem;
        background:
          radial-gradient(120% 120% at 30% 20%, rgb(var(--aui-accent) / 0.55), transparent 60%),
          radial-gradient(120% 120% at 80% 90%, rgb(var(--aui-accent-2, var(--aui-accent)) / 0.4), transparent 55%),
          rgb(var(--aui-surface-sunken));
      }
    </style>

    <div class="demo-stories">
      <.story
        title="Reveal"
        description="Wraps content that animates into view on scroll. Without JS (or before the hook is ready) the content is fully visible — nothing hides behind a script."
        code={@code.reveal}
      >
        <.reveal class="demo-exp-card">
          <h3>Built for teams</h3>
          <p>Everything renders server-side first, then animates into view.</p>
        </.reveal>
      </.story>

      <.story
        title="Stagger"
        description="A container whose direct children reveal in sequence. The stagger collapses to 0ms under reduced motion."
        code={@code.stagger}
      >
        <.stagger as="ul" class="demo-exp-cards">
          <li :for={card <- ["Fast", "Accessible", "Removable"]}>{card}</li>
        </.stagger>
      </.story>

      <.story
        title="Spotlight"
        description="A surface showing a soft radial glow that follows the pointer. Decorative only — it never intercepts pointer events and is off under reduced motion."
        code={@code.spotlight}
      >
        <.spotlight class="demo-exp-card">
          <h3>Hover me</h3>
          <p>A soft radial glow tracks your pointer. It is purely decorative.</p>
        </.spotlight>
      </.story>

      <.story
        title="Tilt"
        description="Adds a subtle 3D tilt toward the pointer on hover. The tilt math is lazy-loaded, so a page that never renders it never pays for it."
        code={@code.tilt}
      >
        <.tilt class="demo-exp-card" max_deg={8}>
          <h3>Tilt</h3>
          <p>Subtle 3D tilt toward the pointer — feedback, not spectacle.</p>
        </.tilt>
      </.story>

      <.story
        title="Scene host"
        description="Hosts a Three.js scene with a designed static fallback and real semantic HTML. Reduced-motion or no-WebGL users keep the fallback; the scene itself loads lazily client-side."
        code={@code.scene}
        preview_class="demo-exp-scene"
      >
        <div style="width:100%;max-width:32rem;">
          <.scene_host scene="aurora-globe" dpr_cap={1.75}>
            <:fallback>
              <div class="demo-exp-poster" aria-hidden="true"></div>
            </:fallback>
            <:semantic>
              <h3 style="margin:0 0 0.25rem;">Global edge network</h3>
              <p style="margin:0;color:rgb(var(--aui-text-muted));">
                Requests are served from 34 regions worldwide.
              </p>
            </:semantic>
          </.scene_host>
        </div>
      </.story>
    </div>
    """
  end
end
