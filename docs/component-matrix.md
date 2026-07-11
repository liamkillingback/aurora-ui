# Component matrix

A traceability map of all **15 families** → their components → key variants →
interaction states covered → keyboard/touch behavior → ARIA/semantic notes → test
file → docs page. Rows are derived by reading the actual modules in
[`../lib/aurora_ui/components/`](../lib/aurora_ui/components/); states marked
`n/a` do not apply to that component.

**Notation.** States use the [definition-of-done](../AGENTS.md#component-definition-of-done)
vocabulary: default, hover, active, focus-visible (`focus`), selected/checked,
loading, empty, success/warning/error (`status`), disabled, readonly,
offline/reconnecting. "Docs page" is the ExDoc module page (the `@moduledoc` /
`@doc` for each function) plus the interactive lab route.

> **Test-coverage note (honest status):** render test files exist today for
> command, data_display, data_navigation, experience, feedback, field, floating,
> media, navigation, overlay, progress, and tabs. The **actions**, **choices**,
> and **selection** families follow the same `test/aurora_ui/<family>_test.exs`
> convention but their files are not yet present — those rows list the intended
> path and are flagged. Filling them in is a standing priority
> ([roadmap.md](roadmap.md)).

---

## 1. Actions — `AuroraUI.Components.Actions`

Docs: [`actions.ex`](../lib/aurora_ui/components/actions.ex) · Test:
`test/aurora_ui/actions_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `button/1` | variant `primary/secondary/ghost/subtle/danger/link`; size `sm/md/lg`; `full_width` | default, hover, active, focus, loading, disabled | native `<button>` activation (Enter/Space); becomes `<a>` on `navigate/patch/href` | loading stays focusable + `aria-busy`; `aria-disabled` on link form; leading/trailing icons `aria-hidden` |
| `icon_button/1` | variant/size as button | default, hover, active, focus, loading, disabled | native button | **requires** `label` → `aria-label` + `title`; icon decorative |
| `button_group/1` | n/a | n/a (container) | children own keyboard | `role="group"`, optional `aria-label` |
| `link_text/1` | variant `default/subtle/quiet`; `external` | default, hover, focus, visited | native link | external → `rel="noopener noreferrer"`, `target="_blank"`, visually-hidden "(opens in new tab)" |

## 2. Field — `AuroraUI.Components.Field`

Docs: [`field.ex`](../lib/aurora_ui/components/field.ex) · Test:
`test/aurora_ui/field_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `field/1` | `required`/`optional` | invalid, required | wraps native control | derives deterministic label/help/error ids; passes `%{id, invalid, describedby, errormessage, required}` to slot |
| `input/1` | type `text/email/password/url/tel/number/search`; prefix/suffix; `show_count` | default, hover, focus, filled, disabled, readonly, invalid | native input | binds `Phoenix.HTML.FormField`; `aria-invalid`/`aria-describedby`/`aria-errormessage`; count is `aria-live="polite"`; affixes decorative |
| `textarea/1` | `rows`, `autosize`, `show_count` | default, focus, disabled, readonly, invalid | native textarea | same association model; `autosize` opt-in via `data-aui-autosize` (height works without JS) |
| `label/1` | `required`/`optional` | n/a | n/a | real `<label for>`; visually-hidden "required" text; `*` decorative |
| `help_text/1` | n/a | n/a | n/a | id referenced by `aria-describedby` |
| `field_error/1` | n/a | error | n/a | `role="alert"` so it announces when it appears |

## 3. Choices — `AuroraUI.Components.Choices`

Docs: [`choices.ex`](../lib/aurora_ui/components/choices.ex) · Test:
`test/aurora_ui/choices_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `checkbox/1` | `indeterminate` | default, hover, focus, checked, indeterminate, disabled, invalid | native checkbox (Space) | `aria-checked="mixed"` + dash for indeterminate; description wired via `aria-describedby`; 44px hit area |
| `radio_group/1` | `options` or `<.radio>` children | selected, disabled (whole group), invalid | native roving arrow keys / single-select | `fieldset`/`legend`, `role="radiogroup"`, `aria-describedby` |
| `radio/1` | per-option `description`/`disabled` | checked, disabled, invalid, focus | native radio | shares `name`; description via `aria-describedby` |
| `switch/1` | `label_on`/`label_off` | checked (on/off), disabled, focus, invalid | native checkbox | `role="switch"`; thumb animates, snaps under reduced motion |
| `segmented_control/1` | size `sm/md/lg`; `options` | selected, disabled | native radio arrow keys | `role="radiogroup"` of exclusive radios styled as one cluster |

*All animated affordances collapse to an instant state change under reduced motion.*

## 4. Selection — `AuroraUI.Components.Selection`

Docs: [`selection.ex`](../lib/aurora_ui/components/selection.ex) · Test:
`test/aurora_ui/selection_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `select/1` | size `sm/md/lg`; `prompt`; `options` | default, focus, disabled, invalid | native `<select>` (zero JS) | label `for/id`; `aria-invalid`/`aria-describedby`; custom chevron decorative |
| `combobox/1` | `options` or `<:option>` slots; `clearable` | default, focus, loading, open, disabled, invalid, empty | `AuroraCombobox` hook: Arrow/Enter/Escape/Home/End, typeahead, click-away, pointer | ARIA combobox+listbox; `aria-expanded/controls/autocomplete=list/activedescendant`; deterministic option ids; server-driven filtering; emits `aui:combobox:select/open/close/clear` |

## 5. Navigation — `AuroraUI.Components.Navigation`

Docs: [`navigation.ex`](../lib/aurora_ui/components/navigation.ex) · Test:
`test/aurora_ui/navigation_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `skip_link/1` | n/a | focus (revealed on focus) | native link; first focusable in doc | jumps to `#main` landmark |
| `navbar/1` | brand/link/actions slots; `current` | current (link) | native `<details>` mobile disclosure (zero JS) | `<nav aria-label>`; `aria-current="page"`; CSS opens panel + hides toggle on wide |
| `sidebar/1` + `sidebar_item/1` + `sidebar_group/1` | sections; collapsible groups | current, group open/closed | native `<details>` for groups | `<nav aria-label>`; `aria-current="page"`; group summary exposes expanded state |
| `breadcrumbs/1` | `<:crumb>` slots | current (last crumb) | native links | `<nav>` + `<ol>`; last crumb is plain `aria-current="page"`, never a link |
| `pagination/1` | `siblings`; `path` fn or `phx-*` | current, disabled (prev/next ends) | native links | `<nav>` + `<ol>`; truncated ranges with `…` gaps; disabled ends are non-focusable `aria-disabled` spans |
| `steps/1` | orientation `horizontal/vertical`; per-step `status` | complete, current, upcoming | n/a (status display) | `<nav>`+`<ol>`; `aria-current="step"`; visually-hidden "(completed)/(current step)"; RTL-safe logical props |

## 6. Tabs & disclosure — `AuroraUI.Components.Tabs`

Docs: [`tabs.ex`](../lib/aurora_ui/components/tabs.ex) · Test:
`test/aurora_ui/tabs_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `tabs/1` | `activation` `manual/auto`; orientation `horizontal/vertical` | selected, disabled (per tab), focus | `AuroraTabs`: roving tabindex, Arrow/Home/End; manual = select on Enter/Space, auto = on focus | WAI-ARIA tabs: `role=tablist/tab/tabpanel`, `aria-selected`, `aria-controls`, `aria-orientation`; **requires stable `id`**; selection survives patches |
| `accordion/1` | `type` `multiple/single`; per-item `open` | expanded/collapsed | native `<details>`/`<summary>` (zero JS) | `AuroraDisclosure` only animates + handles interruption; `single` uses native `<details name>`; find-in-page reveals collapsed content |

## 7. Overlays — `AuroraUI.Components.Overlay`

Docs: [`overlay.ex`](../lib/aurora_ui/components/overlay.ex) · Test:
`test/aurora_ui/overlay_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `dialog/1` | size `sm/md/lg/xl`; `dismissable` | open/closed | native `<dialog>`+`showModal()`; `AuroraDialog` traps focus, returns focus, Escape/backdrop close; scroll lock; body scrolls | `aria-modal`, `aria-labelledby`/`aria-describedby`; background `inert`; header/footer pinned |
| `alert_dialog/1` | size; `confirm_variant` `primary/danger` | open/closed | initial focus on Cancel (least destructive); **not** backdrop-dismissable; Escape → `on_cancel` | `role="alertdialog"`; requires confirm + cancel |
| `drawer/1` | `side` `start/end/top/bottom`; `modal` true/false; `dismissable` | open/closed | modal = trap+`inert`+backdrop; non-modal = `show()`, background interactive, no trap | `role="dialog"`, `aria-modal` reflects `modal`; exit transition plays before removal |

## 8. Floating — `AuroraUI.Components.Floating`

Docs: [`floating.ex`](../lib/aurora_ui/components/floating.ex) · Test:
`test/aurora_ui/floating_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `menu/1` | placement (4 corners); trigger variant/size; per-item `disabled`/`destructive` | open/closed, item disabled, focus | `AuroraMenu`: roving tabindex, Arrow/Home/End, first-letter typeahead, Escape, focus return | `role=menu`/`menuitem` (buttons, not links); `aria-haspopup=menu`, `aria-expanded`; collision-flip positioning |
| `popover/1` | placement `top/bottom/start/end`; trigger variant/size | open/closed, focus | native `popover` attr baseline (light-dismiss + top layer) + `AuroraPopover` positioning; Escape/outside-click close; focus into panel then return | `role="dialog"`, `aria-haspopup=dialog`, non-modal (page stays interactive) |
| `tooltip/1` | placement | shown/hidden | shows on hover **and** focus; Escape/blur hides | `role="tooltip"` referenced via `aria-describedby`; supplementary only — never the only label/instruction |

## 9. Feedback — `AuroraUI.Components.Feedback`

Docs: [`feedback.ex`](../lib/aurora_ui/components/feedback.ex) · Test:
`test/aurora_ui/feedback_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `alert/1` | variant `info/success/warning/danger/neutral`; `assertive`; `on_dismiss` | status (all severities), dismissable | dismiss is a real focusable button | **static** once-announced: `role="status"` (polite) / `role="alert"` (danger or assertive); severity carried by text/icon, not color alone |
| `toast_group/1` | `assertive` | n/a (region) | pause on hover/focus (hook) | the **one** streaming region; single `aria-live`; `role="region"` |
| `toast/1` | severity `info/success/warning/danger/neutral`; `timeout` (0 = persistent); `dedup_key`; `action` | success/warning/error/info/neutral, persistent, dismissable | `AuroraToast`: timers, pause-on-hover/focus, de-dup; dismiss button | list item in the region; `data-aui-timeout`/`data-aui-dedup-key`; critical errors → `timeout={0}` |
| `inline_status/1` | severity; `pulse` | ambient status | n/a | **no** live region — changes silently; dot decorative, label carries meaning |
| `connection_state/1` | labels; `hide_when_connected` | connected, connecting/reconnecting, disconnected/offline | n/a | `AuroraConnectionState` reflects socket → `data-aui-conn`; single polite region announced once; never steals focus or discards work |

## 10. Data display — `AuroraUI.Components.DataDisplay`

Docs: [`data_display.ex`](../lib/aurora_ui/components/data_display.ex) · Test:
`test/aurora_ui/data_display_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `card/1` | elevation `flat/sm/md`; `interactive`; `selected`; `loading` | default, hover, focus (interactive), selected, loading | interactive card = one stretched real `<a>` | `<article>`/`<section>`; `aria-current` when selected; **no nested interactive elements** in an interactive card (WCAG name/role trap) |
| `badge/1` | variant `neutral/info/success/warning/danger/accent`; size; `dot`; `removable` | default, removable | remove is a real labelled button | dot decorative |
| `avatar/1` | `src`/initials; size; shape `circle/square`; `status` `online/away/busy/offline` | image, initials fallback, status | n/a | `<img alt>` required with `src`; fallback `role="img"` keeps name; visually-hidden status text |
| `avatar_group/1` | `max`; overflow | n/a | children own tab order | `role="group"`, `aria-label` |
| `stat/1` | `trend` `up/down/flat`; `delta`; `loading` | default, loading | n/a | trend carried by caret glyph **and** hidden "increased/decreased" text, not color alone |
| `description_list/1` | `<:item term>` | n/a | n/a | real `<dl>`/`<dt>`/`<dd>`; responsive 2-col → stacked |

## 11. Data navigation — `AuroraUI.Components.DataNavigation`

Docs: [`data_navigation.ex`](../lib/aurora_ui/components/data_navigation.ex) ·
Test: `test/aurora_ui/data_navigation_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `table/1` | `responsive` `scroll/stack`; `selectable`; sortable columns; `loading` | default, loading (skeleton), empty, error, row selected | native table semantics; scroll region is focusable | `<table>`+`<caption>`+`<th scope>`; `aria-sort`; sort button emits `sort_event`+`phx-value-key`; selection emits `select_event`/`select_all_event`; bulk region `aria-live` |
| `data_grid/1` | `active_row`/`active_col` | active cell, editable/readonly | **application** model: Arrow/Home/End/Ctrl+Home/End, Enter/F2 edit, Escape cancel (via *your* `AuroraDataGrid` hook against `data-aui-grid`) | `role="grid"`, roving `tabindex` (server-authoritative active cell); `aria-readonly` on non-editable; use only for in-place editing |
| `filter_bar/1` | `count`/`count_unit`; `active?` | active/inactive, count | controls own keyboard | `role="search"`; count is polite `role="status"`; clear-all button |
| `filter_chip/1` | `remove_event` | removable | remove is a real labelled button | list item; `aria-label="Remove filter: <label>"` |
| `empty_state/1` | size; icon/actions | empty | actions own keyboard | `role="status"` so a freshly-loaded empty result is announced; icon decorative |

## 12. Loading / progress — `AuroraUI.Components.Progress`

Docs: [`progress.ex`](../lib/aurora_ui/components/progress.ex) · Test:
`test/aurora_ui/progress_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `spinner/1` | size `sm/md/lg` | busy | n/a | `role="status"` + visually-hidden `label`; **slows** (not stops) under reduced motion so it never reads frozen |
| `progress/1` | determinate/`indeterminate`; `show_value`; size | busy, determinate, indeterminate | n/a | `role="progressbar"`, `aria-valuenow/min/max` (determinate); indeterminate omits `aria-valuenow` |
| `skeleton/1` | shape `rect/text/circle/pill`; explicit `width`/`height` | loading | n/a | `aria-hidden`; reserves layout to prevent CLS; announce busy at a higher level |
| `async_state/1` | `state` `loading/empty/error/ok` | loading, empty, error, ok | branch content owns keyboard | renders one slot; loading = polite region, error = `role="alert"`; maps `AsyncResult` + streams |

## 13. Search / command — `AuroraUI.Components.Command`

Docs: [`command.ex`](../lib/aurora_ui/components/command.ex) · Test:
`test/aurora_ui/command_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `search_field/1` | size; `clearable`; `debounce`; `loading` | default, focus, loading, empty (clear hidden) | native `type=search`; clear button; Enter submits | `role="search"` landmark + `role="searchbox"`; `aria-busy`; always debounce live search |
| `search_results/1` | `count`; `group` slots; `empty` | results, empty, loading | native links | semantic `<ul role="list">` (not a listbox); polite visually-hidden count announcement |
| `search_result/1` | link or static; `active` | active/focus | native link (or `phx-click` row) | `<li>`; becomes `<a>` on `navigate/patch/href` |
| `command_palette/1` | `shortcut`; `open`; `group`/`empty` slots | open/closed, empty (filter) | `AuroraCommandPalette` (lazy → `command.js`): filter + keyboard; opened from **visible** trigger; shortcut discoverable/configurable/non-hijacking | `role="dialog"`+`aria-modal`; combobox input + `role="listbox"`; **requires stable `id`** |

## 14. Media / content — `AuroraUI.Components.Media`

Docs: [`media.ex`](../lib/aurora_ui/components/media.ex) · Test:
`test/aurora_ui/media_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `media/1` | `ratio`; `fit` `cover/contain`; `rounded`; `caption` | n/a | n/a | `<figure>`/`<figcaption>`; `aspect-ratio` reserves space (no CLS); **you** supply the child `<img alt>`; ratio value validated against injection |
| `gallery/1` | `min_item_width` | n/a | natural tab order of item links/controls | `<ul role="list">`; lightbox is out of scope (compose with `dialog`) |
| `code_block/1` | `language`/`filename`; `show_copy` | copy | scroll region focusable; copy button | `{@code}` HEEx-escaped (no raw-HTML path); `AuroraCopyButton` via `data-aui-copy-target`; `language-*` class for highlighters |
| `prose/1` | n/a | n/a | n/a | constrains to `--aui-measure`; scoped so styles don't leak |
| `callout/1` | variant `note/tip/warning/danger`; `title` | tone/severity | n/a | `<aside>` labelled by `title`; variant icon decorative; color from status tokens |

## 15. Experience — `AuroraUI.Components.Experience`

Docs: [`experience.ex`](../lib/aurora_ui/components/experience.ex) · Test:
`test/aurora_ui/experience_test.exs`

| Component | Key variants | States covered | Keyboard / touch | ARIA / semantic notes |
|---|---|---|---|---|
| `reveal/1` | `as` tag; `stagger` | pre-JS visible → revealed | content usable without JS/pointer | `AuroraReveal`; hidden/animated state gated on `data-aui-hook="ready"`; reduced motion → plain fade |
| `stagger/1` | `as` tag | children reveal in sequence | same | `AuroraReveal` + `data-aui-stagger`; per-child `--aui-i`; stagger → 0ms under reduced motion |
| `spotlight/1` | `as` tag | pointer glow active/inactive | keyboard/touch lose nothing (decorative) | `AuroraSpotlight` publishes `--aui-mx/--aui-my`; behind content, never intercepts pointer; off under reduced motion |
| `tilt/1` | `max_deg`; `as` tag | hover tilt | pointer-only; touch/keyboard get full content, no tilt | `AuroraTilt` (lazy → `motion.js`); `data-aui-tilt="off"` disables a subtree; off under reduced motion |
| `scene_host/1` | `scene`; `dpr_cap`; `pause_offscreen`; `fallback`+`semantic` slots | static fallback → scene ready; no-WebGL/no-JS/reduced-motion → fallback | n/a (decorative 3D) | `AuroraSceneHost` (lazy → `three/scene.js`); always-present `semantic` slot conveys the same info; capability-gated; pause/resize/context-recovery/disposal |
| `fade_in/2`, `slide_up/2`, `scale_in/2` | `:to`, `:time` opts | enter animation | n/a | return `%Phoenix.LiveView.JS{}` for `phx-mounted`; reduced motion handled in CSS |
