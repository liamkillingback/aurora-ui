/**
 * AuroraMenu — an accessible menu with roving tabindex.
 *
 * DOM contract:
 *   - root element has `data-aui-menu`
 *   - the trigger is `[data-aui-menu-trigger]` (or the element referenced by
 *     `data-aui-anchor`); it toggles the menu
 *   - the menu container is `[role=menu]` (defaults to root); items are
 *     `[role=menuitem]` (also matches menuitemcheckbox/radio)
 *   - `data-aui-open` reflects open state
 *
 * Keyboard: ArrowUp/Down move between items (wrapping), Home/End jump to
 * ends, printable characters do typeahead, Escape closes and returns focus to
 * the trigger, Tab closes. Click-away closes. Roving tabindex keeps exactly one
 * item tabbable at a time.
 */
import { resolveAnchor } from "../aui"

export const Menu = {
  mounted() {
    if (this._aui) return
    this._aui = { open: false, typeahead: "", typeaheadTimer: null, activeIndex: -1 }

    this._menu = this.el.matches("[role=menu]") ? this.el : this.el.querySelector("[role=menu]") || this.el
    this._trigger =
      this.el.querySelector("[data-aui-menu-trigger]") || resolveAnchor(this.el)

    this._onTriggerClick = (e) => {
      e.preventDefault()
      this._aui.open ? this.close() : this.open()
    }
    this._onTriggerKeydown = (e) => {
      if (e.key === "ArrowDown" || e.key === "Enter" || e.key === " ") {
        e.preventDefault()
        this.open(0)
      } else if (e.key === "ArrowUp") {
        e.preventDefault()
        this.open("last")
      }
    }
    if (this._trigger) {
      this._trigger.addEventListener("click", this._onTriggerClick)
      this._trigger.addEventListener("keydown", this._onTriggerKeydown)
      this._trigger.setAttribute("aria-haspopup", "menu")
      this._trigger.setAttribute("aria-expanded", "false")
    }

    this._onMenuKeydown = (e) => this._handleMenuKeydown(e)
    this._onItemClick = (e) => {
      const item = e.target.closest("[role=menuitem],[role=menuitemcheckbox],[role=menuitemradio]")
      if (item && this._menu.contains(item)) {
        // Let the click/activation happen, then close (unless it's a checkbox/radio).
        if (item.getAttribute("role") === "menuitem") this.close(true)
      }
    }
    this._menu.addEventListener("keydown", this._onMenuKeydown)
    this._menu.addEventListener("click", this._onItemClick)

    this._onDocPointer = (e) => {
      if (!this._aui.open) return
      if (this._menu.contains(e.target)) return
      if (this._trigger && this._trigger.contains(e.target)) return
      this.close(false)
    }

    // Initialize roving tabindex.
    this._items().forEach((it, i) => it.setAttribute("tabindex", i === 0 ? "0" : "-1"))
    this._syncFromDom()
  },

  updated() {
    this._syncFromDom()
    // Keep roving tabindex valid after a patch adds/removes items.
    const items = this._items()
    if (items.length && !items.some((it) => it.getAttribute("tabindex") === "0")) {
      items[0].setAttribute("tabindex", "0")
    }
  },

  destroyed() {
    if (!this._aui) return
    if (this._trigger) {
      this._trigger.removeEventListener("click", this._onTriggerClick)
      this._trigger.removeEventListener("keydown", this._onTriggerKeydown)
    }
    this._menu.removeEventListener("keydown", this._onMenuKeydown)
    this._menu.removeEventListener("click", this._onItemClick)
    document.removeEventListener("pointerdown", this._onDocPointer, true)
    clearTimeout(this._aui.typeaheadTimer)
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _items() {
    return Array.from(
      this._menu.querySelectorAll("[role=menuitem],[role=menuitemcheckbox],[role=menuitemradio]")
    ).filter((it) => !it.hasAttribute("disabled") && it.getAttribute("aria-disabled") !== "true")
  },

  _syncFromDom() {
    const shouldOpen = this.el.hasAttribute("data-aui-open")
    if (shouldOpen && !this._aui.open) this.open(0)
    else if (!shouldOpen && this._aui.open) this.close(false)
  },

  _focusIndex(index) {
    const items = this._items()
    if (!items.length) return
    const clamped = (index + items.length) % items.length
    items.forEach((it, i) => it.setAttribute("tabindex", i === clamped ? "0" : "-1"))
    items[clamped].focus()
    this._aui.activeIndex = clamped
  },

  open(focusWhich = 0) {
    if (!this._aui.open) {
      this._aui.open = true
      this.el.setAttribute("data-aui-open", "")
      this._menu.hidden = false
      if (this._trigger) this._trigger.setAttribute("aria-expanded", "true")
      document.addEventListener("pointerdown", this._onDocPointer, true)
    }
    const items = this._items()
    if (!items.length) return
    const target = focusWhich === "last" ? items.length - 1 : focusWhich || 0
    requestAnimationFrame(() => this._focusIndex(target))
  },

  close(restoreFocus = true) {
    if (!this._aui.open) return
    this._aui.open = false
    this.el.removeAttribute("data-aui-open")
    this._menu.hidden = true
    if (this._trigger) this._trigger.setAttribute("aria-expanded", "false")
    document.removeEventListener("pointerdown", this._onDocPointer, true)
    if (restoreFocus && this._trigger) this._trigger.focus()
  },

  _handleMenuKeydown(e) {
    const items = this._items()
    if (!items.length) return
    const current = items.indexOf(document.activeElement)
    switch (e.key) {
      case "ArrowDown":
        e.preventDefault()
        this._focusIndex(current + 1)
        break
      case "ArrowUp":
        e.preventDefault()
        this._focusIndex(current - 1)
        break
      case "Home":
        e.preventDefault()
        this._focusIndex(0)
        break
      case "End":
        e.preventDefault()
        this._focusIndex(items.length - 1)
        break
      case "Escape":
        e.preventDefault()
        this.close(true)
        break
      case "Tab":
        this.close(false)
        break
      default:
        if (e.key.length === 1 && !e.ctrlKey && !e.metaKey && !e.altKey) {
          this._typeahead(e.key, items, current)
        }
    }
  },

  _typeahead(char, items, current) {
    clearTimeout(this._aui.typeaheadTimer)
    this._aui.typeahead += char.toLowerCase()
    this._aui.typeaheadTimer = setTimeout(() => (this._aui.typeahead = ""), 500)
    const query = this._aui.typeahead
    // Search from the item after the current one, wrapping.
    for (let i = 1; i <= items.length; i++) {
      const idx = (current + i) % items.length
      const label = (items[idx].textContent || "").trim().toLowerCase()
      if (label.startsWith(query)) {
        this._focusIndex(idx)
        return
      }
    }
  }
}
