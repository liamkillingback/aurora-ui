# Architecture Decision Records

Each ADR captures one significant decision, its context, and its consequences.
ADRs are immutable once accepted; a reversal is a new ADR that supersedes the
old one. Adding a runtime dependency or changing the public token/API contract
requires an ADR.

| ADR | Decision |
|-----|----------|
| [0001](0001-distribution.md) | Distribution: Hex package + supported copy/vendor path |
| [0002](0002-source-ownership.md) | Consumers depend on packaged modules; copy path is documented and supported |
| [0003](0003-tailwind-and-css.md) | Tailwind integration, CSS cascade layers, and the `--aui-*` variable contract |
| [0004](0004-catalogue.md) | Component catalogue implementation and hosting |
| [0005](0005-javascript-organization.md) | JavaScript organization: LiveView.JS first, colocated hooks, shared only for cross-cutting |
| [0006](0006-native-platform-apis.md) | Evaluation of native Popover/Dialog, anchor positioning, View Transitions, scroll-driven & Web Animations |
| [0007](0007-threejs.md) | Three.js renderer/runtime and static fallback for the signature scene |
| [0008](0008-versioning-and-support.md) | Release identification, compatibility guarantees, deprecation window, support cadence |
| [0009](0009-analytics-and-email.md) | Anonymous analytics and email integration with consent, retention, and PII boundaries |
