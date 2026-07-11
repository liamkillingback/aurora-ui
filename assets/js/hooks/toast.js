/**
 * AuroraToast — manages a live region of transient notifications.
 *
 * DOM contract:
 *   - root element has `data-aui-toast-region` and is an aria-live region
 *     (polite/assertive is set in HEEx; this hook does not change politeness)
 *   - each toast is `[data-aui-toast]`; optional `data-aui-timeout` (ms) enables
 *     auto-dismiss (0 or absent = sticky)
 *   - a dismiss control is `[data-aui-toast-close]` inside the toast
 *
 * Auto-dismiss pauses while the pointer is over the region or focus is within it
 * (so users can read/interact), and resumes on leave/blur. Reduced motion skips
 * exit animation. Each toast is tracked so timers are cleared on removal.
 */
import { afterTransition } from "../aui"

export const Toast = {
  mounted() {
    if (this._aui) return
    this._aui = { timers: new Map(), paused: false }

    this._onClick = (e) => {
      const closer = e.target.closest("[data-aui-toast-close]")
      if (closer) {
        const toast = closer.closest("[data-aui-toast]")
        if (toast) this._dismiss(toast)
      }
    }
    this._onEnter = () => this._pause()
    this._onLeave = () => this._resume()
    this._onFocusIn = () => this._pause()
    this._onFocusOut = (e) => {
      // Only resume if focus actually left the region.
      if (!this.el.contains(e.relatedTarget)) this._resume()
    }

    this.el.addEventListener("click", this._onClick)
    this.el.addEventListener("mouseenter", this._onEnter)
    this.el.addEventListener("mouseleave", this._onLeave)
    this.el.addEventListener("focusin", this._onFocusIn)
    this.el.addEventListener("focusout", this._onFocusOut)

    this._scanToasts()
  },

  updated() {
    // New toasts may have arrived via a patch; arm their timers.
    this._scanToasts()
  },

  destroyed() {
    if (!this._aui) return
    this.el.removeEventListener("click", this._onClick)
    this.el.removeEventListener("mouseenter", this._onEnter)
    this.el.removeEventListener("mouseleave", this._onLeave)
    this.el.removeEventListener("focusin", this._onFocusIn)
    this.el.removeEventListener("focusout", this._onFocusOut)
    this._aui.timers.forEach((t) => clearTimeout(t.id))
    this._aui.timers.clear()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _scanToasts() {
    const toasts = this.el.querySelectorAll("[data-aui-toast]")
    toasts.forEach((toast) => {
      if (this._aui.timers.has(toast)) return
      const timeout = parseInt(toast.getAttribute("data-aui-timeout") || "0", 10)
      if (timeout > 0) this._arm(toast, timeout)
    })
    // Drop tracking for toasts the server removed.
    this._aui.timers.forEach((_v, toast) => {
      if (!this.el.contains(toast)) {
        clearTimeout(this._aui.timers.get(toast).id)
        this._aui.timers.delete(toast)
      }
    })
  },

  _arm(toast, remaining) {
    const record = { remaining, startedAt: Date.now(), id: null }
    if (!this._aui.paused) {
      record.id = setTimeout(() => this._dismiss(toast), remaining)
      record.startedAt = Date.now()
    }
    this._aui.timers.set(toast, record)
  },

  _pause() {
    if (this._aui.paused) return
    this._aui.paused = true
    this._aui.timers.forEach((rec) => {
      if (rec.id !== null) {
        clearTimeout(rec.id)
        rec.remaining = Math.max(0, rec.remaining - (Date.now() - rec.startedAt))
        rec.id = null
      }
    })
  },

  _resume() {
    if (!this._aui.paused) return
    this._aui.paused = false
    this._aui.timers.forEach((rec, toast) => {
      if (rec.id === null && rec.remaining > 0) {
        rec.startedAt = Date.now()
        rec.id = setTimeout(() => this._dismiss(toast), rec.remaining)
      }
    })
  },

  _dismiss(toast) {
    const rec = this._aui.timers.get(toast)
    if (rec && rec.id !== null) clearTimeout(rec.id)
    this._aui.timers.delete(toast)

    toast.setAttribute("data-aui-leaving", "")
    // Let the server own removal if it wants to (push an event); also self-remove
    // after the exit animation as a graceful default.
    if (typeof this.pushEventTo === "function" && toast.id) {
      this.pushEventTo(this.el, "aui:toast-dismiss", { id: toast.id })
    }
    afterTransition(toast, () => {
      if (toast.parentNode) toast.remove()
    })
  }
}
