/**
 * AuroraCopyButton — copy text to the clipboard with accessible confirmation.
 *
 * DOM contract:
 *   - element is the trigger (a <button>) with either:
 *       `data-aui-copy`        = literal text to copy, or
 *       `data-aui-copy-target` = a selector whose element's text is copied
 *   - on success the element gets a transient `data-aui-copied` attribute
 *     (removed after `data-aui-copied-duration` ms, default 1500)
 *   - an aria-live politeness region (`[data-aui-copy-status]` inside or the
 *     element referenced by `aria-describedby`) is updated for screen readers
 *
 * Keyboard accessible because it's a real button. Falls back to a hidden
 * textarea + execCommand when the async Clipboard API is unavailable/blocked.
 */
export const CopyButton = {
  mounted() {
    if (this._aui) return
    this._aui = { resetTimer: null }
    this._duration = parseInt(this.el.getAttribute("data-aui-copied-duration") || "1500", 10)

    this._onClick = (e) => {
      e.preventDefault()
      this._copy()
    }
    this.el.addEventListener("click", this._onClick)
  },

  destroyed() {
    if (!this._aui) return
    this.el.removeEventListener("click", this._onClick)
    clearTimeout(this._aui.resetTimer)
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _text() {
    const literal = this.el.getAttribute("data-aui-copy")
    if (literal !== null) return literal
    const sel = this.el.getAttribute("data-aui-copy-target")
    if (sel) {
      const target = document.querySelector(sel)
      if (target) {
        return "value" in target && target.value !== undefined ? target.value : target.textContent
      }
    }
    return ""
  },

  async _copy() {
    const text = (this._text() || "").trim()
    if (!text) return
    let ok = false
    try {
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(text)
        ok = true
      } else {
        ok = this._legacyCopy(text)
      }
    } catch (_err) {
      ok = this._legacyCopy(text)
    }
    this._feedback(ok)
  },

  _legacyCopy(text) {
    const ta = document.createElement("textarea")
    ta.value = text
    ta.setAttribute("readonly", "")
    ta.style.position = "fixed"
    ta.style.top = "-9999px"
    document.body.appendChild(ta)
    ta.select()
    let ok = false
    try {
      ok = document.execCommand("copy")
    } catch (_e) {
      ok = false
    }
    document.body.removeChild(ta)
    return ok
  },

  _feedback(ok) {
    const message = ok ? "Copied to clipboard" : "Copy failed"
    this._announce(message)
    if (!ok) return

    this.el.setAttribute("data-aui-copied", "")
    clearTimeout(this._aui.resetTimer)
    this._aui.resetTimer = setTimeout(() => {
      this.el.removeAttribute("data-aui-copied")
    }, this._duration)
  },

  _announce(message) {
    // Prefer an explicit status region; else the described-by region; else a
    // transient visually-hidden live region we create and reuse.
    let region = this.el.querySelector("[data-aui-copy-status]")
    if (!region) {
      const describedBy = this.el.getAttribute("aria-describedby")
      if (describedBy) region = document.getElementById(describedBy.split(/\s+/)[0])
    }
    if (!region) {
      region = this._ensureLiveRegion()
    }
    // Clear then set so repeated identical messages are re-announced.
    region.textContent = ""
    requestAnimationFrame(() => (region.textContent = message))
  },

  _ensureLiveRegion() {
    if (this._liveRegion && document.contains(this._liveRegion)) return this._liveRegion
    const region = document.createElement("div")
    region.setAttribute("aria-live", "polite")
    region.setAttribute("role", "status")
    region.className = "aui-sr-only"
    this.el.appendChild(region)
    this._liveRegion = region
    return region
  }
}
