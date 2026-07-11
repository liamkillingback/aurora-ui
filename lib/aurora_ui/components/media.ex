defmodule AuroraUI.Components.Media do
  @moduledoc """
  Media family — aspect-ratio media, galleries, code blocks, prose, and callouts.

  These components carry the "content" surface: images/video that reserve space
  to avoid layout shift, a responsive gallery, a copyable code block, a readable
  prose container, and admonition callouts.

  ## Semantics & accessibility

    * `media/1` reserves space with `aspect-ratio` **before** the asset loads, so
      it never triggers Cumulative Layout Shift (CLS). Every `<img>` needs a
      meaningful `alt` (or `alt=""` when purely decorative) — the wrapper cannot
      invent one for you.
    * `code_block/1` escapes its content through normal HEEx interpolation and
      **never** renders raw HTML, so pasted code cannot inject markup.
    * `callout/1` is a real `<aside>` with a variant-appropriate icon.

  Light/dark, reduced-motion, forced-colors, RTL, and print are handled in the
  family stylesheet using tokens only.
  """
  use Phoenix.Component

  import AuroraUI.Internal

  @fits ~w(cover contain)
  @variants ~w(note tip warning danger)

  attr :ratio, :string,
    default: nil,
    doc: "aspect ratio like \"16/9\" or \"4/3\"; reserves space to prevent CLS"

  attr :fit, :string, default: "cover", values: @fits, doc: "object-fit for the media child"
  attr :rounded, :boolean, default: true
  attr :rest, :global

  slot :inner_block, required: true, doc: "the <img>/<video>/<picture> element"
  slot :caption, doc: "renders inside <figcaption>"

  @doc """
  An aspect-ratio media wrapper (a `<figure>`).

  Set `ratio` to reserve the box before the asset loads — the frame holds its
  height so surrounding content never jumps. Provide an accurate `alt` on the
  child image; the wrapper is presentational.

  ## Examples

      <.media ratio="16/9">
        <img src="/hero.jpg" alt="Team standing in the new office" />
        <:caption>Opening day, 2026.</:caption>
      </.media>
  """
  def media(assigns) do
    assigns =
      assign(assigns, :class, cx(["aui-media", {"aui-media--rounded", assigns.rounded}]))

    ~H"""
    <figure class={@class} data-aui="media" {@rest}>
      <div
        class={"aui-media__frame aui-media__frame--#{@fit}"}
        style={ratio_style(@ratio)}
      >
        {render_slot(@inner_block)}
      </div>
      <figcaption :if={@caption != []} class="aui-media__caption">{render_slot(@caption)}</figcaption>
    </figure>
    """
  end

  attr :label, :string, default: nil, doc: "accessible name for the gallery list"

  attr :min_item_width, :string,
    default: "16rem",
    doc: "minimum column width; the grid auto-fits as many columns as fit"

  attr :rest, :global

  slot :inner_block, required: true, doc: "gallery items — wrap each in an <li>"

  @doc """
  A responsive grid of media, keyboard-navigable through the natural tab order
  of the links/controls inside each item.

  Lightbox / zoom-to-fullscreen is intentionally **out of scope** — it needs
  focus-trapping overlay behavior that belongs to the overlay family; compose
  this gallery with a `dialog` if you need it.

  ## Examples

      <.gallery label="Product shots" min_item_width="14rem">
        <li :for={shot <- @shots}>
          <.media ratio="1/1"><img src={shot.url} alt={shot.alt} /></.media>
        </li>
      </.gallery>
  """
  def gallery(assigns) do
    ~H"""
    <ul
      role="list"
      class="aui-gallery"
      aria-label={@label}
      style={"--aui-gallery-min: #{@min_item_width};"}
      data-aui="gallery"
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  attr :id, :string, default: nil, doc: "stable id; the copy button targets the <code> element"
  attr :code, :string, required: true, doc: "raw source; escaped on render, never treated as HTML"

  attr :language, :string,
    default: nil,
    doc: "language label + `language-*` class for highlighters"

  attr :filename, :string,
    default: nil,
    doc: "optional filename shown in place of the language label"

  attr :show_copy, :boolean, default: true
  attr :rest, :global

  @doc """
  A `<pre><code>` block with a language label, a copy button, and a horizontally
  scrollable, keyboard-focusable content region.

  Content is interpolated with `{@code}`, so HEEx HTML-escapes it — there is no
  raw-HTML path and pasted markup cannot inject nodes. The block carries a stable
  `aui-code` class and a `language-*` class so a class-based syntax theme /
  highlighter can style tokens; the background comes from tokens
  (`--aui-surface-sunken`). Copy uses `phx-hook="AuroraCopyButton"` with
  `data-aui-copy-target` pointing at the `<code>` element.

  ## Examples

      <.code_block language="elixir" code={~s|IO.puts("hi")|} />
      <.code_block filename="mix.exs" code={@source} />
  """
  def code_block(assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || id(nil, "code"))
      |> then(fn a -> assign(a, :code_id, id(a.id, "source")) end)
      |> assign(:label, assigns.filename || assigns.language)

    ~H"""
    <figure id={@id} class="aui-code" data-aui="code" {@rest}>
      <figcaption class="aui-code__bar">
        <span class="aui-code__lang">{@label || "code"}</span>
        <button
          :if={@show_copy}
          type="button"
          class="aui-code__copy aui-focusable"
          phx-hook="AuroraCopyButton"
          id={id(@id, "copy")}
          data-aui-copy-target={"##{@code_id}"}
          aria-label="Copy code"
        >
          <span class="aui-code__copy-icon" aria-hidden="true"><.copy_icon /></span>
          <span class="aui-code__copy-label">Copy</span>
        </button>
      </figcaption>
      <div
        class="aui-code__scroll"
        tabindex="0"
        role="region"
        aria-label={"#{@label || "code"} snippet"}
      >
        <pre class="aui-code__pre"><code
          id={@code_id}
          class={@language && "language-#{@language}"}
        >{@code}</code></pre>
      </div>
    </figure>
    """
  end

  attr :rest, :global
  slot :inner_block, required: true

  @doc """
  A typographic container: constrains line length to a readable measure
  (`--aui-measure`) and applies consistent vertical rhythm to arbitrary rich
  content (headings, paragraphs, lists, tables, code). Style is scoped to the
  `.aui-prose` block so it never leaks into surrounding UI.

  ## Examples

      <.prose>
        <h2>Getting started</h2>
        <p>Install the library and import the stylesheet…</p>
      </.prose>
  """
  def prose(assigns) do
    ~H"""
    <div class="aui-prose" data-aui="prose" {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :variant, :string, default: "note", values: @variants
  attr :title, :string, default: nil, doc: "optional heading; becomes the aside's accessible name"
  attr :id, :string, default: nil
  attr :rest, :global

  slot :icon, doc: "overrides the default variant icon (decorative)"
  slot :inner_block, required: true

  @doc """
  An admonition/note box rendered as an `<aside>`.

  `variant` selects the tone and default icon: `note` (info), `tip` (success),
  `warning`, `danger`. Color comes from status tokens; the icon is decorative
  and the optional `title` labels the aside.

  ## Examples

      <.callout variant="warning" title="Heads up">
        This action cannot be undone.
      </.callout>
  """
  def callout(assigns) do
    assigns =
      assigns
      |> assign(:id, assigns.id || id(nil, "callout"))
      |> then(fn a -> assign(a, :title_id, id(a.id, "title")) end)

    ~H"""
    <aside
      id={@id}
      class={"aui-callout aui-callout--#{@variant}"}
      aria-labelledby={@title && @title_id}
      data-aui="callout"
      {@rest}
    >
      <span class="aui-callout__icon" aria-hidden="true">
        <%= if @icon != [] do %>
          {render_slot(@icon)}
        <% else %>
          <.callout_icon variant={@variant} />
        <% end %>
      </span>
      <div class="aui-callout__body">
        <p :if={@title} id={@title_id} class="aui-callout__title">{@title}</p>
        <div class="aui-callout__content">{render_slot(@inner_block)}</div>
      </div>
    </aside>
    """
  end

  # ── Internal ──────────────────────────────────────────────────────────────

  # Only emit aspect-ratio for a well-formed "N", "N/N", or "N.N/N" value so a
  # caller string can never break out of the style attribute.
  defp ratio_style(nil), do: nil

  defp ratio_style(ratio) when is_binary(ratio) do
    if Regex.match?(~r{^\s*\d+(\.\d+)?\s*(/\s*\d+(\.\d+)?\s*)?$}, ratio) do
      "aspect-ratio: #{String.trim(ratio)};"
    end
  end

  defp copy_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <rect x="7" y="7" width="9" height="9" rx="2" stroke="currentColor" stroke-width="1.5" />
      <path
        d="M13 7V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h2"
        stroke="currentColor"
        stroke-width="1.5"
      />
    </svg>
    """
  end

  defp callout_icon(%{variant: "tip"} = assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <path
        d="m4 10 4 4 8-8"
        stroke="currentColor"
        stroke-width="1.7"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
    """
  end

  defp callout_icon(%{variant: "warning"} = assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <path
        d="M10 2 1.5 17h17L10 2Z"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linejoin="round"
      />
      <path d="M10 8v4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" />
      <circle cx="10" cy="14.5" r="0.5" fill="currentColor" stroke="currentColor" />
    </svg>
    """
  end

  defp callout_icon(%{variant: "danger"} = assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <circle cx="10" cy="10" r="8" stroke="currentColor" stroke-width="1.5" />
      <path d="M10 6v5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" />
      <circle cx="10" cy="13.5" r="0.5" fill="currentColor" stroke="currentColor" />
    </svg>
    """
  end

  defp callout_icon(assigns) do
    ~H"""
    <svg viewBox="0 0 20 20" fill="none" width="1em" height="1em" aria-hidden="true" focusable="false">
      <circle cx="10" cy="10" r="8" stroke="currentColor" stroke-width="1.5" />
      <path d="M10 9v5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" />
      <circle cx="10" cy="6.5" r="0.5" fill="currentColor" stroke="currentColor" />
    </svg>
    """
  end
end
