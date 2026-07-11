# Changelog

All notable changes to Aurora UI are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Aurora UI's public API is the set of documented `AuroraUI.Components.*` function
components, their attributes/slots, the `--aui-*` CSS custom-property contract,
and the registered JavaScript hook names/DOM contract. Internal modules
(`AuroraUI.Internal`) may change without notice.

## [Unreleased]

## [0.1.2] — 2026-07-11

A second visual/interaction QA pass of the component lab. All are backward
compatible (the public component API, `--aui-*` contract, and hook names are
unchanged; only internal styling and one internal hook data-attribute moved).

### Fixed

- **Field controls show a single focus ring.** The bordered `field` control now
  owns the ring on `:focus-within` (and the inner input's own outline is
  suppressed). Previously the input drew its base outline inset inside the padded
  box, so a focused input/textarea rendered two concentric rings.
- **Horizontal `steps` no longer strike through their labels.** The connector
  ran at the marker's vertical centre, straight across the inline label. The
  horizontal stepper now stacks the marker over a centred label, with the
  connector running between markers only. (Vertical steps are unchanged.)
- **`icon_button` at the default `md` size is square.** It was `40×44` because
  the width used `--aui-control-md` while the shared `md` `min-height` is the
  44px touch target; the width now matches at 44px.
- **`toast` exit animation plays.** The CSS matched `[data-aui-leaving="true"]`
  but the hook sets the attribute with an empty value; it now matches on
  presence, so dismissed/expired toasts animate out (and fade out under reduced
  motion) instead of popping.
- **Code-block copy button reads “Copied”.** The success state appended `"ied"`
  to the `Copy` label, producing “Copyied”; it now swaps the whole word.
- **Interactive `card` shows a visible focus ring.** The stretched link's outline
  was painted outside the card's padding box and clipped by the card's
  `overflow: hidden`. The ring now renders on the card itself (its own outline is
  not clipped) and the link's clipped outline is suppressed.
- **Command-palette backdrop dims in both themes.** The scrim was keyed to
  `--aui-text`, which inverted to a near-white veil in dark mode; it now uses the
  same fixed dark scrim as the dialog/drawer backdrops.
- **`tilt` works again.** The CSS read `--aui-rx/--aui-ry` under a
  `[data-aui-tilt-active]` state and the markup emitted `data-aui-max-deg`, but
  the hook publishes `--aui-tilt-x/-y/-scale` and reads `data-aui-tilt-max`. The
  stylesheet and markup now match the hook contract.
- **Top/bottom `drawer` content scrolls inside.** The box was capped only on the
  dialog, not the box, so tall content spilled past the 85dvh band; the box now
  carries `max-block-size: 85dvh` and its body scrolls.
- **Combobox query text stays clear of the loading spinner.** While `loading`,
  the input reserves extra trailing space so a long query can't render beneath
  the spinner that sits inboard of the clear button.

## [0.1.1] — 2026-07-11

Interaction and layout fixes found in a full visual/interaction QA pass of the
component lab. All are backward compatible.

### Fixed

- **Overlays now open from a trigger.** `dialog`, `alert_dialog`, and `drawer`
  are opened by toggling `data-aui-open` with `Phoenix.LiveView.JS.set_attribute`
  — a client-side change that never fires the hook's `updated()`. The hooks now
  observe the attribute (`MutationObserver`), so triggers work. The drawer also
  calls the native `show()`/`showModal()` so the `<dialog>` actually renders
  (and a modal drawer regains its backdrop, top layer, and inert background).
- **Dialog is centered.** Consumer resets (e.g. Tailwind Preflight's
  `dialog { margin: 0 }`) clobbered the UA's centering and pinned the modal to
  the top-left; `.aui-dialog` now owns `margin: auto`.
- **Tooltip renders.** The `AuroraTooltip` hook was mounted on the tooltip root
  wrapper and hid it (trigger included). The hook now lives on the bubble, so the
  trigger stays visible and the bubble shows on hover/focus.
- **Popover opens.** The panel carries the native `popover` attribute (CSS shows
  it via `:popover-open`), but the hook toggled `hidden` and never called
  `showPopover()`. It now uses the native popover API (`popover="manual"`, hook
  owns dismissal).
- **Command palette opens from its button.** `mountCommandPalette` never wired
  the visible trigger's click (only the ⌘K shortcut). It now does. The listbox
  gained the `data-aui-command-list` marker the hook queries for.
- **Combobox hook activates.** `phx-hook="AuroraCombobox"` moved from the
  `<input>` to the root container (where `mountCombobox` looks for the input and
  list); added the `data-aui-combobox-input`/`-list` markers.
- **Gallery is a grid again.** `gallery` claims `inline-size: 100%` so its
  auto-fill grid gets real column space inside flex/inline parents instead of
  collapsing to one column.

## [0.1.0] — 2026-07-11

Initial public release.

### Added

- **15 component families** as `Phoenix.Component` function components: Actions,
  Field, Choices, Selection, Navigation, Tabs & disclosure, Overlays, Floating
  UI, Feedback, Data display, Data navigation, Loading/progress, Search/command,
  Media/content, and Experience.
- **Semantic token system** (`assets/css/aurora_ui.css`): brand-neutral
  `--aui-*` custom properties for color, spacing, type, radii, elevation,
  layering, and motion, with independent hand-authored light and dark themes and
  a contrast test.
- **Core JavaScript hooks** (`aurora_ui` entry) plus lazily-imported
  `command`, `motion`, and `three` entry points that stay out of consumer
  bundles until their component is rendered.
- **Fully-implemented Three.js scene host** with static/semantic fallbacks,
  capability detection, pause/resize/context-recovery/disposal.
- **Docs + component lab** (`demo/`) and an example application proving the
  install story end to end.
- Accessibility, browser, bundle, and visual-regression evidence under
  `docs/evidence/`.
- Governance: MIT license, security policy, contribution guide, code of conduct,
  support/compatibility policy, third-party notices, and architecture decision
  records.

[Unreleased]: https://github.com/liamkillingback/aurora-ui/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/liamkillingback/aurora-ui/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/liamkillingback/aurora-ui/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/liamkillingback/aurora-ui/releases/tag/v0.1.0
