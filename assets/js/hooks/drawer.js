/**
 * AuroraDrawer — a slide-in sheet anchored to a viewport edge.
 *
 * DOM contract:
 *   - root element has `data-aui-drawer`
 *   - `data-aui-side` = top|right|bottom|left (default right)
 *   - `data-aui-modal` present => modal (scrim, focus trap, scroll lock)
 *   - `data-aui-open` present => should be shown
 *   - `[data-aui-drawer-close]` descendants close the drawer
 *
 * Modal drawers trap focus + lock scroll and dim the background. Non-modal
 * drawers do neither and leave the page interactive. Enter/exit animations use a
 * data-state attribute driven transition; the exit animation is awaited before
 * we release focus/scroll so the sheet doesn't vanish mid-slide. Reduced motion
 * makes the transitions instant.
 */
import {
  focusInitial,
  trapFocus,
  lockScroll,
  unlockScroll,
  afterTransition,
  prefersReducedMotion
} from "../aui"

export const Drawer = {
  mounted() {
    if (this._aui) return
    this._aui = { open: false, releaseTrap: null, invoker: null, locked: false, cancelAnim: null }

    this._modal = this.el.hasAttribute("data-aui-modal")

    this._onKeydown = (e) => {
      if (e.key === "Escape" && this._aui.open) {
        e.stopPropagation()
        this.close()
      }
    }
    this._onClick = (e) => {
      if (e.target.closest?.("[data-aui-drawer-close]")) {
        e.preventDefault()
        this.close()
      }
    }
    this.el.addEventListener("keydown", this._onKeydown)
    this.el.addEventListener("click", this._onClick)

    // Backdrop click (modal only). The scrim is expected as a sibling/child with
    // [data-aui-drawer-scrim]; fall back to clicks outside the panel.
    if (this._modal) {
      this._onScrimClick = (e) => {
        if (!this._aui.open) return
        const panel = this.el.querySelector("[data-aui-drawer-panel]") || this.el
        if (e.target.closest?.("[data-aui-drawer-scrim]")) {
          this.close()
        } else if (!panel.contains(e.target) && this.el.contains(e.target)) {
          this.close()
        }
      }
      this.el.addEventListener("mousedown", this._onScrimClick)
    }

    // A trigger toggles `data-aui-open` with `JS.set_attribute` (a client-side
    // change that never fires `updated()`), so observe the attribute directly.
    this._obs = new MutationObserver(() => this._syncFromDom(false))
    this._obs.observe(this.el, { attributes: true, attributeFilter: ["data-aui-open"] })

    this._syncFromDom(true)
  },

  updated() {
    this._syncFromDom(false)
  },

  destroyed() {
    if (!this._aui) return
    if (this._obs) this._obs.disconnect()
    this.el.removeEventListener("keydown", this._onKeydown)
    this.el.removeEventListener("click", this._onClick)
    if (this._onScrimClick) this.el.removeEventListener("mousedown", this._onScrimClick)
    if (this._aui.cancelAnim) this._aui.cancelAnim()
    this._release()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _syncFromDom(initial) {
    const shouldOpen = this.el.hasAttribute("data-aui-open")
    if (shouldOpen && !this._aui.open) this.open(initial)
    else if (!shouldOpen && this._aui.open) this.close()
  },

  open(initial = false) {
    if (this._aui.open) return
    this._aui.open = true
    this._aui.invoker = document.activeElement

    if (this._aui.cancelAnim) {
      this._aui.cancelAnim()
      this._aui.cancelAnim = null
    }

    this.el.hidden = false
    // Actually put the native <dialog> on screen. Without show()/showModal() the
    // UA keeps `dialog:not([open])` at display:none, so the drawer never appears;
    // showModal() also gives a modal drawer its backdrop, top layer, and inert
    // background. The slide is driven by [data-state] below.
    if (this._modal) {
      if (typeof this.el.showModal === "function" && !this.el.open) this.el.showModal()
    } else if (typeof this.el.show === "function" && !this.el.open) {
      this.el.show()
    }
    // Guard against double-acquire when reopening mid-close (the previous close's
    // lock/trap are still held because its release was cancelled above).
    if (this._modal && !this._aui.locked) {
      lockScroll()
      this._aui.locked = true
    }

    const panel = this.el.querySelector("[data-aui-drawer-panel]") || this.el
    // Start from the "closed" visual state, then flip to "open" on next frame so
    // the CSS transition runs. Reduced motion skips the two-step.
    if (initial || prefersReducedMotion()) {
      this.el.setAttribute("data-state", "open")
    } else {
      this.el.setAttribute("data-state", "closed")
      requestAnimationFrame(() =>
        requestAnimationFrame(() => {
          if (this._aui && this._aui.open) this.el.setAttribute("data-state", "open")
        })
      )
    }

    if (this._modal) {
      if (!this._aui.releaseTrap) this._aui.releaseTrap = trapFocus(this.el)
      requestAnimationFrame(() => {
        if (this._aui && this._aui.open) focusInitial(panel)
      })
    }
  },

  close() {
    if (!this._aui.open) return
    this._aui.open = false
    const panel = this.el.querySelector("[data-aui-drawer-panel]") || this.el
    this.el.setAttribute("data-state", "closed")

    // Release focus/scroll only after the exit animation completes so the panel
    // is still visible while it slides away.
    this._aui.cancelAnim = afterTransition(panel, () => {
      this._aui && (this._aui.cancelAnim = null)
      // Close the native dialog after the slide-out so it leaves the top layer
      // and the UA hides it; keep `hidden` as a belt-and-braces fallback.
      if (this.el.open && typeof this.el.close === "function") this.el.close()
      this.el.hidden = true
      this._release()
    })
  },

  _release() {
    if (this._aui.releaseTrap) {
      this._aui.releaseTrap()
      this._aui.releaseTrap = null
    }
    if (this._aui.locked) {
      unlockScroll()
      this._aui.locked = false
    }
    const invoker = this._aui.invoker
    this._aui.invoker = null
    if (this._modal && invoker && typeof invoker.focus === "function" && document.contains(invoker)) {
      invoker.focus()
    }
  }
}
