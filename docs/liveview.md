# LiveView behavior

Aurora UI is built for Phoenix LiveView. Server-rendered HEEx is always the
source of truth; JavaScript only enhances behavior that HTML and
`Phoenix.LiveView.JS` cannot express safely on their own. This page explains the
JS organization, the hook DOM contract, and how components survive LiveView
patches and reconnects.

## The JavaScript organization ladder (ADR-0005)

Per [ADR-0005](adr/0005-javascript-organization.md), each behavior is
implemented with the lightest mechanism that works:

1. **`Phoenix.LiveView.JS` first.** Show/hide, class toggles, simple transitions,
   and server round-trips are expressed as `JS` commands in HEEx — no hook.
2. **Colocated component hooks** for behavior that is inherently client-side and
   component-local: focus trap, roving `tabindex`, floating-panel positioning,
   IntersectionObserver reveals. Each hook owns a narrow DOM boundary and cleans
   up fully.
3. **Shared hooks only for genuinely cross-component concerns** — LiveView
   connection state and copy-to-clipboard.
4. **Separate lazy entry points** for heavy/optional behavior — the command
   palette, the enhanced combobox, advanced tilt, and the Three.js scene are
   dynamically `import()`ed at mount, so they are code-split and absent from any
   bundle that does not render them.

The consequence: a page that renders only a `button` ships ~0 component JS; heavy
features are opt-in *by rendering them*. This is verified by the
bundle-composition test (phase-08 evidence).

## Registering hooks

Core hooks are exported as `AuroraHooks` from the package entry point and
registered on the `LiveSocket`:

```js
import { AuroraHooks } from "aurora_ui"
const liveSocket = new LiveSocket("/live", Socket, { hooks: { ...AuroraHooks } })
```

`AuroraHooks` includes the eager core hooks and the four **lazy wrappers**
(`AuroraCombobox`, `AuroraCommandPalette`, `AuroraSceneHost`, `AuroraTilt`) whose
real implementations are dynamic-imported on mount:

| Eager core | Lazy (dynamic-import on mount) |
|---|---|
| `AuroraDialog`, `AuroraDrawer`, `AuroraPopover`, `AuroraMenu`, `AuroraTooltip`, `AuroraTabs`, `AuroraDisclosure`, `AuroraToast`, `AuroraReveal`, `AuroraSpotlight`, `AuroraConnectionState`, `AuroraCopyButton` | `AuroraCombobox` → `command.js`, `AuroraCommandPalette` → `command.js`, `AuroraTilt` → `motion.js`, `AuroraSceneHost` → `three/scene.js` |

## Hook DOM contract (summary)

The full DOM contract — which `data-aui-*` attributes each component renders for
its hook — is the authoritative table in
[`../AGENTS.md`](../AGENTS.md#javascript--liveview-hook-contract). It is part of
the public API under SemVer ([compatibility.md](compatibility.md)). In brief, a
component that needs client behavior sets `phx-hook="Aurora<Name>"` on a **stable
DOM id** and exposes state through data attributes, e.g.:

- `dialog`/`alert_dialog` → `AuroraDialog`, `data-aui-dialog`, `data-aui-open`,
  `[data-aui-dialog-close]`.
- `drawer` → `AuroraDrawer`, `data-aui-drawer`, `data-aui-side`, `data-aui-modal`.
- `menu`/`popover`/`tooltip` → `AuroraMenu`/`AuroraPopover`/`AuroraTooltip`,
  `data-aui-anchor`, `data-aui-placement`.
- `tabs` → `AuroraTabs`, `[role=tab]`/`[role=tabpanel]`, `data-aui-activation`.
- `accordion` → `AuroraDisclosure` on native `<details>`.
- `toast_group` → `AuroraToast`, `data-aui-toast-region`, per-toast
  `data-aui-timeout` / `data-aui-dedup-key`.
- `combobox`/`command_palette` → lazy, dynamic-import `command.js`.
- `scene_host` → lazy `AuroraSceneHost`, dynamic-import `three/scene.js`.

Every hook must: guard against duplicate mount, respect `prefers-reduced-motion`
(re-read live), clean up listeners/observers/timers/RAF in `destroyed()`, and
survive `updated()` without losing open/focus/selection state.

## State preservation through patches

LiveView re-renders and DOM-patches on every change. Aurora keeps
client-owned state stable across patches in two ways:

1. **Deterministic ids.** `AuroraUI.Internal.id/2` derives child ids from a
   single base (e.g. `#{id}-listbox`, `#{id}-option-#{n}`, `#{id}-tab-#{index}`),
   never random per-render ids, so ARIA relationships and hook targets stay
   pointing at the same nodes across patches. **Pass a stable `id`** to any
   stateful component (tabs, accordion, dialog, drawer, combobox, command
   palette, toast group, connection state) — several require it.
2. **Hooks own transient state in the DOM and survive `updated()`.** Tabs keep
   the current selection because the hook holds it in the DOM and re-reconciles
   in `updated()`; overlays keep open/focus/scroll-lock state; the combobox keeps
   `aria-activedescendant` and the active option.

Server-authoritative state stays on the server where it matters:
`dialog`/`drawer` reflect a controlled `open` assign to `data-aui-open`;
`data_grid` keeps `active_row`/`active_col` authoritative so roving focus survives
a patch; `table` sort/selection is driven by events you handle and re-assign.

Prefer LiveView **streams** for large collections (tables, search results, toast
lists) so only changed rows are patched — see [recipes.md](recipes.md) and the
`filter_bar`/`async_state` module docs.

Do **not** reach for `phx-update="ignore"` on a whole interactive component to
dodge integration — it is a prohibited shortcut
([`../AGENTS.md`](../AGENTS.md#prohibited-shortcuts)). The hooks are designed to
cooperate with patching instead.

## Reconnect behavior

When the socket drops and re-establishes, LiveView re-mounts and re-patches:

- `connection_state/1` (via `AuroraConnectionState`) reflects the socket state
  onto `data-aui-conn` (`connected`/`connecting`/`disconnected`) and cooperates
  with Phoenix's own `.phx-loading`/`.phx-error` body classes. It is deliberately
  calm: a single polite live region announced **once** per change, a visible
  "reconnecting…" affordance, no focus stealing, and it never discards
  in-progress work — it reports reachability only.
- Exit transitions are played by hooks *before* the element is removed
  (`afterTransition`), so a drawer/dialog close animation never races LiveView
  DOM patching during reconnect.
- Because ids are deterministic, re-mounted hooks re-claim the same nodes and
  guard against duplicate mounts, so a reconnect does not stack listeners.

See [troubleshooting.md](troubleshooting.md#reconnect-noise) for how to avoid
toast/flash noise on reconnect.

## Stable-id requirements

Some components require a stable `id`; others generate a deterministic one if you
omit it. Always supply your own stable id for stateful components rendered inside
a list/stream so the identity is under your control:

| Requires `id` (attr is `required`) | Auto-generates a deterministic id when omitted |
|---|---|
| `tabs/1`, `accordion/1` | `dialog/1`, `alert_dialog/1`, `drawer/1`, `menu/1`, `popover/1`, `tooltip/1`, `combobox/1`, `command_palette/1`, `toast_group/1`, `connection_state/1`, `field/1`, form controls, `reveal/1`, `stagger/1`, `spotlight/1`, `tilt/1`, `scene_host/1`, `code_block/1`, `callout/1` |

## Lazy-loaded modules

The lazy hooks dynamic-import their implementation at mount, keeping heavy code
out of unrelated bundles:

- `AuroraCombobox`, `AuroraCommandPalette` → `command.js` (enhanced combobox +
  palette keyboard/filtering).
- `AuroraTilt` → `motion.js` (pointer tilt math).
- `AuroraSceneHost` → `three/scene.js` (Three.js; `three` is an **optional peer
  dependency**, never bundled into core — see
  [ADR-0007](adr/0007-threejs.md) and
  [dependency-inventory.md](dependency-inventory.md)).

Because the import happens on mount, the first render of a lazy component is
server-HTML-correct and usable before its JS arrives; the enhancement layers on
once loaded. If the import path is wrong the component still renders but the
enhancement never activates — see
[troubleshooting.md](troubleshooting.md#combobox--command-palette-not-enhancing).
