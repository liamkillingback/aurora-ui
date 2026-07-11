# Phase 9 — community launch assets

## Repository presentation

- **Social preview:** dark hero with the Aurora wordmark, tagline "A free
  Phoenix LiveView + Tailwind UI kit", and "15 accessible component families".
  (Set via repo Settings → Social preview; source in `docs/brand/`.)
- **Description + topics:** set on the repo (`phoenix`, `liveview`, `elixir`,
  `tailwindcss`, `ui-kit`, `accessibility`, `design-system`, `wcag`,
  `open-source`).
- **Pinned:** README quick-start + link to the docs/lab.

## Launch article (outline — truthful, no overclaiming)

Title: *"Aurora UI: a genuinely free, accessible Phoenix component kit"*

1. Why another kit — the gaps we kept hitting (accessible overlays, removable
   branding, no framework lock-in).
2. What it is — 15 families, tokens, LiveView-first, lazy 3D.
3. Show, don't tell — the component lab + the "inside the system" demo.
4. Accessibility as a feature, not a footnote (WCAG 2.2 AA, the state matrix).
5. Pay only for what you render — the bundle story.
6. How it's free and sustainable — MIT source, optional newsletter, PHXTemplates
   funds it. No gate.
7. Install in 3 steps; contribute; roadmap.

## Short demo video (script, ~90s, truthful)

1. (0–15s) Install: add dep, import CSS, register hooks.
2. (15–45s) Render a dialog + form + toast; tab through it with a keyboard;
   toggle dark mode live via a token override.
3. (45–70s) Open the component lab; flip a component through its states; copy
   code.
4. (70–90s) The `/lab` constellation; then disable motion and show the designed
   static fallback. End on the repo URL.

No staged results; everything shown is the real app.

## Announcement channels (each with its own rules)

- PHXTemplates blog + newsletter.
- Elixir Forum (Libraries), r/elixir, Elixir Slack #libraries — following each
  community's self-promotion rules.
- Relevant newsletters (Elixir Weekly, Elixir Radar) via their submission forms.
- **Do not** solicit endorsements from named individuals without an existing
  relationship and permission.

## Seeded issues (labels created)

`good first issue`, `component request`, `accessibility`, `docs`, `help wanted`,
plus `needs-triage`/`priority`/`security`. Seed a handful of clearly-labeled
beginner/component/a11y/docs issues at launch.

## Governance for external contributions

Response targets (`SUPPORT.md`), triage labels, security contact
(`SECURITY.md`), release cadence + deprecation window (ADR-0008), CODEOWNERS
review. Maintainers can reproduce, roll back, and support the release
(`docs/evidence/phase-09/packaging.md`).
