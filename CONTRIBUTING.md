# Contributing to Aurora UI

Thanks for helping make a genuinely good, genuinely free Phoenix UI kit.

## Ground rules

- **Read [`AGENTS.md`](AGENTS.md) first.** It is the authoritative component
  contract: module/CSS/JS conventions, the design-token reference, the LiveView
  hook DOM contract, the accessibility rules, the component definition of done,
  and the prohibited shortcuts. A PR that ignores it will be asked to change.
- Accessibility and security regressions are triaged **ahead of** new visual
  variants. A beautiful component that fails keyboard users is a bug, not a
  feature.
- Server-rendered HEEx is the source of truth. JavaScript enhances; it never
  becomes the only way to perform a core action.
- No component may add JavaScript or CSS to a page that does not render it.

## Local setup

```bash
git clone https://github.com/liamkillingback/aurora-ui
cd aurora-ui
mix deps.get
mix check          # format + compile (warnings as errors) + test + snippet freshness

# docs / component lab / example app:
cd demo && mix setup && mix phx.server
```

## Definition of done for a component change

1. Every relevant interaction state is implemented (see the matrix in AGENTS.md)
   or explicitly recorded as `not applicable`.
2. Keyboard + touch parity; correct ARIA; visible, unobscured focus.
3. Works in light/dark, reduced motion, forced colors, RTL, and 200–400% zoom.
4. A render test in `test/aurora_ui/<family>_test.exs` covers the important
   semantics.
5. Tokens only — no hard-coded colors or sizes.
6. Docs updated: the component page, the component matrix row, and the changelog.

## Pull requests

- Branch from `main`; keep PRs focused.
- Fill in the PR template, including the accessibility checklist and any
  public-API change (use the API-change review template in
  [`docs/api-inventory.md`](docs/api-inventory.md)).
- CI must pass: format, compile-as-errors, tests, secret scan, dependency/licence
  audit, docs build, accessibility smoke, and bundle budgets.
- Breaking a public component API requires a deprecation note and, where markup
  changes, migration guidance. See the support policy in
  [`docs/compatibility.md`](docs/compatibility.md).

## Good first contributions

We label issues `good first issue`, `component request`, `accessibility`,
`docs`, and `help wanted`. Docs fixes, new recipes, additional test coverage,
and accessibility audits are always welcome.

## Reporting security issues

Do **not** open a public issue. See [`SECURITY.md`](SECURITY.md).

## Licensing of contributions

By submitting a contribution you agree it is licensed under the project's MIT
license and that you have the right to contribute it.
