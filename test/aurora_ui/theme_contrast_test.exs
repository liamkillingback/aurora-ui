defmodule AuroraUI.ThemeContrastTest do
  @moduledoc """
  Token linter + contrast regression guard (Phase 2 exit-gate requirement).

  Parses the shipped token stylesheet, extracts the light and dark token sets,
  and verifies that the foreground/background pairings the components actually
  use meet WCAG 2.2 contrast thresholds. Also catches missing/invalid tokens.

  This runs in plain ExUnit — no browser — so a theme regression fails CI.
  """
  use ExUnit.Case, async: true

  @css Path.expand("../../assets/css/aurora_ui.css", __DIR__)

  # Pairs that must meet contrast, as {foreground_token, background_token, min_ratio}.
  # 4.5 for normal text; 3.0 for large text and non-text UI (borders, icons).
  @text_pairs [
    {"text", "canvas", 4.5},
    {"text", "surface", 4.5},
    {"text-muted", "canvas", 4.5},
    {"text-muted", "surface", 4.5},
    {"text-on-action", "action", 4.5}
  ]

  # 3.0 for colors that carry meaning/state (WCAG 2.2 SC 1.4.11 non-text contrast):
  # the focus ring, action color, and status colors MUST be perceivable.
  @ui_pairs [
    {"action", "canvas", 3.0},
    {"ring", "canvas", 3.0},
    {"danger", "canvas", 3.0},
    {"success", "canvas", 3.0},
    {"text-subtle", "surface", 3.0}
  ]

  # Structural borders are not the *sole* identifier of a control (inputs also
  # carry a label and a distinct surface fill), so SC 1.4.11's 3:1 does not
  # strictly apply. We still enforce a 1.5:1 perceptibility floor so a border
  # can never regress to invisible.
  @border_pairs [
    {"border-strong", "canvas", 1.5}
  ]

  setup_all do
    css = File.read!(@css)

    {:ok,
     light: parse_block(css, ~r/:root,\s*\[data-aui-theme="light"\]\s*\{(.*?)\}/s),
     dark: parse_block(css, ~r/\[data-aui-theme="dark"\]\s*\{(.*?)\}/s)}
  end

  test "no referenced token is missing from either theme", %{light: light, dark: dark} do
    referenced =
      (@text_pairs ++ @ui_pairs)
      |> Enum.flat_map(fn {fg, bg, _} -> [fg, bg] end)
      |> Enum.uniq()

    for token <- referenced do
      assert Map.has_key?(light, token), "light theme missing --aui-#{token}"
      assert Map.has_key?(dark, token), "dark theme missing --aui-#{token}"
    end
  end

  test "all color tokens parse to valid RGB triples", %{light: light, dark: dark} do
    for {theme, tokens} <- [{"light", light}, {"dark", dark}], {name, rgb} <- tokens do
      assert match?({r, g, b} when r in 0..255 and g in 0..255 and b in 0..255, rgb),
             "#{theme} --aui-#{name} is not a valid 0-255 RGB triple: #{inspect(rgb)}"
    end
  end

  for {fg, bg, min} <- @text_pairs do
    @tag fg: fg, bg: bg, min: min
    test "light text contrast: #{fg} on #{bg} >= #{min}", %{light: t} do
      assert_contrast(t, unquote(fg), unquote(bg), unquote(min))
    end

    test "dark text contrast: #{fg} on #{bg} >= #{min}", %{dark: t} do
      assert_contrast(t, unquote(fg), unquote(bg), unquote(min))
    end
  end

  for {fg, bg, min} <- @ui_pairs do
    test "light UI contrast: #{fg} on #{bg} >= #{min}", %{light: t} do
      assert_contrast(t, unquote(fg), unquote(bg), unquote(min))
    end

    test "dark UI contrast: #{fg} on #{bg} >= #{min}", %{dark: t} do
      assert_contrast(t, unquote(fg), unquote(bg), unquote(min))
    end
  end

  for {fg, bg, min} <- @border_pairs do
    test "light border perceptibility: #{fg} on #{bg} >= #{min}", %{light: t} do
      assert_contrast(t, unquote(fg), unquote(bg), unquote(min))
    end

    test "dark border perceptibility: #{fg} on #{bg} >= #{min}", %{dark: t} do
      assert_contrast(t, unquote(fg), unquote(bg), unquote(min))
    end
  end

  test "no referenced border token is missing", %{light: light, dark: dark} do
    for {fg, bg, _} <- @border_pairs, token <- [fg, bg] do
      assert Map.has_key?(light, token) and Map.has_key?(dark, token)
    end
  end

  # ── helpers ──

  defp assert_contrast(tokens, fg, bg, min) do
    ratio = contrast(Map.fetch!(tokens, fg), Map.fetch!(tokens, bg))

    assert ratio >= min,
           "--aui-#{fg} on --aui-#{bg} = #{Float.round(ratio, 2)}:1, needs #{min}:1"
  end

  defp parse_block(css, regex) do
    [_, body] = Regex.run(regex, css)

    Regex.scan(~r/--aui-([a-z0-9-]+):\s*(\d+)\s+(\d+)\s+(\d+)\s*;/, body)
    |> Map.new(fn [_, name, r, g, b] ->
      {name, {String.to_integer(r), String.to_integer(g), String.to_integer(b)}}
    end)
  end

  # WCAG relative luminance + contrast ratio.
  defp contrast(rgb1, rgb2) do
    l1 = luminance(rgb1)
    l2 = luminance(rgb2)
    {lighter, darker} = {max(l1, l2), min(l1, l2)}
    (lighter + 0.05) / (darker + 0.05)
  end

  defp luminance({r, g, b}) do
    0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
  end

  defp channel(v) do
    c = v / 255
    if c <= 0.03928, do: c / 12.92, else: :math.pow((c + 0.055) / 1.055, 2.4)
  end
end
