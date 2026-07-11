/**
 * AuroraDialog — progressive enhancement for a native <dialog data-aui-dialog>.
 *
 * DOM contract:
 *   - root element is the <dialog data-aui-dialog>
 *   - `data-aui-open` present on mount/update => the dialog should be modal-open
 *   - any descendant with `[data-aui-dialog-close]` closes the dialog on click
 *
 * Behavior: showModal() for the top layer + backdrop, focus the [autofocus] or
 * first focusable element, trap focus (native <dialog> already traps, but we add
 * a fallback for browsers/edge cases), lock body scroll, close on Escape, close
 * on backdrop click, restore focus to the invoker on close. Survives updated()
 * without losing open state.
 */
import { focusInitial, trapFocus, lockScroll, unlockScroll } from "../aui"

export const Dialog = {
  mounted() {
    if (this._aui) return
    this._aui = { open: false, releaseTrap: null, invoker: null, locked: false }

    // Remember which element opened us so we can restore focus on close.
    this._onFocusIn = () => {
      if (!this._aui.open) this._aui.invoker = document.activeElement
    }
    document.addEventListener("focusin", this._onFocusIn, true)

    // Native cancel (Escape) — let it close but route through our teardown.
    this._onCancel = (e) => {
      e.preventDefault() // prevent the default instant close so we tidy up first
      this.close()
    }
    this.el.addEventListener("cancel", this._onCancel)

    // Native close event (covers form method=dialog, close() from anywhere).
    this._onClose = () => this._teardownOpen()
    this.el.addEventListener("close", this._onClose)

    // Backdrop click: on a native <dialog>, clicks on the ::backdrop land on the
    // dialog element itself. Detect by hit-testing against the content box.
    this._onClick = (e) => {
      const closer = e.target.closest?.("[data-aui-dialog-close]")
      if (closer) {
        e.preventDefault()
        this.close()
        return
      }
      if (e.target === this.el) {
        const r = this.el.getBoundingClientRect()
        const inside =
          e.clientX >= r.left && e.clientX <= r.right && e.clientY >= r.top && e.clientY <= r.bottom
        if (!inside) this.close()
      }
    }
    this.el.addEventListener("click", this._onClick)

    // Open/close is driven by the `data-aui-open` attribute. A trigger toggles it
    // with `Phoenix.LiveView.JS.set_attribute`, which is a client-side DOM change
    // that never fires `updated()` — so observe the attribute directly.
    this._obs = new MutationObserver(() => this._syncFromDom())
    this._obs.observe(this.el, { attributes: true, attributeFilter: ["data-aui-open"] })

    this._syncFromDom()
  },

  updated() {
    // Reflect server-driven open/close (LiveView patches) without dropping state.
    this._syncFromDom()
  },

  destroyed() {
    if (!this._aui) return
    if (this._obs) this._obs.disconnect()
    document.removeEventListener("focusin", this._onFocusIn, true)
    this.el.removeEventListener("cancel", this._onCancel)
    this.el.removeEventListener("close", this._onClose)
    this.el.removeEventListener("click", this._onClick)
    this._teardownOpen()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _syncFromDom() {
    const shouldOpen = this.el.hasAttribute("data-aui-open")
    if (shouldOpen && !this._aui.open) this.open()
    else if (!shouldOpen && this._aui.open) this.close()
  },

  open() {
    if (this._aui.open) return
    this._aui.invoker = document.activeElement
    if (typeof this.el.showModal === "function" && !this.el.open) {
      this.el.showModal()
    }
    this._aui.open = true
    lockScroll()
    this._aui.locked = true
    this._aui.releaseTrap = trapFocus(this.el)
    // Defer focus so the top layer is painted first.
    requestAnimationFrame(() => {
      if (this._aui && this._aui.open) focusInitial(this.el)
    })
  },

  close() {
    if (!this._aui.open) return
    if (this.el.open && typeof this.el.close === "function") {
      this.el.close() // fires "close" → _teardownOpen
    } else {
      this._teardownOpen()
    }
  },

  _teardownOpen() {
    if (!this._aui || !this._aui.open) return
    this._aui.open = false
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
    if (invoker && typeof invoker.focus === "function" && document.contains(invoker)) {
      invoker.focus()
    }
  }
}
