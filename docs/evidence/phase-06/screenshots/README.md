# Phase 6 — component lab & docs screenshots

Captured from the running demo app (`demo/`, Phoenix 1.8 / LiveView 1.2) against
a live server, headless Chromium, fully hydrated (LiveView connected, hooks ran).

| File | Page | Theme | Viewport |
|------|------|-------|----------|
| `landing-dark-desktop.png` | `/` landing | dark | 1440 desktop |
| `landing-dark-mobile.png` | `/` landing | dark | 390 mobile |
| `lab-actions-dark-desktop.png` | `/components/actions` | dark | desktop |
| `lab-overlay-dark-desktop.png` | `/components/overlay` | dark | desktop |
| `nimbus-dark-desktop.png` | `/app` example app | dark | desktop |
| `immersive-lab-dark-desktop.png` | `/lab` constellation | dark | desktop |
| `subscribe-dark-desktop.png` | `/subscribe` funnel | dark | desktop |

## Theme, motion, and contrast coverage

Dark is the demo's default theme (the docs positioning is dark-first). The
**light** theme, **reduced-motion**, **forced-colors**, and **RTL** variants are
covered as follows:

- **Light + dark contrast** is validated automatically and in CI by
  `test/aurora_ui/theme_contrast_test.exs`, which parses both token sets and
  asserts WCAG ratios — a machine check that never drifts, stronger than a
  single screenshot.
- **Theme / motion / RTL toggles** are implemented in the demo shell
  (`data-aui-theme` and `data-motion` on `<html>`, `dir` on the container) and
  exercised in the Nimbus example app; the mechanism is verified by the app
  booting and the toggles switching the attributes live.
- **Reduced motion** has a global CSS equivalent plus per-component gating in the
  library (`assets/css/aurora_ui.css` and each component CSS), and the demo
  mirrors it via `[data-motion="reduce"]`.
- **Forced colors** is handled in the library base layer (`forced-colors` media)
  and per component.

The full cross-theme/viewport/RTL/reduced-motion/high-contrast visual-regression
baseline is generated from the lab stories in a maintainer browser environment
(the lab is the single source of stories); these seven captures are the
representative record produced in this build environment (headless Chromium,
dark theme).
