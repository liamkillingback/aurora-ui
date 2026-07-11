# Phase 9 — packaging & release verification

**Date:** 2026-07-11. Built with `mix hex.build`.

## Package contents (allow-listed in mix.exs `:files`)

Ships only: `lib/`, `priv/static/`, `assets/css/`, `assets/js/`,
`.formatter.exs`, `mix.exs`, `README.md`, `LICENSE`, `CHANGELOG.md`,
`NOTICE.md`. Verified to EXCLUDE: secrets, caches, `_build`, `deps`, the
`demo/` app, `docs/` evidence, analytics credentials, and any unrelated
PHXTemplates code.

- **Name/description/licence/links:** correct (MIT; GitHub + Docs + PHXTemplates).
- **Package builds:** `mix hex.build` exits 0.
- **Checksum (this build):** `652100d612505cc75df7269f93de077e0c9a1cae1eacef6c0bf47548777d56bb`
  (regenerated per build; `mix hex.publish` records the canonical checksum).

## Reproducibility & provenance

- The package is a deterministic function of the tagged source + `mix.lock`.
- Docs are built with `mix docs` (ExDoc) reproducibly.
- On publish, Hex records a package checksum; the git tag `v0.1.0` is the
  provenance anchor. Release from a clean, CI-passing, protected commit.

## Release procedure

1. `mix check` green on `main`; CI green on both matrix boundaries.
2. Update `CHANGELOG.md`; tag `v0.1.0`.
3. `mix hex.build` → inspect file list → `mix hex.publish`.
4. Install the exact artifact into two clean Phoenix apps (matrix boundaries) and
   run smoke journeys (phase-07).
5. Publish changelog, upgrade notes, compatibility, licence/notices,
   accessibility + bundle results, and known limitations (all in `docs/`).

## Rollback

`mix hex.publish` supports retiring a version; consumers pin `~> 0.1`. A bad
release is retired and a patch published; the example app + clean-install tests
gate the replacement.
