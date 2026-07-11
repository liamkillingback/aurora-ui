# API inventory

The public API surface of Aurora UI, plus the **API-change review template** a PR
fills in whenever it changes a public attr, slot, token, or hook name.

Per [compatibility.md](compatibility.md) and
[ADR-0008](adr/0008-versioning-and-support.md), the public API under SemVer is:

1. the documented `AuroraUI.Components.*` function components and their
   attributes/slots (listed below),
2. the `--aui-*` token contract ([tokens.md](tokens.md)), and
3. the registered JavaScript hook names + DOM contract
   ([`../AGENTS.md`](../AGENTS.md), [liveview.md](liveview.md)).

`AuroraUI.Internal` and any private component are **excluded** — they may change
without a deprecation window.

## Top-level module — `AuroraUI`

| Function / macro | Arity | Purpose |
|---|---|---|
| `AuroraUI.__using__/1` | macro | `use AuroraUI` imports all 15 family modules into `html_helpers/0`. |
| `AuroraUI.version/0` | 0 | Returns the installed version string. |

## Public function components (per family)

Every entry is a `Phoenix.Component` function of **arity 1** unless noted. Attrs
and slots for each are documented in the module source (linked) and summarized in
the [component matrix](component-matrix.md).

### Actions — [`AuroraUI.Components.Actions`](../lib/aurora_ui/components/actions.ex)

- `button/1`
- `icon_button/1`
- `button_group/1`
- `link_text/1`

### Field — [`AuroraUI.Components.Field`](../lib/aurora_ui/components/field.ex)

- `field/1`
- `input/1`
- `textarea/1`
- `label/1`
- `help_text/1`
- `field_error/1`

### Choices — [`AuroraUI.Components.Choices`](../lib/aurora_ui/components/choices.ex)

- `checkbox/1`
- `radio_group/1`
- `radio/1`
- `switch/1`
- `segmented_control/1`

### Selection — [`AuroraUI.Components.Selection`](../lib/aurora_ui/components/selection.ex)

- `select/1`
- `combobox/1`

### Navigation — [`AuroraUI.Components.Navigation`](../lib/aurora_ui/components/navigation.ex)

- `skip_link/1`
- `navbar/1`
- `sidebar/1`
- `sidebar_item/1`
- `sidebar_group/1`
- `breadcrumbs/1`
- `pagination/1`
- `steps/1`

*(`page_items/3` exists but is `@doc false` — an internal helper, not part of the
public API.)*

### Tabs & disclosure — [`AuroraUI.Components.Tabs`](../lib/aurora_ui/components/tabs.ex)

- `tabs/1`
- `accordion/1`

### Overlays — [`AuroraUI.Components.Overlay`](../lib/aurora_ui/components/overlay.ex)

- `dialog/1`
- `alert_dialog/1`
- `drawer/1`

### Floating — [`AuroraUI.Components.Floating`](../lib/aurora_ui/components/floating.ex)

- `menu/1`
- `popover/1`
- `tooltip/1`

### Feedback — [`AuroraUI.Components.Feedback`](../lib/aurora_ui/components/feedback.ex)

- `alert/1`
- `toast_group/1`
- `toast/1`
- `inline_status/1`
- `connection_state/1`

### Data display — [`AuroraUI.Components.DataDisplay`](../lib/aurora_ui/components/data_display.ex)

- `card/1`
- `badge/1`
- `avatar/1`
- `avatar_group/1`
- `stat/1`
- `description_list/1`

### Data navigation — [`AuroraUI.Components.DataNavigation`](../lib/aurora_ui/components/data_navigation.ex)

- `table/1`
- `data_grid/1`
- `filter_bar/1`
- `filter_chip/1`
- `empty_state/1`

### Loading / progress — [`AuroraUI.Components.Progress`](../lib/aurora_ui/components/progress.ex)

- `spinner/1`
- `progress/1`
- `skeleton/1`
- `async_state/1`

### Search / command — [`AuroraUI.Components.Command`](../lib/aurora_ui/components/command.ex)

- `search_field/1`
- `search_results/1`
- `search_result/1`
- `command_palette/1`

### Media / content — [`AuroraUI.Components.Media`](../lib/aurora_ui/components/media.ex)

- `media/1`
- `gallery/1`
- `code_block/1`
- `prose/1`
- `callout/1`

### Experience — [`AuroraUI.Components.Experience`](../lib/aurora_ui/components/experience.ex)

Function components:

- `reveal/1`
- `stagger/1`
- `spotlight/1`
- `tilt/1`
- `scene_host/1`

`Phoenix.LiveView.JS` transition helpers (for `phx-mounted` etc.):

- `fade_in/2` — `fade_in(js \\ %JS{}, opts \\ [])`
- `slide_up/2` — `slide_up(js \\ %JS{}, opts \\ [])`
- `scale_in/2` — `scale_in(js \\ %JS{}, opts \\ [])`

## Registered JavaScript hooks (public names)

Part of the public API under SemVer. DOM contract in
[`../AGENTS.md`](../AGENTS.md); registration in
[`../assets/js/index.js`](../assets/js/index.js).

**Eager core:** `AuroraDialog`, `AuroraDrawer`, `AuroraPopover`, `AuroraMenu`,
`AuroraTooltip`, `AuroraTabs`, `AuroraDisclosure`, `AuroraToast`, `AuroraReveal`,
`AuroraSpotlight`, `AuroraConnectionState`, `AuroraCopyButton`.

**Lazy wrappers (dynamic-import on mount):** `AuroraCombobox` → `command.js`,
`AuroraCommandPalette` → `command.js`, `AuroraTilt` → `motion.js`,
`AuroraSceneHost` → `three/scene.js`.

Renaming or removing any of these names — or changing the `data-aui-*` DOM
contract — is a **breaking** change and follows the deprecation window.

## Token contract

The full `--aui-*` token list is the third public surface; see
[tokens.md](tokens.md). Removing or renaming a token is breaking.

---

## API-change review template

Copy this into any PR that changes a public attr, slot, token, or hook name/DOM
contract. (Referenced from [`../CONTRIBUTING.md`](../CONTRIBUTING.md) and the PR
template.) If the change touches only `AuroraUI.Internal`, private components,
undocumented DOM, or the demo app, note that and skip the rest.

```markdown
### API-change review

**1. What changed?**
- Component(s) / hook(s) / token(s):
- Precisely what changed (attr/slot/token/hook name, default, allowed `values`,
  DOM attribute, slot arg shape):
  - Before:
  - After:

**2. Which public surface does it touch?** (check all)
- [ ] `AuroraUI.Components.*` attr/slot
- [ ] `--aui-*` token contract
- [ ] Hook name or `data-aui-*` DOM contract
- [ ] None (Internal / private / demo only) — explain and stop here.

**3. Is it breaking?** (SemVer)
- [ ] Additive only (new attr/slot/token/hook, or a wider `values` set) → MINOR
- [ ] Bug fix, no contract change → PATCH
- [ ] Breaking (removed/renamed/narrowed/changed default/DOM change) → needs
      deprecation + eventual MAJOR (or removal a minor after deprecation)

**4. Deprecation plan** (required if breaking)
- Old API kept working for ≥ 1 minor: [ ] yes  (version deprecated in: ___)
- Compile-time warning added (attrs/slots): [ ] yes / [ ] n/a
- Earliest removal version:

**5. Migration note**
- What a consumer must change, with a before/after snippet:
- Codemod snippet provided (if feasible for a markup change): [ ] yes / [ ] n/a

**6. Changelog entry**
- Added under the correct heading (Added / Changed / Deprecated / Removed / Fixed)
  in `CHANGELOG.md`: [ ] yes

**7. Docs & traceability updated**
- [ ] Module `@doc`/`@moduledoc` and `## Examples`
- [ ] `docs/component-matrix.md` row
- [ ] `docs/api-inventory.md` (this file)
- [ ] `docs/tokens.md` (if a token changed)
- [ ] `AGENTS.md` hook table (if the DOM contract changed)

**8. Tests**
- [ ] `test/aurora_ui/<family>_test.exs` updated to assert the new semantics
- [ ] Accessibility unaffected or improved (focus/ARIA/keyboard/reduced-motion)
```
