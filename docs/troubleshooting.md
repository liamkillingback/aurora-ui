# Troubleshooting

Common first-run and integration problems, each with the fix. If none of these
match, check [Getting started](getting-started.md), the
[LiveView behavior](liveview.md) page, or open a GitHub Discussion
([`../SUPPORT.md`](../SUPPORT.md)).

## Styles are not applying (or your overrides don't win)

**Symptoms:** components render as unstyled HTML, or your theme overrides have no
effect.

**Fixes:**

1. **Import the CSS.** Ensure `@import "aurora_ui/aurora_ui.css";` is present in
   your `app.css` and that your bundler resolves the package path.
2. **Import order + cascade layers.** Import Aurora **before** your own styles.
   Aurora is authored in named layers
   (`aui.reset, aui.tokens, aui.base, aui.components, aui.utilities`). Unlayered
   consumer CSS and your Tailwind `utilities` layer beat `aui.components` by the
   cascade-layer rules ([ADR-0003](adr/0003-tailwind-and-css.md)) — so you should
   **not** need `!important`. If you *are* reaching for `!important`, your import
   order is likely wrong (Aurora imported after your styles) or your overrides are
   themselves inside an earlier-declared layer.
3. **Override tokens, not classes.** For theming, redefine `--aui-*` tokens in
   your CSS (see [tokens.md](tokens.md)) rather than fighting component classes.
4. **Color format.** Color tokens are RGB *triples* (`37 99 235`), consumed as
   `rgb(var(--aui-x) / <alpha>)`. Setting `--aui-action: #2563eb` will break —
   use `--aui-action: 37 99 235`.

## Hooks not firing (behavior is dead)

**Symptoms:** the dialog won't trap focus, the menu won't open with the keyboard,
tabs don't respond to arrow keys, toasts don't auto-dismiss.

**Fixes:**

1. **Register `AuroraHooks`.** Confirm
   `new LiveSocket(..., { hooks: { ...AuroraHooks } })` and that
   `import { AuroraHooks } from "aurora_ui"` resolves. A missing spread is the
   most common cause.
2. **Stable ids.** Stateful components need a stable id (`tabs`/`accordion`
   *require* one). A changing id per render makes the hook re-mount and lose
   state — see [liveview.md](liveview.md#stable-id-requirements).
3. **Don't ignore updates.** `phx-update="ignore"` on the whole component blocks
   the hook's `updated()` reconciliation. Remove it.
4. **Check the browser console** for a hook name typo — `phx-hook` must match a
   key in `AuroraHooks` exactly (`AuroraDialog`, not `auroraDialog`).

## Tailwind purges/strips styles, or utility recipes disappear

**Symptoms:** Aurora looks fine in dev but breaks in a production build, or
Tailwind-based recipes against Aurora tokens lose their classes.

**Fixes:**

- Aurora's shipped CSS is **static** (not utilities), so Tailwind's `content`
  purge does **not** remove it — if base Aurora styles vanish in prod, the cause
  is the CSS import/bundling, not purge.
- If you use Aurora's **optional Tailwind preset with utility-based recipes**, add
  Aurora's compiled modules to your `content` globs so class scanning sees them:

  ```js
  content: ["./lib/**/*.{ex,heex}", "../deps/aurora_ui/lib/**/*.ex"]
  ```

  ([ADR-0003](adr/0003-tailwind-and-css.md), [tokens.md](tokens.md#tailwind-preset-optional)).

## Content Security Policy blocks the scene / hooks

**Symptoms:** the Three.js scene never boots, or lazy hooks fail to import, with a
CSP violation in the console.

**Fixes:**

- The scene host and other lazy hooks use **dynamic `import()`**. Your
  `script-src` must allow the chunk to load (self-hosted chunks need `'self'`;
  avoid `strict-dynamic` misconfigurations that block sibling chunks).
- The scene host writes to a `<canvas>` (WebGL) — no external network is
  required, and `three` is loaded from your own bundle as an optional peer dep, so
  you do **not** need to allow a third-party host. If your CSP disallows the WebGL
  context or the worker/chunk, the host correctly leaves the static `fallback`
  in place ([ADR-0007](adr/0007-threejs.md)).
- Aurora ships no analytics/telemetry and makes no network calls from the library
  ([ADR-0009](adr/0009-analytics-and-email.md)), so no `connect-src` allowance is
  needed for the components themselves.

## Dark mode isn't switching

**Symptoms:** toggling your theme control doesn't change Aurora's colors, or it
ignores the OS setting.

**Fixes:**

- **Follow the OS:** set *no* `data-aui-theme`. Aurora then uses
  `@media (prefers-color-scheme: dark)` on `:root:not([data-aui-theme])`.
- **Pin a theme:** set `data-aui-theme="light"` or `"dark"` on `<html>` (or a
  scope). If you set the attribute, the media-query fallback no longer applies —
  your toggle must flip the attribute value.
- If native form controls or scrollbars look wrong, ensure the attribute is on a
  high enough ancestor; Aurora sets `color-scheme` alongside the tokens.
- Overriding only *one* theme? Remember light and dark are independent token sets
  — override both `[data-aui-theme="light"]`/`:root` **and**
  `[data-aui-theme="dark"]` ([tokens.md](tokens.md#overriding-tokens--a-worked-brand-theme)).

## Combobox / command palette not enhancing

**Symptoms:** the combobox filters on the server but has no keyboard highlighting;
the command palette opens as plain HTML with no filtering.

**Fixes:**

- These use **lazy** hooks (`AuroraCombobox`, `AuroraCommandPalette`) that
  dynamic-import `command.js` on mount. Confirm the wrappers are registered (they
  are part of `AuroraHooks`) and that your bundler emits and serves the
  code-split `command.js` chunk (check the Network tab on mount).
- Give the component a **stable `id`** — the command palette hook needs it to
  survive patches (`command_palette` documents `id` as required for the hook).
- The baseline is intentional: server filtering + a semantic list works without
  JS; the hook adds active-descendant, typeahead, and keyboard nav on top. If the
  chunk 404s, you get the working baseline but no enhancement — fix the asset path.

## Reconnect flash / toast noise

<a id="reconnect-noise"></a>

**Symptoms:** after a socket reconnect, flash messages or toasts re-appear or
stack up; the connection indicator "shouts."

**Fixes:**

- Render toasts from a LiveView **stream** and let `toast_group/1` +
  `AuroraToast` own timers/de-dup. Give repeated notifications a
  `dedup_key` so a matching visible toast is refreshed instead of a duplicate
  being stacked.
- Don't re-`put_flash` unconditionally in `mount`/`handle_params` — a reconnect
  re-runs them. Gate flash on a real event, or move transient status to
  `connection_state/1`, which announces **once** per state change (a single polite
  region, no focus stealing) rather than on every patch.
- For a critical error the user must act on, use a persistent `alert/1` or a
  `toast` with `timeout={0}` — never rely on an ephemeral toast that a reconnect
  might clear ([`AuroraUI.Components.Feedback`](../lib/aurora_ui/components/feedback.ex)).

## A component won't keep its open/selected state across a change

**Symptoms:** clicking elsewhere in the LiveView collapses an open menu, resets
tab selection, or closes a drawer.

**Fixes:**

- Ensure a **stable `id`** and remove any `phx-update="ignore"`.
- For server-controlled overlays, drive `open` from an assign and provide
  `on_close`/`on_cancel` so the server clears the controlling assign when the user
  dismisses — otherwise the next patch re-opens it. See
  [recipes.md](recipes.md) and [liveview.md](liveview.md#state-preservation-through-patches).
