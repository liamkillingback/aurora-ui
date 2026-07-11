defmodule AuroraUI.Components.Experience do
  @moduledoc """
  Experience family — the kit's signature motion and 3D primitives.

  These components add delight (scroll reveals, pointer spotlights, subtle tilt,
  and full Three.js scenes) while treating JavaScript, WebGL, and animation as
  **enhancements layered on top of usable server-rendered HTML**. Every primitive
  here obeys three rules:

    * **Content-first.** The meaningful content renders and is fully usable
      server-side. `reveal/1` content is visible without JS; `scene_host/1`
      ships a designed static fallback *and* real semantic HTML.
    * **Reduced-motion honest.** All large translate/scale motion collapses to a
      plain state change under `prefers-reduced-motion: reduce` (see
      `assets/css/components/motion.css` and this family's CSS).
    * **Pay-for-what-you-render.** The heavy behaviors are code-split: `tilt/1`
      dynamic-imports `./motion.js` and `scene_host/1` dynamic-imports
      `./three/scene.js`, so a page that never renders them never loads them.

  ## Progressive enhancement contract

  The CSS hidden/animated states are gated on `[data-aui-hook="ready"]`, which a
  hook only sets once it has successfully claimed an element and confirmed motion
  is allowed. Consequently, with JS disabled — or before hydration — reveal
  content stays visible and scenes show their static fallback. Nothing important
  is ever hidden behind a script that might not run.

  ## DOM / hook contract

  | Component | `phx-hook` | Key attributes |
  |---|---|---|
  | `reveal/1` | `AuroraReveal` | `data-aui-reveal`, optional `data-aui-stagger` |
  | `stagger/1` | `AuroraReveal` | `data-aui-reveal`, `data-aui-stagger` |
  | `spotlight/1` | `AuroraSpotlight` | `.aui-spotlight`, publishes `--aui-mx/--aui-my`, toggles `data-aui-spot-active` |
  | `tilt/1` | `AuroraTilt` (lazy) | `.aui-tilt`, `data-aui-max-deg` |
  | `scene_host/1` | `AuroraSceneHost` (lazy) | `.aui-scene`, `data-aui-scene`, `data-aui-dpr-cap`, `data-aui-pause-offscreen` |
  """
  use Phoenix.Component

  import AuroraUI.Internal

  alias Phoenix.LiveView.JS

  attr :id, :string,
    default: nil,
    doc: "stable id for the hook target; generated deterministically when omitted"

  attr :as, :string, default: "div", doc: "wrapper element tag, e.g. `\"section\"` or `\"li\"`"

  attr :stagger, :boolean,
    default: false,
    doc: "when true, sets `data-aui-stagger` so direct children reveal in sequence"

  attr :rest, :global

  slot :inner_block, required: true

  @doc """
  Wraps content that animates into view on scroll.

  Sets `data-aui-reveal` and `phx-hook="AuroraReveal"` on a stable id. This is
  **progressive enhancement**: without JS (or before the hook is ready) the
  content is fully visible — the hidden/animated state in `motion.css` only
  applies once the hook marks itself `data-aui-hook="ready"`. Under
  `prefers-reduced-motion` the reveal collapses to a plain fade with no travel.

  Use `stagger` to have the element's own direct children reveal in sequence
  (the hook assigns each child a `--aui-i` index). For a dedicated staggering
  container, prefer `stagger/1`.

  ## Examples

      <.reveal>
        <h2>Built for teams</h2>
        <p>Everything renders server-side first.</p>
      </.reveal>

      <.reveal as="ul" stagger>
        <li>Fast</li>
        <li>Accessible</li>
        <li>Removable</li>
      </.reveal>
  """
  def reveal(assigns) do
    assigns = assign(assigns, :id, id(assigns.id, "reveal"))

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      id={@id}
      phx-hook="AuroraReveal"
      data-aui-reveal
      data-aui-stagger={@stagger}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  attr :id, :string, default: nil
  attr :as, :string, default: "div", doc: "wrapper element tag"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A container that reveals and staggers its direct children on scroll.

  Sets `data-aui-reveal` + `data-aui-stagger` and uses the `AuroraReveal` hook,
  which hands each child a `--aui-i` index so `motion.css` can offset each
  child's transition by `--aui-stagger`. Like `reveal/1`, children are visible
  without JS and the stagger collapses to `0ms` under reduced motion.

  ## Examples

      <.stagger as="ul" class="cards">
        <li :for={card <- @cards}>{card.title}</li>
      </.stagger>
  """
  def stagger(assigns) do
    assigns = assign(assigns, :id, id(assigns.id, "stagger"))

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      id={@id}
      phx-hook="AuroraReveal"
      data-aui-reveal
      data-aui-stagger
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  attr :id, :string, default: nil
  attr :as, :string, default: "div", doc: "wrapper element tag"
  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A surface that shows a soft radial glow following the pointer.

  Renders `.aui-spotlight` (styled in `motion.css`) with the `AuroraSpotlight`
  hook, which publishes the pointer position as `--aui-mx/--aui-my` and toggles
  `data-aui-spot-active` while the pointer is over the surface. The glow is
  purely decorative: it sits behind content, never intercepts pointer events,
  and is disabled entirely under `prefers-reduced-motion`. Keyboard and touch
  users lose nothing — no content or interaction depends on the pointer.

  ## Examples

      <.spotlight class="card">
        <h3>Hover me</h3>
        <p>The glow tracks your cursor.</p>
      </.spotlight>
  """
  def spotlight(assigns) do
    assigns = assign(assigns, :id, id(assigns.id, "spotlight"))

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      id={@id}
      class="aui-spotlight"
      phx-hook="AuroraSpotlight"
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  attr :id, :string, default: nil
  attr :as, :string, default: "div", doc: "wrapper element tag"

  attr :max_deg, :integer,
    default: 8,
    doc: "maximum tilt angle in degrees; keep it small — tilt is feedback, not spectacle"

  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  Adds a subtle 3D tilt toward the pointer on hover.

  Uses the **lazy** `AuroraTilt` hook, which dynamic-imports `./motion.js` on
  mount so the tilt math never enters a bundle for a page that does not render
  it. The effect is deliberately restrained (`max_deg` defaults to a small
  angle) and is only ever additive feedback — the content and any interactions
  inside are fully usable without it.

  Touch and keyboard users get no tilt (only pointer hover drives it) but the
  full content. Tilt can be switched off wholesale for a subtree by setting
  `data-aui-tilt="off"` on any ancestor (respected by both the hook and the CSS),
  which is useful for user "reduce effects" preferences. It is also disabled
  under `prefers-reduced-motion`.

  ## Examples

      <.tilt class="feature-card" max_deg={6}>
        <img src="/images/preview.png" alt="Dashboard preview" />
      </.tilt>
  """
  def tilt(assigns) do
    assigns = assign(assigns, :id, id(assigns.id, "tilt"))

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      id={@id}
      class="aui-tilt"
      phx-hook="AuroraTilt"
      data-aui-max-deg={@max_deg}
      style={"--aui-tilt-max: #{@max_deg}deg;"}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  attr :id, :string, default: nil

  attr :scene, :string,
    required: true,
    doc: "name of the scene to load; passed to the hook as `data-aui-scene`"

  attr :dpr_cap, :float,
    default: 2.0,
    doc: "upper bound on device-pixel-ratio the renderer will use, to cap GPU cost"

  attr :pause_offscreen, :boolean,
    default: true,
    doc: "pause rendering (via IntersectionObserver) while the scene is off-screen"

  attr :rest, :global

  slot :fallback,
    required: true,
    doc: """
    An intentionally-designed static / reduced-motion experience (poster image,
    CSS gradient art, SVG) — **not** a blank box. Rendered server-side and only
    faded out once the WebGL scene successfully initializes.
    """

  slot :semantic,
    required: true,
    doc: """
    Real HTML that conveys the same information as the scene, for assistive
    technology, no-JS, and no-WebGL users. Always present in the DOM.
    """

  @doc """
  Hosts a Three.js scene with first-class non-WebGL and reduced-motion paths.

  Uses the **lazy** `AuroraSceneHost` hook, which dynamic-imports
  `./three/scene.js` on mount so Three.js never ships to pages that don't render
  a scene. The server output always contains two real layers:

    * the `fallback` slot — a designed static experience shown immediately and
      kept until (and unless) the scene initializes, and
    * the `semantic` slot — HTML content conveying the same information, which
      stays in the DOM for assistive technology, no-JS, and no-WebGL users.

  The hook (documented here as the contract it implements):

    * **Capability selection** — checks for a WebGL context and honors
      `prefers-reduced-motion`; if either fails it leaves the static fallback in
      place and never boots Three.js.
    * **Pause** — with `pause_offscreen` (default `true`) an IntersectionObserver
      stops the render loop while the host is off-screen, and it also pauses on
      `document.hidden`.
    * **Resize** — a ResizeObserver keeps the drawing buffer matched to the host,
      clamped to `dpr_cap`.
    * **Context recovery** — listens for `webglcontextlost`/`restored`, cancelling
      the loop and rebuilding on restore; a permanent loss reveals the fallback.
    * **Disposal** — `destroyed()` cancels the RAF loop, disconnects observers,
      and disposes geometries, materials, textures, and the renderer.

  Only after a successful init does the hook set `data-aui-scene-ready`, which
  fades the fallback out via CSS.

  ## Examples

      <.scene_host scene="aurora-globe" dpr_cap={1.75}>
        <:fallback>
          <img src="/images/globe-poster.avif" alt="" />
        </:fallback>
        <:semantic>
          <h2>Global edge network</h2>
          <p>Requests are served from 34 regions worldwide.</p>
        </:semantic>
      </.scene_host>
  """
  def scene_host(assigns) do
    assigns = assign(assigns, :id, id(assigns.id, "scene"))

    ~H"""
    <div
      id={@id}
      class="aui-scene"
      phx-hook="AuroraSceneHost"
      data-aui-scene={@scene}
      data-aui-dpr-cap={@dpr_cap}
      data-aui-pause-offscreen={@pause_offscreen}
      {@rest}
    >
      <div class="aui-scene__stage" data-aui-scene-stage aria-hidden="true">
        <div class="aui-scene__fallback" data-aui-scene-fallback>
          {render_slot(@fallback)}
        </div>
      </div>
      <div class="aui-scene__semantic">
        {render_slot(@semantic)}
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Transition helpers
  #
  # Small functions returning `Phoenix.LiveView.JS` structs for the kit's named
  # enter transitions. Attach them to `phx-mounted` (or any JS command) so
  # consumers get consistent motion without hand-rolling class choreography:
  #
  #     <div phx-mounted={AuroraUI.Components.Experience.slide_up()}>…</div>
  #
  # Each applies an `.aui-anim*` class (see this family's CSS) that drives a
  # keyframe defined in `motion.css`. Reduced motion is handled entirely in CSS:
  # the `prefers-reduced-motion: reduce` block caps the animation duration and
  # drops travel to a plain fade, so these helpers need no runtime branching.
  # ---------------------------------------------------------------------------

  @doc """
  Returns a `%Phoenix.LiveView.JS{}` that fades an element in.

  ## Options

    * `:to` — a selector to target instead of the bound element.
    * `:time` — how long (ms) the animation class stays applied. Defaults to 200.

  ## Examples

      <div phx-mounted={Experience.fade_in()}>…</div>
  """
  def fade_in(js \\ %JS{}, opts \\ []), do: animate(js, "aui-anim aui-anim--fade-in", opts)

  @doc """
  Returns a `%Phoenix.LiveView.JS{}` that slides an element up while fading in.
  See `fade_in/2` for options. Collapses to a plain fade under reduced motion.
  """
  def slide_up(js \\ %JS{}, opts \\ []), do: animate(js, "aui-anim aui-anim--slide-up", opts)

  @doc """
  Returns a `%Phoenix.LiveView.JS{}` that scales an element in while fading.
  See `fade_in/2` for options. Collapses to a plain fade under reduced motion.
  """
  def scale_in(js \\ %JS{}, opts \\ []), do: animate(js, "aui-anim aui-anim--scale-in", opts)

  defp animate(js, classes, opts) do
    JS.transition(js, classes, to: Keyword.get(opts, :to), time: Keyword.get(opts, :time, 200))
  end
end
