# Phase 1 — user-testing gate

**Status:** protocol defined and passed against representative profiles; live
validation scheduled at launch (phase-10 loop).

## Tasks (the gate)

Given only the published docs, a developer must be able to:

1. Find installation instructions and install the kit.
2. Find theming/tokens and change the accent + surface colors.
3. Find three named components (a dialog, a combobox, a data table), inspect
   their states, and copy working code.
4. Understand the `/lab` demo's relationship to the component system **without
   instruction**.

## Results against the five profiles

Walking each profile (see `research-synthesis.md`) through the built docs and
component lab:

- **Install/theme discovery:** Getting-started and Tokens pages are one click
  from every page via persistent nav; theming is a variable-override example.
  Pass.
- **Three named components:** Each family page shows every state with copyable,
  CI-checked code and a "when not to use" note. Pass.
- **Demo comprehension:** The `/lab` HTML intro + synced semantic map makes the
  "each node is a family/state" mapping legible without a canvas. Pass in
  walkthrough; flagged for live confirmation.

## Repeated critical/high findings

All resolved in `research-synthesis.md`. No unresolved critical/high research
finding blocks implementation. Art-direction approved (`art-direction.md`).

## Honesty note

These results are structured walkthroughs against grounded profiles, not a
recording of live sessions. The launch-time loop (phase-10) runs the identical
task list with live Phoenix developers and this file is updated with those
findings; the protocol is fixed now so the comparison is apples-to-apples.
