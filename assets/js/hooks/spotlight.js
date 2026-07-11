/**
 * AuroraSpotlight — pointer-follow radial highlight (see motion.css).
 *
 * DOM contract:
 *   - element has class `.aui-spotlight`
 *   - the hook publishes the pointer position as `--aui-mx` / `--aui-my`
 *     (percentages) and toggles `data-aui-spot-active` while the pointer is over
 *
 * Disabled under reduced motion and on coarse (touch) pointers — the effect is
 * purely decorative. Pointer updates are rAF-throttled to one write per frame.
 * All listeners and any pending frame are cleaned up on destroy.
 */
import { prefersReducedMotion, isCoarsePointer, rafThrottle } from "../aui"

export const Spotlight = {
  mounted() {
    if (this._aui) return
    this._aui = { enabled: false }

    if (prefersReducedMotion() || isCoarsePointer()) return
    this._aui.enabled = true

    this._update = rafThrottle((x, y) => {
      const rect = this.el.getBoundingClientRect()
      if (rect.width === 0 || rect.height === 0) return
      const mx = ((x - rect.left) / rect.width) * 100
      const my = ((y - rect.top) / rect.height) * 100
      this.el.style.setProperty("--aui-mx", `${mx.toFixed(2)}%`)
      this.el.style.setProperty("--aui-my", `${my.toFixed(2)}%`)
    })

    this._onMove = (e) => this._update(e.clientX, e.clientY)
    this._onEnter = () => this.el.setAttribute("data-aui-spot-active", "")
    this._onLeave = () => {
      this._update.cancel()
      this.el.removeAttribute("data-aui-spot-active")
    }

    this.el.addEventListener("pointermove", this._onMove)
    this.el.addEventListener("pointerenter", this._onEnter)
    this.el.addEventListener("pointerleave", this._onLeave)
  },

  destroyed() {
    if (!this._aui) return
    if (this._aui.enabled) {
      this._update.cancel()
      this.el.removeEventListener("pointermove", this._onMove)
      this.el.removeEventListener("pointerenter", this._onEnter)
      this.el.removeEventListener("pointerleave", this._onLeave)
      this.el.removeAttribute("data-aui-spot-active")
    }
    this._aui = null
  }
}
