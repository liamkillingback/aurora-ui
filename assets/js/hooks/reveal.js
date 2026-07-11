/**
 * AuroraReveal — reveal-on-scroll enhancement (see assets/css/components/motion.css).
 *
 * DOM contract:
 *   - element has `data-aui-reveal`
 *   - on mount the hook adds `data-aui-hook="ready"` (CSS then hides it until
 *     revealed — progressive enhancement: without JS it stays visible)
 *   - when the element scrolls into view the hook adds `data-aui-revealed`
 *   - if the element (or an ancestor) has `data-aui-stagger`, each child gets
 *     `--aui-i` set to its index so CSS can stagger the transition-delay
 *
 * Under reduced motion the element reveals immediately (the CSS collapses the
 * transform to a plain fade). The IntersectionObserver is disconnected on
 * destroy. Once revealed we stop observing (reveal is one-shot).
 */
import { prefersReducedMotion } from "../aui"

export const Reveal = {
  mounted() {
    if (this._aui) return
    this._aui = { observer: null }

    // Assign stagger indices to children if requested.
    if (this.el.hasAttribute("data-aui-stagger")) {
      Array.from(this.el.children).forEach((child, i) =>
        child.style.setProperty("--aui-i", String(i))
      )
    }

    // Claim the element (CSS hides it now that a hook is present).
    this.el.setAttribute("data-aui-hook", "ready")

    if (prefersReducedMotion() || !("IntersectionObserver" in window)) {
      this._reveal()
      return
    }

    this._aui.observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            this._reveal()
            break
          }
        }
      },
      { threshold: 0.12, rootMargin: "0px 0px -8% 0px" }
    )
    this._aui.observer.observe(this.el)
  },

  updated() {
    // Keep stagger indices fresh if children changed and we haven't revealed.
    if (this.el.hasAttribute("data-aui-stagger") && !this.el.hasAttribute("data-aui-revealed")) {
      Array.from(this.el.children).forEach((child, i) =>
        child.style.setProperty("--aui-i", String(i))
      )
    }
  },

  destroyed() {
    if (!this._aui) return
    if (this._aui.observer) this._aui.observer.disconnect()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _reveal() {
    this.el.setAttribute("data-aui-revealed", "")
    if (this._aui.observer) {
      this._aui.observer.disconnect()
      this._aui.observer = null
    }
  }
}
