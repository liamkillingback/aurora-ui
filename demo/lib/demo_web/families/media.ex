defmodule DemoWeb.Families.Media do
  @moduledoc """
  Component-lab stories for the Media family — aspect-ratio media, galleries,
  code blocks, prose, and callouts. Structure mirrors
  `DemoWeb.Families.Actions`.
  """
  use DemoWeb, :html

  @code %{
    media: ~S|<.media ratio="16/9">
  <img src={~p"/images/logo.svg"} alt="Aurora UI logo" />
  <:caption>The Aurora UI mark, framed at a 16/9 ratio.</:caption>
</.media>|,
    gallery: ~S|<.gallery label="Brand marks" min_item_width="12rem">
  <li :for={i <- 1..4}>
    <.media ratio="1/1">
      <img src={~p"/images/logo.svg"} alt={"Brand mark #{i}"} />
    </.media>
  </li>
</.gallery>|,
    code_block: ~S"""
    <.code_block
      language="elixir"
      filename="hello.ex"
      code={~s|defmodule Hello do
      def world, do: IO.puts("Hello, Aurora!")
    end|}
    />
    """,
    prose: ~S|<.prose>
  <h2>Getting started</h2>
  <p>
    Aurora UI is a set of accessible Phoenix LiveView components. Install the
    library, import the stylesheet, and start composing — every primitive is
    server-rendered first and enhanced progressively.
  </p>
  <ul>
    <li>Content-first and reduced-motion honest.</li>
    <li>Styled entirely from design tokens.</li>
  </ul>
</.prose>|,
    callouts: ~S|<.callout variant="note" title="Note">
  Search is server-rendered; JavaScript only enhances it.
</.callout>
<.callout variant="tip" title="Tip">
  Debounce live search between 120–300 ms for a responsive feel.
</.callout>
<.callout variant="warning" title="Heads up">
  Icon-only buttons still need an accessible label.
</.callout>
<.callout variant="danger" title="Destructive">
  This action cannot be undone.
</.callout>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Media"
        description="A figure that reserves its box with aspect-ratio before the asset loads, so content never jumps (no CLS)."
        code={@code.media}
      >
        <div style="width:100%;max-width:26rem;">
          <.media ratio="16/9">
            <img src={~p"/images/logo.svg"} alt="Aurora UI logo" />
            <:caption>The Aurora UI mark, framed at a 16/9 ratio.</:caption>
          </.media>
        </div>
      </.story>

      <.story
        title="Gallery"
        description="A responsive auto-fit grid of media, keyboard-navigable through each item's natural tab order."
        code={@code.gallery}
      >
        <.gallery label="Brand marks" min_item_width="12rem">
          <li :for={i <- 1..4}>
            <.media ratio="1/1">
              <img src={~p"/images/logo.svg"} alt={"Brand mark #{i}"} />
            </.media>
          </li>
        </.gallery>
      </.story>

      <.story
        title="Code block"
        description="A pre/code block with a language label and a copy button. Content is HTML-escaped on render — pasted markup can never inject nodes."
        code={@code.code_block}
      >
        <div style="width:100%;max-width:32rem;">
          <.code_block
            language="elixir"
            filename="hello.ex"
            code={~s|defmodule Hello do\n  def world, do: IO.puts("Hello, Aurora!")\nend|}
          />
        </div>
      </.story>

      <.story
        title="Prose"
        description="A typographic container that constrains line length to a readable measure and applies consistent vertical rhythm."
        code={@code.prose}
      >
        <.prose>
          <h2>Getting started</h2>
          <p>
            Aurora UI is a set of accessible Phoenix LiveView components. Install the
            library, import the stylesheet, and start composing — every primitive is
            server-rendered first and enhanced progressively.
          </p>
          <ul>
            <li>Content-first and reduced-motion honest.</li>
            <li>Styled entirely from design tokens.</li>
          </ul>
        </.prose>
      </.story>

      <.story
        title="Callouts"
        description="Admonition asides in four tones — note, tip, warning, danger — each with a variant-appropriate decorative icon."
        code={@code.callouts}
      >
        <div style="display:grid;gap:0.75rem;width:100%;max-width:34rem;">
          <.callout variant="note" title="Note">
            Search is server-rendered; JavaScript only enhances it.
          </.callout>
          <.callout variant="tip" title="Tip">
            Debounce live search between 120–300 ms for a responsive feel.
          </.callout>
          <.callout variant="warning" title="Heads up">
            Icon-only buttons still need an accessible label.
          </.callout>
          <.callout variant="danger" title="Destructive">
            This action cannot be undone.
          </.callout>
        </div>
      </.story>
    </div>
    """
  end
end
