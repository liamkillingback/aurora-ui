# ADR 0007 — Three.js renderer/runtime and static fallback

- **Status:** Accepted
- **Date:** 2026-07-11
- **Deciders:** maintainers

## Context

The signature "inside the system" demo uses a 3D component constellation. It must
be fully implemented yet never harm consumers who don't render it, never block
docs content, and degrade to an intentionally-designed static experience on
low-capability devices, reduced-motion, no-JS, or no-WebGL.

## Decision

- **Renderer:** Three.js `WebGLRenderer` (WebGL 2 backend) as the baseline for
  universal support. We keep the renderer choice behind the `scene_host`
  abstraction so a WebGPU backend can be adopted later without changing the
  component API. (Three's WebGPU renderer is still maturing; not a 0.1 default.)
- **Isolation:** Three.js is an **optional peer dependency** imported only inside
  `assets/js/three/scene.js`, which is reached only through the lazy
  `AuroraSceneHost` hook. `import three` never appears in core; the bundle
  composition test asserts this.
- **Fallback:** `scene_host/1` renders, server-side, both a designed static
  `fallback` slot **and** a `semantic` slot carrying the same information as real
  HTML. The 3D scene only replaces the fallback after it successfully
  initializes and only when reduced-motion is off and WebGL is present.
- **Runtime discipline:** DPR capped, paused when offscreen (IntersectionObserver)
  or tab-hidden (visibilitychange), context-loss recovery, ResizeObserver-driven
  resize, and full disposal (geometry/material/renderer/rAF/listeners) on
  navigation. Budgets in phase-08 evidence.
- **Educational example:** one small standalone scene ships as an example; the
  full constellation is reserved for `/lab`.

## Consequences

- Consumers pay nothing for 3D unless they render a scene host.
- The docs work, and look intentional, with JS/WebGL/motion all disabled.
- A future WebGPU swap is an internal change.

## Alternatives considered

- **WebGPU-first**: immature cross-browser support today. Deferred behind the
  abstraction, not out of scope.
- **A prebuilt 3D `<canvas>` video**: not interactive, doesn't map to real
  component families. Rejected.
