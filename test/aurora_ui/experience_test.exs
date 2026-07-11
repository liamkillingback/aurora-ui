defmodule AuroraUI.Components.ExperienceTest do
  use ExUnit.Case, async: true

  import Phoenix.Component, except: [slot: 2, slot: 1]
  import Phoenix.LiveViewTest

  alias AuroraUI.Components.Experience
  alias Phoenix.LiveView.JS

  # Build a slot entry usable directly by render_component. The inner_block may
  # be a 2-arity function returning renderable content (see call_inner_block!/3).
  defp slot(name, content) do
    [%{__slot__: name, inner_block: fn _changed, _arg -> content end}]
  end

  describe "reveal/1" do
    test "marks the hook target and stays visible (progressive enhancement)" do
      html =
        render_component(&Experience.reveal/1, %{
          inner_block: slot(:inner_block, "Revealed content")
        })

      # Content is in the server output — usable with no JS.
      assert html =~ "Revealed content"
      assert html =~ "data-aui-reveal"
      assert html =~ ~s(phx-hook="AuroraReveal")
      # A stable id is always present for the hook to target.
      assert html =~ ~s(id="aui-reveal-)
    end

    test "does not stagger by default" do
      html =
        render_component(&Experience.reveal/1, %{inner_block: slot(:inner_block, "x")})

      refute html =~ "data-aui-stagger"
    end

    test "stagger sets data-aui-stagger and `as` changes the tag" do
      html =
        render_component(&Experience.reveal/1, %{
          as: "section",
          stagger: true,
          inner_block: slot(:inner_block, "x")
        })

      assert html =~ "<section"
      assert html =~ "data-aui-stagger"
    end

    test "honors a caller-supplied id" do
      html =
        render_component(&Experience.reveal/1, %{
          id: "hero",
          inner_block: slot(:inner_block, "x")
        })

      assert html =~ ~s(id="hero-reveal")
    end
  end

  describe "stagger/1" do
    test "reveals and staggers children via the reveal hook" do
      html =
        render_component(&Experience.stagger/1, %{
          inner_block: slot(:inner_block, "Card")
        })

      assert html =~ "Card"
      assert html =~ ~s(phx-hook="AuroraReveal")
      assert html =~ "data-aui-reveal"
      assert html =~ "data-aui-stagger"
    end
  end

  describe "spotlight/1" do
    test "renders the spotlight surface with its hook" do
      html =
        render_component(&Experience.spotlight/1, %{
          inner_block: slot(:inner_block, "Hover me")
        })

      assert html =~ "Hover me"
      assert html =~ "aui-spotlight"
      assert html =~ ~s(phx-hook="AuroraSpotlight")
    end
  end

  describe "tilt/1" do
    test "renders the lazy tilt hook with the max angle" do
      html =
        render_component(&Experience.tilt/1, %{
          max_deg: 6,
          inner_block: slot(:inner_block, "Feature")
        })

      assert html =~ "Feature"
      assert html =~ "aui-tilt"
      assert html =~ ~s(phx-hook="AuroraTilt")
      assert html =~ ~s(data-aui-max-deg="6")
      assert html =~ "--aui-tilt-max: 6deg"
    end
  end

  describe "scene_host/1" do
    test "renders BOTH the fallback and the semantic content server-side" do
      html =
        render_component(&Experience.scene_host/1, %{
          scene: "aurora-globe",
          fallback: slot(:fallback, "STATIC POSTER"),
          semantic: slot(:semantic, "34 regions worldwide")
        })

      # No-JS / no-WebGL usability: the static fallback is present...
      assert html =~ "STATIC POSTER"
      assert html =~ "aui-scene__fallback"
      # ...and so is the real, assistive-tech-readable information.
      assert html =~ "34 regions worldwide"
      assert html =~ "aui-scene__semantic"
    end

    test "wires the lazy scene hook and its configuration" do
      html =
        render_component(&Experience.scene_host/1, %{
          scene: "aurora-globe",
          dpr_cap: 1.75,
          pause_offscreen: true,
          fallback: slot(:fallback, "poster"),
          semantic: slot(:semantic, "info")
        })

      assert html =~ ~s(phx-hook="AuroraSceneHost")
      assert html =~ ~s(data-aui-scene="aurora-globe")
      assert html =~ ~s(data-aui-dpr-cap="1.75")
      assert html =~ "data-aui-pause-offscreen"
      assert html =~ "aui-scene__stage"
    end
  end

  describe "transition helpers" do
    test "each returns a %Phoenix.LiveView.JS{} struct" do
      assert %JS{} = Experience.fade_in()
      assert %JS{} = Experience.slide_up()
      assert %JS{} = Experience.scale_in()
    end

    test "accept an existing JS struct and options and stay chainable" do
      assert %JS{} = Experience.fade_in(%JS{}, to: "#hero", time: 300)
      assert %JS{} = %JS{} |> Experience.slide_up() |> Experience.scale_in()
    end

    test "carry the family's animation classes" do
      # The applied classes drive the keyframes defined in motion.css.
      assert inspect(Experience.fade_in()) =~ "aui-anim--fade-in"
      assert inspect(Experience.slide_up()) =~ "aui-anim--slide-up"
      assert inspect(Experience.scale_in()) =~ "aui-anim--scale-in"
    end
  end
end
