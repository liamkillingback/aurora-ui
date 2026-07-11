# ADR 0002 — Source ownership model

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

Following ADR-0001, we must define who "owns" the rendered source and what the
upgrade/conflict implications are.

## Decision

By default, **consumers depend on the packaged modules** and own only their
theme (the `--aui-*` overrides in their CSS) and their composition of the
components. This keeps upgrades to a `mix deps.update aurora_ui` and a changelog
read.

When a consumer needs to change a component's markup, they use the **documented
copy path**: copy the family module into their app, adjust the module name, and
keep `AuroraUI.Internal` (or inline the two helpers they use). At that point they
own that file and opt out of upstream changes for it — this is stated explicitly
in `docs/upgrade.md` and each copy recipe.

Conflict strategy: the package never generates or writes into consumer source,
so there is no file-collision risk. Theme overrides live in a consumer-owned
CSS layer that always wins over `aui.components` (see ADR-0003), so upgrades
cannot silently override a consumer's theme.

## Consequences

- Clean, boring upgrades for the common case.
- Forking is explicit and localized to one file per component.
- No "did the generator overwrite my edits?" class of bug.

## Alternatives considered

- **Always-copy ownership**: pushes upgrade burden onto every consumer for every
  component. Rejected as the default.
