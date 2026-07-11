defmodule AuroraUI.Components.MediaTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias AuroraUI.Components.Media

  describe "media/1" do
    test "renders a figure with a reserved aspect-ratio frame" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.media ratio="16/9">
          <img src="/hero.jpg" alt="A hero" />
        </Media.media>
        """)

      assert html =~ "<figure"
      assert html =~ "aspect-ratio: 16/9;"
      assert html =~ ~s(alt="A hero")
    end

    test "renders a figcaption from the caption slot" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.media ratio="4/3">
          <img src="/x.jpg" alt="x" />
          <:caption>Opening day</:caption>
        </Media.media>
        """)

      assert html =~ "<figcaption"
      assert html =~ "Opening day"
    end

    test "ignores a malformed ratio value" do
      assigns = %{bad_ratio: "16/9; } evil"}

      html =
        rendered_to_string(~H"""
        <Media.media ratio={@bad_ratio}>
          <img src="/x.jpg" alt="x" />
        </Media.media>
        """)

      refute html =~ "evil"
      refute html =~ "aspect-ratio:"
    end
  end

  describe "gallery/1" do
    test "renders a semantic list grid" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.gallery label="Shots">
          <li>one</li>
          <li>two</li>
        </Media.gallery>
        """)

      assert html =~ ~s(role="list")
      assert html =~ ~s(aria-label="Shots")
      assert html =~ "--aui-gallery-min: 16rem;"
    end
  end

  describe "code_block/1" do
    test "renders pre/code with a language label" do
      html = render_component(&Media.code_block/1, code: "IO.puts(1)", language: "elixir")

      assert html =~ "<pre"
      assert html =~ "<code"
      assert html =~ "language-elixir"
      assert html =~ "elixir"
    end

    test "wires the copy button to the code element" do
      html = render_component(&Media.code_block/1, id: "snip", code: "x")

      assert html =~ ~s(phx-hook="AuroraCopyButton")
      assert html =~ ~s(data-aui-copy-target="#snip-source")
      assert html =~ ~s(id="snip-source")
      assert html =~ ~s(aria-label="Copy code")
    end

    test "escapes content and never injects raw HTML" do
      html = render_component(&Media.code_block/1, code: "<script>alert(1)</script>")

      assert html =~ "&lt;script&gt;"
      refute html =~ "<script>alert(1)</script>"
    end

    test "exposes a focusable, labelled scroll region" do
      html = render_component(&Media.code_block/1, code: "x", language: "js")

      assert html =~ ~s(role="region")
      assert html =~ ~s(tabindex="0")
    end
  end

  describe "prose/1" do
    test "wraps rich content in a measured container" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.prose>
          <h2>Title</h2>
          <p>Body</p>
        </Media.prose>
        """)

      assert html =~ "aui-prose"
      assert html =~ "<h2>Title</h2>"
    end
  end

  describe "callout/1" do
    test "renders an aside with the variant class" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.callout variant="warning" title="Heads up">
          Careful now
        </Media.callout>
        """)

      assert html =~ "<aside"
      assert html =~ "aui-callout--warning"
      assert html =~ "Careful now"
    end

    test "labels the aside with the title" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.callout id="c1" variant="danger" title="Stop">
          Do not proceed
        </Media.callout>
        """)

      assert html =~ ~s(aria-labelledby="c1-title")
      assert html =~ ~s(id="c1-title")
    end

    test "defaults to the note variant" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Media.callout title="Note">Body</Media.callout>
        """)

      assert html =~ "aui-callout--note"
    end
  end
end
