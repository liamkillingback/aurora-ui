/**
 * AuroraTabs — an accessible tab list with roving tabindex.
 *
 * DOM contract:
 *   - root element has the tabs; `[role=tablist]` wraps `[role=tab]`s
 *   - each `[role=tab]` has `aria-controls` pointing at its `[role=tabpanel]`
 *   - `data-aui-activation` = "auto" (default, selection follows focus) or
 *     "manual" (arrow moves focus, Enter/Space selects)
 *   - `data-aui-orientation` = horizontal (default) or vertical
 *
 * Keyboard: Arrow keys move between tabs (wrapping, direction respects
 * orientation), Home/End jump to ends. Updates aria-selected, roving tabindex,
 * and panel visibility. Selection is preserved across updated().
 */
export const Tabs = {
  mounted() {
    if (this._aui) return
    this._aui = {}
    this._tablist = this.el.querySelector("[role=tablist]") || this.el
    this._auto = (this.el.getAttribute("data-aui-activation") || "auto") !== "manual"
    this._vertical = this.el.getAttribute("data-aui-orientation") === "vertical"

    this._onKeydown = (e) => this._handleKeydown(e)
    this._onClick = (e) => {
      const tab = e.target.closest("[role=tab]")
      if (tab && this._tabs().includes(tab)) this._select(tab, true)
    }
    this._tablist.addEventListener("keydown", this._onKeydown)
    this._tablist.addEventListener("click", this._onClick)

    // Establish initial selection: an existing aria-selected, else the first tab.
    const tabs = this._tabs()
    const selected = tabs.find((t) => t.getAttribute("aria-selected") === "true") || tabs[0]
    if (selected) this._select(selected, false)
  },

  updated() {
    // Preserve the currently selected tab across patches; re-assert wiring.
    const tabs = this._tabs()
    if (!tabs.length) return
    const selected =
      tabs.find((t) => t.getAttribute("aria-selected") === "true") ||
      (this._aui.selectedId && tabs.find((t) => t.id === this._aui.selectedId)) ||
      tabs[0]
    this._select(selected, false)
  },

  destroyed() {
    if (!this._aui) return
    this._tablist.removeEventListener("keydown", this._onKeydown)
    this._tablist.removeEventListener("click", this._onClick)
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _tabs() {
    return Array.from(this._tablist.querySelectorAll("[role=tab]")).filter(
      (t) => t.getAttribute("aria-disabled") !== "true" && !t.hasAttribute("disabled")
    )
  },

  _panelFor(tab) {
    const id = tab.getAttribute("aria-controls")
    return id ? document.getElementById(id) : null
  },

  _select(tab, focus) {
    const tabs = this._tabs()
    tabs.forEach((t) => {
      const isSel = t === tab
      t.setAttribute("aria-selected", isSel ? "true" : "false")
      t.setAttribute("tabindex", isSel ? "0" : "-1")
      const panel = this._panelFor(t)
      if (panel) {
        panel.hidden = !isSel
        if (isSel) panel.setAttribute("tabindex", panel.getAttribute("tabindex") || "0")
      }
    })
    this._aui.selectedId = tab.id || null
    if (focus) tab.focus()
  },

  _moveFocus(tab, activate) {
    const tabs = this._tabs()
    tabs.forEach((t) => t.setAttribute("tabindex", t === tab ? "0" : "-1"))
    tab.focus()
    if (activate) this._select(tab, true)
  },

  _handleKeydown(e) {
    const tabs = this._tabs()
    const current = tabs.indexOf(document.activeElement)
    if (current === -1) return
    const nextKey = this._vertical ? "ArrowDown" : "ArrowRight"
    const prevKey = this._vertical ? "ArrowUp" : "ArrowLeft"
    let nextIndex = null
    switch (e.key) {
      case nextKey:
        nextIndex = (current + 1) % tabs.length
        break
      case prevKey:
        nextIndex = (current - 1 + tabs.length) % tabs.length
        break
      case "Home":
        nextIndex = 0
        break
      case "End":
        nextIndex = tabs.length - 1
        break
      case "Enter":
      case " ":
        if (!this._auto) {
          e.preventDefault()
          this._select(tabs[current], true)
        }
        return
      default:
        return
    }
    e.preventDefault()
    this._moveFocus(tabs[nextIndex], this._auto)
  }
}
