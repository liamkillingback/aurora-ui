# Phase 1 — anti-pattern reference board

The explicit list of things Aurora UI refuses to do. Each has a rule and the
mechanism that enforces it.

| Anti-pattern | Why it's bad | Aurora UI rule & enforcement |
|---|---|---|
| Generic default styling | Reads as "unstyled Bootstrap"; no craft | Art direction with intentional spatial/kinetic language; every component designed, not defaulted |
| Incomplete states | Users hit hover-only components that break on error/loading | Definition-of-done requires every applicable state; matrix in `docs/component-matrix.md` |
| Inaccessible overlays | Focus escapes, no return, no escape, background not inert | Native `<dialog>` + focus-return/scroll-lock/inert hook; keyboard + SR test matrix (phase-08) |
| JavaScript-heavy primitives | Bundle bloat, framework lock-in, breaks with JS off | LiveView.JS first; small colocated hooks; heavy features lazy-split; no-JS baselines |
| Animation without meaning | Distracting, harms performance and motion-sensitive users | Motion system: named, purposeful, interruptible, reduced-motion-equivalent; "avoid" list in `docs/motion.md` |
| Inscrutable class APIs | `class="btn btn-primary btn-lg btn-block"` guessing games | Typed attrs with finite `values:`; no stringly-typed style prop |
| Hard-to-remove branding | Consumer app ends up looking like the vendor | Brand-neutral `--aui-*` tokens; demo brand tokens live only in `demo/`, never the library |
| Variant explosion | 40 button variants nobody can choose between | Few meaningful variants; consumer classes/tokens for the long tail |
| `phx-update="ignore"` on whole components | Dodges real LiveView integration; state desync | Prohibited in `AGENTS.md`; hooks own narrow DOM boundaries only |
| Continuous background motion | Battery/CPU drain, distraction | No continuous motion by default; scenes pause offscreen/hidden |
| Scroll hijacking / cursor replacement / focus-moving animation | Breaks user agency and AT | Explicitly banned in the motion "avoid" list |
| Email-gated source | Hostile to the open-source promise | Source MIT, never gated; funnel opt-in only (ADR-0009) |
