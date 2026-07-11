/**
 * AuroraPopover — a non-modal floating panel anchored to a trigger.
 *
 * DOM contract:
 *   - root element has `data-aui-popover` and is the floating panel
 *   - `data-aui-anchor` = id (or selector) of the trigger; defaults to the
 *     previous element sibling
 *   - `data-aui-placement` = e.g. bottom, bottom-start, top-end, right … (the
 *     hook writes back the *resolved* placement after collision flipping)
 *   - `data-aui-open` toggles visibility (server- or trigger-driven)
 *
 * Non-modal: no scroll lock, no focus trap, the page stays interactive. Closes
 * on click-away and Escape. Repositions on scroll/resize while open. Keyboard +
 * touch friendly (the trigger's own click toggles `data-aui-open`; we also wire
 * the trigger if it carries `[data-aui-popover-trigger]`).
 */
import { positionFloating, resolveAnchor, focusableWithin } from "../aui"

export const Popover = {
  mounted() {
    if (this._aui) return
    this._aui = { open: false, anchor: null }
    this._aui.anchor = resolveAnchor(this.el)

    this._reposition = () => {
      if (!this._aui.open) return
      const placement = this.el.getAttribute("data-aui-placement") || "bottom"
      const resolved = positionFloating(this._aui.anchor, this.el, { placement })
      this.el.setAttribute("data-aui-resolved-placement", resolved)
    }

    // Toggle from an anchor that opts in as a trigger.
    this._onTriggerClick = (e) => {
      e.preventDefault()
      this._aui.open ? this.close() : this.open()
    }
    if (this._aui.anchor && this._aui.anchor.hasAttribute("data-aui-popover-trigger")) {
      this._aui.anchor.addEventListener("click", this._onTriggerClick)
    }

    this._onDocPointer = (e) => {
      if (!this._aui.open) return
      if (this.el.contains(e.target)) return
      if (this._aui.anchor && this._aui.anchor.contains(e.target)) return
      this.close()
    }
    this._onKeydown = (e) => {
      if (e.key === "Escape" && this._aui.open) {
        this.close()
        if (this._aui.anchor) this._aui.anchor.focus?.()
      }
    }

    this._syncFromDom()
  },

  updated() {
    // Anchor node may have been re-created by a patch.
    this._aui.anchor = resolveAnchor(this.el)
    this._syncFromDom()
    if (this._aui.open) this._reposition()
  },

  destroyed() {
    if (!this._aui) return
    if (this._aui.anchor && this._onTriggerClick) {
      this._aui.anchor.removeEventListener("click", this._onTriggerClick)
    }
    this._removeOpenListeners()
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
    this._aui.open = true
    this.el.hidden = false
    this.el.setAttribute("data-aui-open", "")
    this._reposition()

    // Reposition while open; close on outside interaction.
    window.addEventListener("scroll", this._reposition, true)
    window.addEventListener("resize", this._reposition)
    document.addEventListener("pointerdown", this._onDocPointer, true)
    document.addEventListener("keydown", this._onKeydown, true)

    if (this._aui.anchor) this._aui.anchor.setAttribute("aria-expanded", "true")

    // If the panel contains focusables and wasn't opened by pointer, move focus in.
    const focusables = focusableWithin(this.el)
    if (focusables.length) requestAnimationFrame(() => focusables[0].focus())
  },

  close() {
    if (!this._aui.open) return
    this._aui.open = false
    this.el.hidden = true
    this.el.removeAttribute("data-aui-open")
    if (this._aui.anchor) this._aui.anchor.setAttribute("aria-expanded", "false")
    this._removeOpenListeners()
  },

  _removeOpenListeners() {
    window.removeEventListener("scroll", this._reposition, true)
    window.removeEventListener("resize", this._reposition)
    document.removeEventListener("pointerdown", this._onDocPointer, true)
    document.removeEventListener("keydown", this._onKeydown, true)
  }
}
