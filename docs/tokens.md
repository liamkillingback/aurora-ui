# Design tokens & theming

Every visual value in Aurora UI resolves to a CSS custom property under the
`--aui-*` namespace, defined in
[`../assets/css/aurora_ui.css`](../assets/css/aurora_ui.css). **The set of
`--aui-*` tokens is the public theming API** (see
[ADR-0003](adr/0003-tailwind-and-css.md) and
[compatibility.md](compatibility.md)) — you theme Aurora UI by redefining these
properties in *your own* CSS. No recompile, no forked source, no PHXTemplates
branding leaking into your app.

Never edit `aurora_ui.css`. Override in a layer you control.

## How color tokens are stored

Color tokens are **space-separated RGB channel triples**, not `rgb(...)` or hex.
They are consumed as `rgb(var(--aui-x) / <alpha>)`, so opacity composes cleanly:

```css
/* a token value looks like this */
--aui-action: 37 99 235;

/* and is used like this */
background: rgb(var(--aui-action));
border-color: rgb(var(--aui-action) / 0.5);   /* 50% alpha */
```

When you override a color token, supply the same triple format:

```css
:root {
  --aui-action: 124 58 237;   /* your brand purple, as R G B */
}
```

Non-color tokens (radii, spacing, type, motion, layering) are ordinary CSS
values.

## Light & dark

Light is the default token set; dark is an **independent, hand-authored** set —
not an algorithmic inversion — and both are contrast-validated (see
`test/theme_contrast`). Theme resolution:

- `:root` / `[data-aui-theme="light"]` → light tokens.
- `[data-aui-theme="dark"]` → dark tokens.
- `@media (prefers-color-scheme: dark)` on `:root:not([data-aui-theme])` → dark
  tokens when the consumer has **not** pinned a theme, respecting the OS
  preference automatically.

To pin a theme, set `data-aui-theme="light"` or `"dark"` on `<html>` (or any
scope). To follow the OS, set nothing. `color-scheme` is set alongside so native
form controls and scrollbars match.

Only **color** tokens (and shadows) change between themes. Radii, spacing, type,
sizing, layering, and motion are theme-independent.

## Token reference

### Canvas & surfaces (elevation ladder)

| Token | Light | Dark | Purpose |
|---|---|---|---|
| `--aui-canvas` | `250 250 252` | `5 9 20` | Page background |
| `--aui-surface` | `255 255 255` | `11 19 34` | Default surface |
| `--aui-surface-raised` | `255 255 255` | `17 26 43` | Raised surface (cards, menus) |
| `--aui-surface-sunken` | `244 244 248` | `8 14 26` | Recessed surface (code blocks, wells) |
| `--aui-surface-overlay` | `255 255 255` | `17 26 43` | Overlay/dialog surface |

### Text

| Token | Light | Dark | Purpose |
|---|---|---|---|
| `--aui-text` | `17 20 28` | `226 232 240` | Primary text |
| `--aui-text-muted` | `90 96 110` | `148 160 178` | Secondary text |
| `--aui-text-subtle` | `128 134 148` | `108 120 138` | Tertiary/subtle text |
| `--aui-text-on-action` | `255 255 255` | `5 9 20` | Text on an action-colored fill |

### Borders & focus ring

| Token | Light | Dark | Purpose |
|---|---|---|---|
| `--aui-border` | `224 226 232` | `34 46 68` | Default border/separator |
| `--aui-border-strong` | `200 203 212` | `51 66 92` | Emphasized border |
| `--aui-ring` | `56 132 248` | `56 189 248` | Focus-visible ring color |

### Action / primary

| Token | Light | Dark | Purpose |
|---|---|---|---|
| `--aui-action` | `37 99 235` | `56 189 248` | Primary action fill |
| `--aui-action-hover` | `29 78 216` | `125 211 252` | Hover state |
| `--aui-action-active` | `30 64 175` | `14 165 233` | Active/pressed state |
| `--aui-action-subtle` | `219 234 254` | `12 74 110` | Subtle action tint (backgrounds) |

### Status

Each severity has a base and a `-subtle` tint. Meaning is never carried by color
alone — components also use text and/or icons.

| Token | Light | Dark |
|---|---|---|
| `--aui-success` / `--aui-success-subtle` | `21 128 61` / `220 252 231` | `74 222 128` / `5 46 22` |
| `--aui-warning` / `--aui-warning-subtle` | `180 83 9` / `254 243 199` | `251 191 36` / `66 32 6` |
| `--aui-danger` / `--aui-danger-subtle` | `190 40 44` / `254 226 226` | `248 113 113` / `69 10 10` |
| `--aui-info` / `--aui-info-subtle` | `3 105 161` / `224 242 254` | `56 189 248` / `8 47 73` |

### Data / chart ramp

Categorical, contrast-checked against the canvas. Used by `stat`, badges, and
any chart layer you build.

| Token | Light | Dark |
|---|---|---|
| `--aui-data-1` | `37 99 235` | `56 189 248` |
| `--aui-data-2` | `5 150 105` | `52 211 153` |
| `--aui-data-3` | `217 119 6` | `251 191 36` |
| `--aui-data-4` | `190 40 44` | `248 113 113` |
| `--aui-data-5` | `124 58 237` | `167 139 250` |
| `--aui-data-6` | `8 145 178` | `34 211 238` |

### Radii

| Token | Value |
|---|---|
| `--aui-radius-xs` | `0.25rem` |
| `--aui-radius-sm` | `0.375rem` |
| `--aui-radius-md` | `0.5rem` |
| `--aui-radius-lg` | `0.75rem` |
| `--aui-radius-xl` | `1rem` |
| `--aui-radius-full` | `9999px` |

### Spacing (4px base)

`--aui-space-1` … `--aui-space-12`: `0.25`, `0.5`, `0.75`, `1`, `1.25`, `1.5`,
`2` (`-8`), `2.5` (`-10`), `3rem` (`-12`). (The scale is non-linear at the top —
`1`–`6` are contiguous, then `8`, `10`, `12`.)

### Type

| Token | Value |
|---|---|
| `--aui-font-sans` | `ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif` |
| `--aui-font-mono` | `ui-monospace, "JetBrains Mono", "SFMono-Regular", Menlo, Consolas, monospace` |
| `--aui-text-xs` … `--aui-text-2xl` | `0.75`, `0.875`, `1` (base), `1.125`, `1.375`, `1.75rem` |
| `--aui-leading-tight` / `--aui-leading-normal` | `1.2` / `1.5` |

### Sizing

| Token | Value | Purpose |
|---|---|---|
| `--aui-control-sm` | `2rem` | Small control height |
| `--aui-control-md` | `2.5rem` | Default control height |
| `--aui-control-lg` | `3rem` | Large control height |
| `--aui-touch-min` | `44px` | Minimum touch target |
| `--aui-measure` | `68ch` | Readable line length (prose) |

### Layering (z-index ladder)

A single documented ladder for overlays so stacking never becomes guesswork.

| Token | Value |
|---|---|
| `--aui-z-base` | `0` |
| `--aui-z-sticky` | `100` |
| `--aui-z-dropdown` | `1000` |
| `--aui-z-overlay` | `1100` |
| `--aui-z-modal` | `1200` |
| `--aui-z-toast` | `1300` |
| `--aui-z-tooltip` | `1400` |

### Motion

See [motion.md](motion.md) for how these are applied and the reduced-motion
contract.

| Token | Value | Purpose |
|---|---|---|
| `--aui-dur-1` | `120ms` | Micro: hover, press |
| `--aui-dur-2` | `180ms` | Small enter/exit |
| `--aui-dur-3` | `240ms` | Overlays |
| `--aui-dur-4` | `360ms` | Emphasis / spatial |
| `--aui-ease-standard` | `cubic-bezier(0.2, 0, 0, 1)` | Default easing |
| `--aui-ease-emphasized` | `cubic-bezier(0.2, 0, 0, 1.2)` | Emphasized (slight overshoot) |
| `--aui-ease-exit` | `cubic-bezier(0.4, 0, 1, 1)` | Exit/accelerate |
| `--aui-distance-sm` / `-md` / `-lg` | `4px` / `8px` / `16px` | Travel distances |
| `--aui-stagger` | `40ms` | Per-item stagger delay |

### Elevation (shadows)

Theme-dependent. Zeroed out under `@media (forced-colors: active)` so the OS owns
color and structure stays legible.

| Token | Light | Dark |
|---|---|---|
| `--aui-shadow-sm` | `0 1px 2px 0 rgb(17 20 28 / 0.06)` | `0 1px 2px 0 rgb(0 0 0 / 0.4)` |
| `--aui-shadow-md` | `0 4px 12px -2px …, 0 2px 4px -2px …` | (darker equivalents) |
| `--aui-shadow-lg` | `0 16px 40px -12px rgb(17 20 28 / 0.22)` | `0 16px 50px -12px rgb(0 0 0 / 0.7)` |
| `--aui-shadow-ring` | `0 0 0 1px rgb(17 20 28 / 0.05)` | `0 0 0 1px rgb(255 255 255 / 0.04)` |

## Overriding tokens — a worked brand theme

Because tokens live on `:root`, you override them in your own stylesheet, which
sits in a layer that beats `aui.components`. Set both themes:

```css
/* assets/css/app.css — imported AFTER aurora_ui.css */

:root,
[data-aui-theme="light"] {
  /* Brand accent (violet) */
  --aui-action: 124 58 237;
  --aui-action-hover: 109 40 217;
  --aui-action-active: 91 33 182;
  --aui-action-subtle: 237 233 254;
  --aui-ring: 139 92 246;

  /* Rounder corners + a serif display face */
  --aui-radius-md: 0.75rem;
  --aui-radius-lg: 1rem;
  --aui-font-sans: "Inter", ui-sans-serif, system-ui, sans-serif;
}

[data-aui-theme="dark"] {
  --aui-action: 167 139 250;
  --aui-action-hover: 196 181 253;
  --aui-action-active: 139 92 246;
  --aui-action-subtle: 46 16 101;
  --aui-ring: 167 139 250;
  --aui-text-on-action: 20 10 40;
}
```

You can also scope a theme to a subtree by putting the overrides (or a
`data-aui-theme`) on any element rather than `:root` — useful for a dark hero
band on an otherwise light page.

## Tailwind preset (optional)

Per [ADR-0003](adr/0003-tailwind-and-css.md), components **never depend on
Tailwind utilities being generated** — the shipped CSS is static, so Tailwind's
`content` purge cannot strip Aurora styles. Tailwind is purely optional.

If you *do* use Tailwind and want to reference Aurora tokens from utility classes
(e.g. `bg-[rgb(var(--aui-surface))]` or a mapped `theme` key), map the `--aui-*`
properties into your Tailwind theme. When you write utility-based recipes against
these tokens, add Aurora's compiled modules to your `content` globs so class
scanning sees them:

```js
// tailwind.config.js
content: [
  "./js/**/*.js",
  "./lib/**/*.{ex,heex}",
  "../deps/aurora_ui/lib/**/*.ex"   // only needed if you use Aurora's utility recipes
]
```

Because color tokens are RGB triples, map them through `rgb(var(...) / <alpha-value>)`
so Tailwind opacity modifiers keep working:

```js
theme: {
  extend: {
    colors: {
      "aui-action": "rgb(var(--aui-action) / <alpha-value>)",
      "aui-surface": "rgb(var(--aui-surface) / <alpha-value>)"
    },
    borderRadius: { "aui-md": "var(--aui-radius-md)" }
  }
}
```
