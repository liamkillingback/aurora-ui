# Phase 7 — example application & integration proofs

## The example is a real, coherent product

The `demo/` app includes an example product — a small **project dashboard**
("Nimbus") — rather than an unconnected component gallery. It exercises, in one
connected flow: an auth-style form, responsive navigation, a dashboard/data view,
filters + table, command search, dialog/drawer, toast/error handling, async
LiveView state (assign_async/streams), offline/reconnect, theme switching, an RTL
locale, and the complete experience scene. Sample data is in-memory
(`Demo.Sample`) with a deterministic reset; there are no real credentials or
production services.

## Installation proof (the path dependency)

`demo/` depends on the library via `{:aurora_ui, path: ".."}` — the same public
surface a Hex consumer uses:

- CSS imported once in `assets/css/app.css` (`@import ".../aurora_ui.css"`).
- Hooks registered in `assets/js/app.js` (`import { AuroraHooks }`,
  `hooks: { ...AuroraHooks }`).
- Components available via `use AuroraUI` in `DemoWeb`.

This proves the documented install story compiles and runs in a real Phoenix 1.8
/ LiveView 1.2 app: `mix compile` + `mix assets.build` succeed and the app boots.

## Consumer build concerns covered

- **Tailwind scanning / asset build:** the library ships static CSS (no utility
  purge dependency), so Tailwind's `content` config cannot strip Aurora styles;
  the demo's `mix assets.build` produces a working CSS + JS bundle.
- **Dark mode:** driven by `data-aui-theme` on `<html>`; the demo's theme toggle
  flips it live with no recompile.
- **LiveView reconnect:** the connection indicator + state-preserving hooks are
  exercised on the dashboard.
- **CSP:** the scene uses only same-origin assets + WebGL (no eval/remote fetch);
  documented in `docs/troubleshooting.md`.

## Configurability proof (disable motion / scene)

Setting the reduced-motion preference (or the demo's motion toggle) and disabling
the scene both leave the core app compiling, testing, and retaining an intentional
equivalent experience — the static/semantic fallbacks render server-side. A build
that imports only a button contains none of the overlay/command/motion/Three.js
code (bundle-composition proof, phase-08).

## Removal / copy proof

Each family has a "copy this component" recipe that preserves the MIT notice and
accessibility behavior (`docs/recipes.md`), so a consumer can vendor a component
and drop the dependency — the documented alternative to the package path
(ADR-0001/0002).

## Install measurement

Exact steps: (1) add dep, (2) import CSS, (3) register hooks, (4) `use AuroraUI`.
Typical first-render time: minutes. Common failure messages and their fixes are
catalogued in `docs/troubleshooting.md`.

**Exit gate:** a developer unfamiliar with the repo can build one form, one
overlay, and one data interaction from the published docs; clean integration +
removal are exercised by the demo and the copy recipes. **Go.**
