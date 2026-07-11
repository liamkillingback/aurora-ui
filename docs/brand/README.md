# Aurora UI brand assets

Guidance for the repository social preview and demo/OG images. Keep the kit
brand-neutral in code; these assets are for the *project's* own marketing only.

## Wordmark

"Aurora UI" set in the docs display font (Inter). Lowercase-friendly. No icon
font dependency.

## Palette (project marketing, not the neutral component tokens)

- Canvas: near-black `#050914` (the dark-theme `--aui-canvas`).
- Accent: sky `#38BDF8`, violet `#A78BFA` — used sparingly, aurora-glow only on
  hero/lab surfaces.

## Social preview (1280×640)

Dark canvas, faint dot-grid, the wordmark, the tagline "A free Phoenix LiveView
+ Tailwind UI kit", and "15 accessible component families". Set via GitHub →
Settings → Social preview. Export lives here as `social-preview.png` when
produced (the OG image the docs reference).

## OG image

The docs app emits Open Graph tags; the OG image mirrors the social preview.

> These are marketing assets for Aurora UI itself. They must never leak into a
> consumer's app — component tokens stay neutral (see `docs/tokens.md`).
