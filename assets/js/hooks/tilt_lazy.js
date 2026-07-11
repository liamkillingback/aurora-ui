/**
 * AuroraTilt — lazy wrapper for pointer-driven 3D tilt.
 *
 * Tilt is decorative and inappropriate on touch or when the user prefers reduced
 * motion, so we bail out *before* importing anything in those cases (saving the
 * network request entirely). Otherwise we dynamically import the code-split
 * `../motion.js` entry and delegate to `mountTilt(this)`, which returns a
 * cleanup function.
 *
 * An ancestor with `data-aui-tilt="off"` also disables the effect (lets a
 * container opt a whole region out).
 */
import { prefersReducedMotion, isCoarsePointer } from "../aui"

export const Tilt = {
  mounted() {
    if (this._aui) return
    this._aui = { cleanup: null, destroyed: false }

    if (prefersReducedMotion() || isCoarsePointer() || this.el.closest('[data-aui-tilt="off"]')) {
      return // never import the chunk when tilt can't/shouldn't run
    }

    import("../motion.js")
      .then(({ mountTilt }) => {
        if (this._aui.destroyed) return
        this._aui.cleanup = mountTilt(this)
      })
      .catch((err) => {
        console.warn("[AuroraTilt] enhancement unavailable:", err)
      })
  },

  destroyed() {
    if (!this._aui) return
    this._aui.destroyed = true
    if (this._aui.cleanup) this._aui.cleanup()
    this._aui = null
  }
}
