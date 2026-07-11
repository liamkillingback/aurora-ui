# Phase 10 — maintenance & growth loop

Keeps the free kit credible and useful after launch. Automation lives in
`.github/workflows/maintenance.yml` (weekly + manual).

## Scheduled checks

Dependency freshness/audit, tests against latest patch deps, bundle budgets +
code-splitting proof, broken-link scan of `docs/`, and an accessibility smoke —
all weekly; a failure opens a `needs-triage` issue automatically.

## Native-platform revalidation

Per ADR-0006 we track when CSS anchor positioning, the Popover API, and View
Transitions reach our full support matrix, and remove the JS fallbacks when they
do. Reviewed each maintenance cycle.

## Deprecation discipline

Public API changes follow the ADR-0008 window (≥1 minor with warnings + upgrade
notes); markup-breaking changes ship migration guidance. Accessibility and
security regressions are triaged ahead of new visual variants.

## Release testing

Every release is installed into a clean Phoenix app (both matrix boundaries) and
run against the example app (phase-07). Smoke journeys must pass before tag.

## Recipes & commerce relevance

Publish periodic recipes connecting components into real workflows, and build
commerce-specific component recipes (product card, price, cart line, filters)
that stay broadly useful and demonstrate presentation patterns **without**
duplicating the paid commerce starter's domain logic.

## Re-run user testing

When navigation, distribution, public API, or art direction materially changes,
re-run the phase-01 task list with live Phoenix developers and update
`docs/evidence/phase-01/user-testing.md`.

## Review cadence

Qualitative + KPI review at 7, 30, and 90 days (phase-09 funnel KPIs); prioritize
new families/integrations by observed demand, accessibility risk, maintenance
cost, and premium relevance.
