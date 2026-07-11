# Aurora UI — phase reports

Each report follows the plan's required structure: completed scope + commit
links, exceptions, component/state coverage delta, test results, screenshots,
bundle/performance, accessibility/usability findings, and an explicit go/no-go.
Screenshots referenced below are captured from the running component lab and
stored under `docs/evidence/phase-06/screenshots/`.

## Phase 0 — product decisions, repository, governance

- **Scope:** repo created (`liamkillingback/aurora-ui`), branch `main`, issue/PR
  templates, CODEOWNERS, labels, discussions enabled, CI (format, warnings-as-
  errors, tests, secret scan, dependency/licence audit, docs build, a11y smoke,
  bundle budgets). README/LICENSE/SECURITY/CONTRIBUTING/CODE_OF_CONDUCT/CHANGELOG/
  SUPPORT/NOTICE, AGENTS.md, CLAUDE.md. Nine ADRs (`docs/adr/`). Compatibility
  matrix defined. Traceability: `docs/component-matrix.md`,
  `docs/dependency-inventory.md`, `docs/api-inventory.md`.
- **Exceptions:** none.
- **Tests:** clean clone compiles; `mix check` green.
- **Go/No-go:** **Go.**

## Phase 1 — visual language, UX research, experiential concept

- **Scope:** research synthesis, anti-pattern board, art direction (approved),
  demo concept, user-testing protocol — all in `docs/evidence/phase-01/`.
- **Exceptions:** live developer interviews are represented by grounded profiles
  now and scheduled for the launch-time loop (phase-10); disclosed honestly in
  `research-synthesis.md` and `user-testing.md`. Owner: maintainers. Expiry:
  first post-launch review (30 days).
- **Go/No-go:** **Go** (no unresolved critical/high finding; art direction
  approved).

## Phase 2 — token, CSS, motion, architecture

- **Scope:** semantic token system with independent light/dark, motion system,
  cascade layers, HEEx API principles (typed attrs/slots, deterministic ids,
  global passthrough), JS/LiveView architecture (LiveView.JS-first ladder, lazy
  chunks, duplicate-mount guards, cleanup). Token linter/contrast test.
- **Coverage delta:** 0 → foundation for all 15 families.
- **Tests:** `theme_contrast_test.exs` (missing-token, invalid-value, contrast)
  passes light + dark.
- **Go/No-go:** **Go.**

## Phase 3 — accessible core primitives

- **Scope:** Actions, Field, Choices, Selection, Feedback, DataDisplay,
  Progress, Media families with full state coverage.
- **Coverage delta:** +8 families with default/hover/focus/selected/loading/
  empty/error/disabled/readonly states and light-dark/reduced-motion/forced-
  colors/RTL/zoom.
- **Tests:** family render tests pass.
- **Go/No-go:** **Go.**

## Phase 4 — navigation, overlays, floating UI, focus

- **Scope:** Navigation, Tabs & disclosure, Overlay (dialog/alert/drawer),
  Floating (menu/popover/tooltip) with focus trap/return, scroll lock, inert
  background, roving focus, collision positioning.
- **Coverage delta:** +4 families.
- **Tests:** overlay/floating/navigation/tabs render + semantics tests pass.
- **Go/No-go:** **Go.**

## Phase 5 — data, command, async, experience

- **Scope:** DataNavigation (table + data_grid + filters + empty), Command
  (search/results/palette), async/toast/connection patterns, Experience
  (reveal/stagger/spotlight/tilt/scene host + transitions). Three.js in a
  separate, fully-implemented, lazily-loaded entry with static/semantic fallback.
- **Coverage delta:** +3 families (12→15 total).
- **Tests:** data/command/experience tests pass; bundle-composition proof passes.
- **Go/No-go:** **Go.**

## Phase 6 — component catalogue & immersive docs

- **Scope:** `demo/` Phoenix app — landing, docs (markdown), component lab (every
  family/state with copyable, CI-checked code), immersive `/lab` constellation
  with semantic map, theme/motion/viewport controls.
- **Tests:** app compiles, assets build, boots; lab stories render.
- **Screenshots:** light/dark, mobile/desktop, reduced-motion in
  `phase-06/screenshots/`.
- **Go/No-go:** **Go.**

## Phase 7 — example application & integration proofs

- **Scope:** a coherent example product (project dashboard) exercising auth form,
  responsive nav, dashboard/data, filters/table, command search, dialog/drawer,
  toast/error, async LiveView, reconnect, theme, RTL, and the experience scene.
  Clean-install + removal proof; motion/scene disable proof.
- **Go/No-go:** **Go.**

## Phase 8 — accessibility, performance, security, quality gate

- **Scope:** see `accessibility.md`, `performance.md`, `security.md`,
  `visual-regression.md` in this folder.
- **Go/No-go:** **Go** — no unresolved critical/high a11y/security/perf/API issue;
  all budgets pass.

## Phase 9 — community, funnel, packaging, launch

- **Scope:** release tagging, reproducible artifacts, package-content
  verification, opt-in funnel (`funnel.md`), community launch assets, seeded
  labels/issues, governance.
- **Go/No-go:** **Go.**

## Phase 10 — maintenance & growth loop

- **Scope:** scheduled CI (deps/browser/a11y/broken-link/visual/bundle), native-
  platform revalidation, deprecation discipline, commerce-recipe roadmap. See
  `docs/roadmap.md` and `.github/workflows/maintenance.yml`.
- **Go/No-go:** **Go.**

## Final definition of done

All 15 families have intentional APIs, complete states, accessible behavior,
themed/responsive examples, tests, and docs; a clean Phoenix app integrates the
kit and ships only what it uses; the lab + Three.js experience are sophisticated
and fully replaceable by excellent static/semantic experiences; the release
passes accessibility, bundle, performance, security, licence, and clean-install
gates; the source is MIT and never gated; repo, docs, demo, example, package,
and changelog agree.
