# CLAUDE.md

Aurora UI is a free, MIT-licensed Phoenix LiveView + Tailwind UI kit.

**Read [`AGENTS.md`](AGENTS.md) before writing any component** — it is the
authoritative contract: module/CSS/JS conventions, the design-token reference,
the LiveView hook DOM contract, the accessibility rules, the component
definition of done, and prohibited shortcuts.

Quick commands:

```bash
mix deps.get
mix compile --warnings-as-errors
mix test
mix format --check-formatted
mix check            # everything CI runs
```

Architecture at a glance:

- `lib/aurora_ui/components/*.ex` — 15 function-component families.
- `lib/aurora_ui/internal.ex` — shared class/variant/id helpers (private API).
- `assets/css/aurora_ui.css` — cascade-layered tokens + base; one
  `assets/css/components/<family>.css` per family.
- `assets/js/index.js` — core hooks; `command.js`/`motion.js`/`three/` are
  lazy-imported entry points kept out of core bundles.
- `demo/` — the docs, component lab, and example app (a Phoenix app depending on
  the library by path — proves the install story).
- `docs/adr/` — architecture decision records. `docs/evidence/phase-NN/` —
  phase evidence.
