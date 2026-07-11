# Phase 1 — art direction

**Status:** approved (maintainer sign-off 2026-07-11) · supersedes exploration boards.

## Moodboard direction (selected)

**"Instrument panel at night."** A precise, calm, spatial devtool aesthetic —
the language of Linear/Vercel/Raycast, adapted to Phoenix and made brand-neutral.
Crafted, technically precise, quietly kinetic. Depth comes from a disciplined
elevation ladder and light, not from ornament.

### Two directions explored

1. **"Aurora field" (selected).** Deep near-black canvas, cool sky/violet accents
   used sparingly, generous negative space, a faint dot-grid and occasional
   aurora glow reserved for hero/lab surfaces. Neutral enough to sit under any
   consumer brand once tokens are overridden.
2. **"Warm paper" (rejected as default).** Light, editorial, high-warmth. Lovely
   for docs, but imposes a strong personality on consumer apps and fights the
   dark-first devtool positioning. Retained only as the docs light theme.

Direction 1 wins: it feels crafted, spatial, kinetic, and technically precise
while staying compatible with many brands after a ~12-variable token override.

## Palette (semantic, brand-neutral)

Defined as the light and dark token sets in `assets/css/aurora_ui.css`. Both are
hand-authored and contrast-checked (`test/aurora_ui/theme_contrast_test.exs`).
The neutral base is a true neutral so consumers don't inherit a hue they didn't
choose; accent defaults to a blue that meets AA on both canvases and is trivially
overridable via `--aui-action`.

## Typography & icons

- **Type:** system-font stack by default (`--aui-font-sans`), so consumers pay no
  font cost and get native rendering. The docs opt into Inter + JetBrains Mono
  (OFL, in `NOTICE.md`); substitution is a one-variable change.
- **Icons:** Aurora UI ships **no icon font**. Components take icons via slots, so
  consumers use their own set. Docs illustrate with Lucide (ISC).

## Representative states designed before implementation

For form, overlay, navigation, data, command, feedback, and experience families
we specified the visual treatment of default/hover/focus-visible/selected/
loading/empty/error/disabled/offline, in light + dark + reduced-motion + forced-
colors, prior to building. Those specs became the CSS token usage and the state
matrix.

## Documentation across modes

Docs are designed for mobile, laptop, wide desktop, 200–400% zoom, reduced-motion,
and high-contrast/forced-colors. The immersive `/lab` layer is additive and never
required to read a component page.
