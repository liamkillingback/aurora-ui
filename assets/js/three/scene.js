/**
 * Aurora UI — Three.js scene host (code-split entry, package export "aurora_ui/three").
 *
 * ── Code-splitting / tree-shaking expectation ──────────────────────────────
 * This module (and its `await import("three")`) must NEVER be reachable from the
 * core `index.js` graph. It is only ever pulled in dynamically by the
 * `scene_lazy.js` wrapper, which is itself only mounted on a page that renders
 * `phx-hook="AuroraSceneHost"`. Verify after a bundle build that:
 *   1. `three` does not appear in the main/entry chunk (only in a lazy chunk).
 *   2. A page with no scene host downloads neither this chunk nor `three`.
 *   3. Removing all scene hosts drops `three` from the served assets entirely.
 * `three` is declared as an OPTIONAL peerDependency, so a consumer that never
 * uses a scene doesn't need it installed — hence every use is guarded.
 * ───────────────────────────────────────────────────────────────────────────
 *
 * Exports `mountScene(hook)`. Returns a cleanup function on success, or `null`
 * if it declines (no WebGL / `three` unavailable) so the static fallback stays.
 */

/** Cheap WebGL capability probe (no context kept). */
function hasWebGL() {
  try {
    const canvas = document.createElement("canvas")
    return !!(
      window.WebGLRenderingContext &&
      (canvas.getContext("webgl") || canvas.getContext("experimental-webgl"))
    )
  } catch (_e) {
    return false
  }
}

/**
 * Mount a lightweight ambient scene into `hook.el`.
 *
 * DOM contract (on hook.el):
 *   - a server-rendered static fallback (image/gradient) is already inside;
 *     it stays untouched if we bail out
 *   - `data-dpr-cap`  max devicePixelRatio (default 2) to bound fill cost
 *   - `[data-aui-scene-canvas]` optional explicit canvas mount point; else we
 *     create and append a canvas positioned to fill the host
 *
 * Returns cleanup, or null when it declines.
 */
export function mountScene(hook) {
  const el = hook.el
  if (!hasWebGL()) return null

  // Everything below is async because `three` is dynamically imported. We keep a
  // `disposed` flag so a fast destroy() before the import resolves is honored.
  const state = {
    disposed: false,
    raf: null,
    renderer: null,
    scene: null,
    camera: null,
    geometry: null,
    material: null,
    points: null,
    io: null,
    ro: null,
    canvas: null,
    createdCanvas: false,
    visible: true,
    onVisibility: null,
    onContextLost: null,
    onContextRestored: null,
    THREE: null
  }

  import("three")
    .then((THREE) => {
      if (state.disposed) return
      state.THREE = THREE
      init(hook, state, THREE)
    })
    .catch((err) => {
      // `three` not installed / failed to load — keep the static fallback.
      console.warn("[AuroraSceneHost] three unavailable:", err)
    })

  // Return synchronous cleanup immediately; it tears down whatever exists.
  return () => dispose(state)
}

function init(hook, state, THREE) {
  const el = hook.el
  const dprCap = parseFloat(el.getAttribute("data-dpr-cap") || "2")

  // Canvas: reuse an explicit mount point or create one that fills the host.
  let canvas = el.querySelector("[data-aui-scene-canvas]")
  if (!canvas) {
    canvas = document.createElement("canvas")
    canvas.setAttribute("data-aui-scene-canvas", "")
    canvas.setAttribute("aria-hidden", "true")
    Object.assign(canvas.style, {
      position: "absolute",
      inset: "0",
      width: "100%",
      height: "100%",
      display: "block",
      pointerEvents: "none"
    })
    // Ensure the host can position the canvas.
    if (getComputedStyle(el).position === "static") el.style.position = "relative"
    el.appendChild(canvas)
    state.createdCanvas = true
  }
  state.canvas = canvas

  let renderer
  try {
    renderer = new THREE.WebGLRenderer({
      canvas,
      alpha: true,
      antialias: true,
      powerPreference: "low-power",
      failIfMajorPerformanceCaveat: false
    })
  } catch (err) {
    // Renderer creation can still fail (blacklisted GPU) — keep fallback.
    console.warn("[AuroraSceneHost] renderer init failed:", err)
    if (state.createdCanvas && canvas.parentNode) canvas.remove()
    return
  }
  state.renderer = renderer

  const rect = el.getBoundingClientRect()
  const width = Math.max(1, rect.width)
  const height = Math.max(1, rect.height)
  const dpr = Math.min(window.devicePixelRatio || 1, dprCap)
  renderer.setPixelRatio(dpr)
  renderer.setSize(width, height, false)

  const scene = new THREE.Scene()
  const camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 100)
  camera.position.z = 6
  state.scene = scene
  state.camera = camera

  // A small field of floating points — cheap, ambient, brand-neutral.
  const COUNT = 240
  const positions = new Float32Array(COUNT * 3)
  for (let i = 0; i < COUNT; i++) {
    positions[i * 3 + 0] = (Math.random() - 0.5) * 12
    positions[i * 3 + 1] = (Math.random() - 0.5) * 8
    positions[i * 3 + 2] = (Math.random() - 0.5) * 8
  }
  const geometry = new THREE.BufferGeometry()
  geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3))
  const material = new THREE.PointsMaterial({
    size: 0.05,
    color: 0x8ab4ff,
    transparent: true,
    opacity: 0.7,
    depthWrite: false
  })
  const points = new THREE.Points(geometry, material)
  scene.add(points)
  state.geometry = geometry
  state.material = material
  state.points = points

  // Respect reduced motion: render a single static frame, no animation loop.
  const reduce =
    typeof window.matchMedia === "function" &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches

  const clock = new THREE.Clock()
  const renderFrame = () => {
    renderer.render(scene, camera)
  }
  const animate = () => {
    if (state.disposed) return
    state.raf = requestAnimationFrame(animate)
    const t = clock.getElapsedTime()
    points.rotation.y = t * 0.05
    points.rotation.x = Math.sin(t * 0.1) * 0.1
    renderFrame()
  }

  const start = () => {
    if (reduce || state.raf !== null || state.disposed) {
      if (reduce) renderFrame()
      return
    }
    if (state.visible && !document.hidden) {
      clock.start()
      animate()
    }
  }
  const stop = () => {
    if (state.raf !== null) {
      cancelAnimationFrame(state.raf)
      state.raf = null
    }
  }

  // Pause when scrolled offscreen.
  if ("IntersectionObserver" in window) {
    state.io = new IntersectionObserver(
      (entries) => {
        state.visible = entries.some((e) => e.isIntersecting)
        state.visible ? start() : stop()
      },
      { threshold: 0 }
    )
    state.io.observe(el)
  }

  // Pause when the tab is hidden.
  state.onVisibility = () => (document.hidden ? stop() : start())
  document.addEventListener("visibilitychange", state.onVisibility)

  // Resize with the host.
  if ("ResizeObserver" in window) {
    state.ro = new ResizeObserver(() => {
      const r = el.getBoundingClientRect()
      const w = Math.max(1, r.width)
      const h = Math.max(1, r.height)
      renderer.setSize(w, h, false)
      camera.aspect = w / h
      camera.updateProjectionMatrix()
      if (reduce) renderFrame()
    })
    state.ro.observe(el)
  }

  // Handle GPU context loss/restore gracefully.
  state.onContextLost = (e) => {
    e.preventDefault()
    stop()
  }
  state.onContextRestored = () => {
    renderer.setSize(el.clientWidth || width, el.clientHeight || height, false)
    start()
  }
  canvas.addEventListener("webglcontextlost", state.onContextLost, false)
  canvas.addEventListener("webglcontextrestored", state.onContextRestored, false)

  start()
}

/** Full teardown: cancel rAF, disconnect observers, remove listeners, dispose
 *  all GPU resources, and remove a canvas we created. Idempotent. */
function dispose(state) {
  if (state.disposed) return
  state.disposed = true

  if (state.raf !== null) {
    cancelAnimationFrame(state.raf)
    state.raf = null
  }
  if (state.io) {
    state.io.disconnect()
    state.io = null
  }
  if (state.ro) {
    state.ro.disconnect()
    state.ro = null
  }
  if (state.onVisibility) {
    document.removeEventListener("visibilitychange", state.onVisibility)
    state.onVisibility = null
  }
  if (state.canvas) {
    if (state.onContextLost) state.canvas.removeEventListener("webglcontextlost", state.onContextLost)
    if (state.onContextRestored)
      state.canvas.removeEventListener("webglcontextrestored", state.onContextRestored)
  }
  if (state.geometry) {
    state.geometry.dispose()
    state.geometry = null
  }
  if (state.material) {
    state.material.dispose()
    state.material = null
  }
  if (state.renderer) {
    // Frees the WebGL context and associated GPU memory.
    state.renderer.dispose()
    if (typeof state.renderer.forceContextLoss === "function") state.renderer.forceContextLoss()
    state.renderer = null
  }
  if (state.createdCanvas && state.canvas && state.canvas.parentNode) {
    state.canvas.remove()
  }
  state.canvas = null
  state.scene = null
  state.camera = null
  state.points = null
  state.THREE = null
}
