/**
 * Aurora UI — advanced motion (code-split entry, package export "aurora_ui/motion").
 *
 * Only imported on demand by the AuroraTilt lazy wrapper, so it never lands in a
 * consumer bundle that doesn't use tilt. Exports `mountTilt(hook)`.
 */
import { prefersReducedMotion, isCoarsePointer, rafThrottle } from "./aui"

/**
 * Pointer-driven 3D tilt for a card-like element.
 *
 * DOM contract (on `hook.el`):
 *   - `data-aui-tilt-max`   max rotation in degrees (default 8)
 *   - `data-aui-tilt-scale` hover scale (default 1.0 = none)
 *   - `data-aui-tilt-glare` if present, a `[data-aui-tilt-glare]` child's
 *     `--aui-glare-x/--aui-glare-y` follow the pointer for a sheen
 *
 * The transform is applied via CSS custom properties so the stylesheet decides
 * how to compose them (`--aui-tilt-x`, `--aui-tilt-y`, `--aui-tilt-scale`).
 * rAF-throttled; disabled on coarse pointers / reduced motion; fully cleaned up.
 *
 * @returns {() => void} cleanup
 */
export function mountTilt(hook) {
  const el = hook.el
  if (prefersReducedMotion() || isCoarsePointer()) return () => {}

  const max = parseFloat(el.getAttribute("data-aui-tilt-max") || "8")
  const hoverScale = parseFloat(el.getAttribute("data-aui-tilt-scale") || "1")
  const glare = el.querySelector("[data-aui-tilt-glare]")

  const apply = rafThrottle((clientX, clientY) => {
    const rect = el.getBoundingClientRect()
    if (rect.width === 0 || rect.height === 0) return
    // Normalize pointer to -0.5..0.5 within the element.
    const px = (clientX - rect.left) / rect.width - 0.5
    const py = (clientY - rect.top) / rect.height - 0.5
    const rotY = px * max * 2 // horizontal position → rotate around Y
    const rotX = -py * max * 2 // vertical position → rotate around X (inverted)
    el.style.setProperty("--aui-tilt-x", `${rotX.toFixed(2)}deg`)
    el.style.setProperty("--aui-tilt-y", `${rotY.toFixed(2)}deg`)
    el.style.setProperty("--aui-tilt-scale", String(hoverScale))
    if (glare) {
      glare.style.setProperty("--aui-glare-x", `${((px + 0.5) * 100).toFixed(1)}%`)
      glare.style.setProperty("--aui-glare-y", `${((py + 0.5) * 100).toFixed(1)}%`)
    }
  })

  const onMove = (e) => apply(e.clientX, e.clientY)
  const onEnter = () => el.setAttribute("data-aui-tilting", "")
  const onLeave = () => {
    apply.cancel()
    el.removeAttribute("data-aui-tilting")
    // Ease back to rest.
    el.style.setProperty("--aui-tilt-x", "0deg")
    el.style.setProperty("--aui-tilt-y", "0deg")
    el.style.setProperty("--aui-tilt-scale", "1")
  }

  el.addEventListener("pointerenter", onEnter)
  el.addEventListener("pointermove", onMove)
  el.addEventListener("pointerleave", onLeave)

  return () => {
    apply.cancel()
    el.removeEventListener("pointerenter", onEnter)
    el.removeEventListener("pointermove", onMove)
    el.removeEventListener("pointerleave", onLeave)
    el.removeAttribute("data-aui-tilting")
    el.style.removeProperty("--aui-tilt-x")
    el.style.removeProperty("--aui-tilt-y")
    el.style.removeProperty("--aui-tilt-scale")
  }
}
