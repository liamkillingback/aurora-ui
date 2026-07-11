# Recipes

Real-world patterns built from Aurora UI components. Each recipe is a working
LiveView in the demo app (a real LiveView with real interaction, reconnect, and
streams — not a static snapshot; see [ADR-0004](adr/0004-catalogue.md)). The
routes below are on the docs site at
<https://aurora-ui.phxtemplates.com>, and the example code shown on each page is
read from compiled, tested snippet modules so it never drifts.

Every recipe follows the house rules: server-rendered HEEx is the source of
truth, JavaScript only enhances, and accessibility is built in — see
[accessibility.md](accessibility.md) and [liveview.md](liveview.md).

## Authentication form

A sign-in / sign-up form with proper label/help/error association, inline
validation, a password field, a remember-me switch, and a primary submit with a
loading state.

- Uses: `field`, `input`, `label`, `help_text`, `field_error`, `checkbox`/`switch`,
  `button`, `alert` (for a form-level error).
- Key ideas: `field/1` derives deterministic ids so the label, `aria-describedby`
  help, and `aria-errormessage` error line up; the submit button stays focusable
  and sets `aria-busy` while in flight rather than being swapped for a disabled
  control.
- Route: [`/recipes/auth-form`](https://aurora-ui.phxtemplates.com/recipes/auth-form)

## Dashboard with table + filters

A data dashboard: KPI stats, a filterable, sortable, selectable table with bulk
actions, and a filter shell whose state lives in the URL.

- Uses: `stat`, `filter_bar`, `filter_chip`, `search_field`, `select`, `table`
  (sortable + selectable), `badge`, `pagination`, `empty_state`.
- Key ideas: keep filters in the URL (shareable, back/forward-safe), render rows
  into a **stream** so only changed rows patch, announce the result count
  politely, and handle the sort/selection event contracts documented in
  [`AuroraUI.Components.DataNavigation`](../lib/aurora_ui/components/data_navigation.ex).
- Route: [`/recipes/dashboard`](https://aurora-ui.phxtemplates.com/recipes/dashboard)

## Command search

A command palette opened from a visible trigger (with an optional, discoverable
shortcut), plus a debounced search field and a semantic results list with an
empty state.

- Uses: `command_palette`, `search_field`, `search_results`, `search_result`.
- Key ideas: the visible trigger is the source of truth (the shortcut is an
  enhancement, never the only door); the palette hook is **lazy** (dynamic-imports
  `command.js`); results are a semantic list of links, not a listbox; always
  debounce live search.
- Route: [`/recipes/command-search`](https://aurora-ui.phxtemplates.com/recipes/command-search)

## Dialog + drawer flows

Confirmations and side panels done right: a modal dialog, a destructive
`alert_dialog`, and a non-modal filter drawer that the user works alongside the
page.

- Uses: `dialog`, `alert_dialog`, `drawer` (modal and non-modal), `button`.
- Key ideas: overlays are native `<dialog>` with hook-managed focus trap, focus
  return, scroll lock, and background `inert`; `alert_dialog` forces an explicit
  choice, focuses the least-destructive action, and is not backdrop-dismissable;
  drive `open` from an assign and provide `on_close`/`on_cancel` so the server
  clears state on dismissal.
- Route: [`/recipes/overlays`](https://aurora-ui.phxtemplates.com/recipes/overlays)

## Toast & error handling

Transient confirmations and durable errors, with the right live-region strategy.

- Uses: `toast_group`, `toast`, `alert`, `connection_state`, `async_state`.
- Key ideas: exactly one polite `toast_group` owns the streaming live region;
  use `dedup_key` to refresh instead of stacking; put anything the user *must* act
  on in a persistent `alert` or a `toast` with `timeout={0}` — never only in an
  ephemeral toast; keep reconnect calm with `connection_state`. See
  [troubleshooting.md](troubleshooting.md#reconnect-noise).
- Route: [`/recipes/toasts`](https://aurora-ui.phxtemplates.com/recipes/toasts)

## Async & streaming states

Mapping a LiveView `assign_async`/stream result to a single declarative branch.

- Uses: `async_state`, `spinner`, `skeleton`, `empty_state`, `table`.
- Key ideas: map the `AsyncResult` (and stream emptiness) to one `state` atom and
  let `async_state/1` pick the loading/empty/error/ok branch; reserve layout with
  `skeleton` sizes to avoid layout shift; stream the `:ok` branch. See the
  [`AuroraUI.Components.Progress`](../lib/aurora_ui/components/progress.ex) module
  doc.
- Route: [`/recipes/async`](https://aurora-ui.phxtemplates.com/recipes/async)

## Copying a component (preserving notices + a11y)

How to lift a component into your own namespace on the supported copy path while
keeping the MIT notice and the accessibility behavior intact.

- Uses: any family module + `AuroraUI.Internal` helpers (`cx/1`, `variant/3`,
  `id/2`).
- Key ideas: copy one file per component, rename the module, keep or inline the
  Internal helpers, **preserve the license notice and the focus/ARIA/state
  behavior**, and accept that you now own upstream merges for that file. See
  [upgrade.md](upgrade.md#copy--fork-path-documented-and-supported) and
  [ADR-0002](adr/0002-source-ownership.md).
- Route: [`/recipes/copy-a-component`](https://aurora-ui.phxtemplates.com/recipes/copy-a-component)

---

More patterns land as demand warrants — see how requests are prioritized in
[roadmap.md](roadmap.md). Contributions of new recipes are welcome
([`../CONTRIBUTING.md`](../CONTRIBUTING.md)).
