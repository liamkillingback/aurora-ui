# Changelog

All notable changes to Aurora UI are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Aurora UI's public API is the set of documented `AuroraUI.Components.*` function
components, their attributes/slots, the `--aui-*` CSS custom-property contract,
and the registered JavaScript hook names/DOM contract. Internal modules
(`AuroraUI.Internal`) may change without notice.

## [Unreleased]

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

[Unreleased]: https://github.com/liamkillingback/aurora-ui/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/liamkillingback/aurora-ui/releases/tag/v0.1.0
