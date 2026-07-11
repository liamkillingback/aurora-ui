# Phase 1 — "inside the system" demo concept

## Concept

A **component constellation**: a spatial field where each node is a real
component family and its satellites are that family's key states. Moving through
the field is moving through the system — hovering a node emphasizes it and
reveals its states; selecting it navigates into that family's documentation.
Depth, lighting, and responsive motion reinforce the kit's structure; it is not
a decorative background unrelated to content.

## Semantic-first, canvas-optional

The constellation is authored as a **semantic list/grid first**: an ordered,
labeled map of families and states that is fully usable with no canvas, no JS,
and a screen reader. The Three.js scene is an enhancement layered over that same
data. Hover/focus/selection in the semantic list drives scene emphasis, so the
two are always in sync and either can be used alone.

## Fallback ladder (all intentionally designed)

| Condition | Experience |
|---|---|
| Full capability | 3D constellation + synced semantic map |
| Reduced motion | Static, well-composed constellation still (no travel); semantic map fully interactive |
| Touch / single-pointer | Tap a node → detail; no hover dependency |
| Keyboard | Roving focus through the semantic map; Enter navigates |
| Screen reader | The semantic map is the primary UI; scene is `aria-hidden` |
| Data-saver / low-power / low-capability | Static image/CSS composition; no WebGL init |
| No-JS | Server-rendered semantic map |
| Print | Semantic map, ink-friendly |
| Unsupported browser / WebGL absent / context lost | Designed static fallback, never a blank gradient or apology |

## Guardrails

- The demo never obscures install commands, component navigation, or primary
  content. Install + nav are always visible outside the canvas.
- DPR/complexity capped; scene pauses offscreen and when the tab is hidden;
  disposes on navigation; recovers from context loss. Budgets in phase-08.
- The heaviest intended scene configuration is prototyped and validated on
  low/mid/high device classes before it is committed as default (recorded in
  phase-06 evidence).

## Relationship to the component system (user-legible)

The `/lab` intro is a short HTML paragraph stating plainly: "Each point is a
component family; each cluster around it is a state you can use today. Select one
to read its docs." User testing (below) checks that visitors understand this
relationship without instruction.
