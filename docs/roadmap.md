# Roadmap & contribution priorities

Aurora UI does not publish dated feature promises. Everything in the 0.1 build
plan already ships ([ADR-0008](adr/0008-versioning-and-support.md) is a
support/compatibility policy, not a staged feature plan). What this page *does*
describe is how we decide **what to work on next** — the living priorities that
order incoming component and feature requests.

Think of this as a prioritization rubric, not a timeline.

## How requests are prioritized

Every component request, feature request, and improvement is weighed against four
factors (also summarized in [`../SUPPORT.md`](../SUPPORT.md)):

1. **Observed demand.** Real, repeated pull from issues, discussions, and usage —
   not hypothetical completeness. A pattern many people are hand-rolling beats a
   rarely-needed variant.
2. **Accessibility risk.** How likely people are to get this wrong on their own,
   and how badly it fails users when they do. High-risk patterns (focus
   management, live regions, complex keyboard models) are worth shipping precisely
   because they are hard to do correctly — accessibility and security regressions
   are always triaged **ahead of** new visual variants.
3. **Maintenance cost.** The ongoing burden a feature adds: bundle weight, a new
   runtime dependency (which requires an ADR — [ADR-0006](adr/0006-native-platform-apis.md)),
   cross-browser surface, and test matrix. Cheap-to-maintain, high-leverage work
   is favored.
4. **Premium relevance.** Whether the work also strengthens the paid PHXTemplates
   starters built on the same design language. This keeps the free kit
   sustainably funded — but it is a *tiebreaker*, never a reason to withhold
   something the free kit needs. The source is free forever
   ([`../SUPPORT.md`](../SUPPORT.md)).

These factors are held in tension; a request strong on demand and accessibility
but heavy on maintenance still gets serious consideration, just with a design that
manages the cost.

## Standing priorities

These are the kinds of contribution we actively want, ordered by how eagerly we
take them:

1. **Accessibility fixes and audits** for existing components — always first.
2. **Bug fixes** and cross-browser/RTL/zoom/forced-colors corrections.
3. **Docs and recipes** — real-world patterns
   ([recipes.md](recipes.md)), copy-recipe accuracy, clearer guidance.
4. **Test coverage** — additional render tests asserting semantics and states.
5. **New variants/states of existing components** where demand is demonstrated.
6. **New components** that clear the four-factor bar above.

## Under active consideration (directional, not committed)

Recorded so contributors know where thinking is heading. None of these are dated
commitments; each will land only when it clears the rubric.

- **CSS anchor positioning** taking over from the JS positioning fallback for
  floating components as browser support becomes universal
  ([ADR-0006](adr/0006-native-platform-apis.md)).
- **A WebGPU backend** for the scene host behind the existing `scene_host`
  abstraction, once Three's WebGPU renderer matures — an internal swap with no
  component-API change ([ADR-0007](adr/0007-threejs.md)).
- **View Transitions** as progressive enhancement for more overview↔detail flows,
  always gated on support + reduced motion.
- **Broader test-matrix coverage** for the families whose render tests are still
  being filled in (see [component-matrix.md](component-matrix.md)).

## How to influence priorities

- Open a **Component request** or **Feature request** issue with a concrete use
  case — real demand is the strongest signal.
- Upvote/comment on existing issues rather than filing duplicates; observed demand
  is measured across the tracker.
- Contributions are welcome and move things up the list; read
  [`../CONTRIBUTING.md`](../CONTRIBUTING.md) and
  [`../AGENTS.md`](../AGENTS.md) first, and use the API-change review template in
  [api-inventory.md](api-inventory.md) for any public-API change.
