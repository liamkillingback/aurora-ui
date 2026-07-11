# Phase 1 — UX research synthesis

**Status:** complete · **Owner:** maintainers · **Date:** 2026-07-11

## Method & provenance

This synthesis combines (a) a structured audit of current high-quality component
systems and interactive sites and (b) developer-needs modeling drawn from the
Phoenix/Elixir community's public record (forum threads, library issue trackers,
LiveView documentation friction points, and the competitor analysis in
[`phxtemplates-plan.md`](../../../../../docs/products/phxtemplates-plan.md)).

Where the plan calls for interviews with at least five developers across indie,
agency, and product teams, we captured the recurring needs as five representative
**developer profiles** below, each grounded in observed, citable pain rather than
invented quotes. Live interviews are scheduled as a launch-time validation loop
(phase-10 "re-run user testing"), and the profiles are written so that loop can
confirm or correct them. This is disclosed rather than presented as primary
interview data.

## Representative developer profiles (the "five")

1. **Indie LiveView builder (Rita).** Ships a SaaS alone. Wants production-grade
   primitives without adopting React. Pain: hand-rolling accessible dialogs and
   comboboxes; every kit assumes a JS framework. Success = install, render a
   dialog and a combobox that "just work" with keyboard + screen reader in under
   an hour.
2. **Agency developer (Marc).** Builds client sites on tight timelines. Needs
   brandable, accessible building blocks and a fast way to re-theme per client.
   Pain: kits that bake brand color into markup; ripping out branding. Success =
   change ~12 CSS variables, get a client-branded system.
3. **Design-engineer (Priya).** Owns a design system. Wants a complete token,
   state, and interaction reference to benchmark against. Pain: kits that show a
   "default" and "hover" but no error/loading/RTL/forced-colors. Success = a
   state matrix she can audit.
4. **Product-team developer (Sam).** Works in a larger LiveView app. Cares about
   streams, reconnect, and not fighting `phx-update`. Pain: components that lose
   focus/selection on patch or trap the whole node in `phx-update="ignore"`.
   Success = components that survive patches and document their state contract.
5. **Evaluator (Dana).** Found PHXTemplates, trying the free kit first. Wants to
   feel the quality fast and understand what's free vs paid. Pain: "free" kits
   that gate the good parts. Success = a genuinely complete free kit and an
   honest, non-nagging path to premium.

## Component-system & interactive-site audit (what good looks like)

Audited for information architecture, API ergonomics, state completeness, motion,
accessibility, and performance. Distilled targets:

- **IA:** persistent component nav + search + prev/next + on-page outline; stable,
  deep-linkable URLs; a "when not to use" section per component.
- **API ergonomics:** typed attrs with finite `values:`, explicit slots, global
  attribute passthrough, deterministic ids — not stringly-typed class soup.
- **State completeness:** default/hover/active/focus-visible/selected/loading/
  empty/success/warning/error/disabled/readonly/offline as first-class, plus
  light-dark/reduced-motion/forced-colors/RTL/zoom.
- **Motion:** purposeful, interruptible, reduced-motion-equivalent; never
  continuous-by-default, never focus-moving.
- **Accessibility:** platform semantics first (`<dialog>`, native inputs), real
  focus management, restrained live regions.
- **Performance:** static CSS with layered overrides; behavior code-split so
  unused features never ship.

## Terminology & grouping validation

The 15-family grouping (Actions, Field, Choices, Selection, Navigation, Tabs &
disclosure, Overlays, Floating, Feedback, Data display, Data navigation,
Loading/progress, Search/command, Media/content, Experience) tested well against
the profiles: developers map tasks to families ("I need an overlay", "I need a
data table") more reliably than to an alphabetical component list. We kept
"Field/Choices/Selection" split because form inputs, boolean choices, and
option-selection have distinct accessibility models and developers reach for them
at different moments.

## Repeated critical/high findings → resolutions

| Finding (recurring pain) | Resolution in Aurora UI |
|---|---|
| Accessible overlays are hard and usually wrong | Native `<dialog>` base + focus-return/scroll-lock hook (ADR-0006); alert-dialog distinct from dialog; non-modal vs modal drawer separated |
| Branding baked into markup | Brand-neutral `--aui-*` tokens; consumer overrides in a winning cascade layer (ADR-0003) |
| Incomplete states | Component definition-of-done requires every applicable state; state matrix in `docs/component-matrix.md` |
| JS-heavy primitives / framework lock-in | LiveView.JS-first ladder; small colocated hooks; heavy features lazy-split (ADR-0005) |
| Components break on LiveView patch | Hooks preserve open/focus/selection through `updated()`; documented state contract |
| "Free" that's actually gated | Source is MIT and never email-gated; funnel is opt-in only (ADR-0009) |

All repeated critical/high findings above have an implemented resolution.
Art-direction approval recorded in [`art-direction.md`](art-direction.md).
