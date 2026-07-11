/**
 * AuroraTooltip — a supplementary label shown on hover and keyboard focus.
 *
 * DOM contract:
 *   - root element has `data-aui-tooltip` and is the tooltip bubble (role=tooltip)
 *   - `data-aui-anchor` = id/selector of the trigger; defaults to previous sibling
 *   - `data-aui-placement` = preferred placement (collision-flipped at show time)
 *   - `data-aui-delay` = open delay in ms (default 200)
 *
 * Accessibility: shows on both mouseenter AND focus of the anchor; hides on
 * mouseleave/blur/Escape. Small open delay to avoid flicker; hides instantly.
 * Tooltips must never be the *only* place required info lives (touch users can't
 * hover) — this hook simply enhances an already-labelled control, and does not
 * try to open on touch. The anchor gets aria-describedby wired to the bubble id.
 */
import { positionFloating, resolveAnchor, prefersReducedMotion } from "../aui"

export const Tooltip = {
  mounted() {
    if (this._aui) return
    this._aui = { open: false, showTimer: null }

    this._anchor = resolveAnchor(this.el)
    this._delay = parseInt(this.el.getAttribute("data-aui-delay") || "200", 10)

    // Ensure the bubble has an id and describes the anchor.
    if (!this.el.id) this.el.id = `aui-tt-${Math.random().toString(36).slice(2, 8)}`
    if (this._anchor) {
      const described = this._anchor.getAttribute("aria-describedby")
      if (!described || !described.split(/\s+/).includes(this.el.id)) {
        this._anchor.setAttribute("aria-describedby", [described, this.el.id].filter(Boolean).join(" "))
      }
    }
    this.el.setAttribute("role", "tooltip")
    this.el.hidden = true

    this._onEnter = () => this._scheduleShow()
    this._onLeave = () => this.hide()
    this._onFocus = () => this.show() // focus shows immediately (no hover flicker risk)
    this._onBlur = () => this.hide()
    this._onKeydown = (e) => {
      if (e.key === "Escape" && this._aui.open) this.hide()
    }
    this._reposition = () => {
      if (!this._aui.open) return
      const placement = this.el.getAttribute("data-aui-placement") || "top"
      const resolved = positionFloating(this._anchor, this.el, { placement, offset: 6 })
      this.el.setAttribute("data-aui-resolved-placement", resolved)
    }

    if (this._anchor) {
      this._anchor.addEventListener("mouseenter", this._onEnter)
      this._anchor.addEventListener("mouseleave", this._onLeave)
      this._anchor.addEventListener("focus", this._onFocus, true)
      this._anchor.addEventListener("blur", this._onBlur, true)
      this._anchor.addEventListener("keydown", this._onKeydown)
    }
  },

  updated() {
    if (this._aui.open) this._reposition()
  },

  destroyed() {
    if (!this._aui) return
    clearTimeout(this._aui.showTimer)
    if (this._anchor) {
      this._anchor.removeEventListener("mouseenter", this._onEnter)
      this._anchor.removeEventListener("mouseleave", this._onLeave)
      this._anchor.removeEventListener("focus", this._onFocus, true)
      this._anchor.removeEventListener("blur", this._onBlur, true)
      this._anchor.removeEventListener("keydown", this._onKeydown)
    }
    this._removeReposition()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _scheduleShow() {
    clearTimeout(this._aui.showTimer)
    const delay = prefersReducedMotion() ? 0 : this._delay
    this._aui.showTimer = setTimeout(() => this.show(), delay)
  },

  show() {
    clearTimeout(this._aui.showTimer)
    if (this._aui.open) return
    this._aui.open = true
    this.el.hidden = false
    this.el.setAttribute("data-aui-open", "")
    this._reposition()
    window.addEventListener("scroll", this._reposition, true)
    window.addEventListener("resize", this._reposition)
  },

  hide() {
    clearTimeout(this._aui.showTimer)
    if (!this._aui.open) return
    this._aui.open = false
    this.el.hidden = true
    this.el.removeAttribute("data-aui-open")
    this._removeReposition()
  },

  _removeReposition() {
    window.removeEventListener("scroll", this._reposition, true)
    window.removeEventListener("resize", this._reposition)
  }
}
