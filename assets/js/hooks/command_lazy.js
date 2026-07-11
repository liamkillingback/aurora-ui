/**
 * AuroraCommandPalette — lazy wrapper.
 *
 * Dynamically imports the code-split `../command.js` entry and delegates to
 * `mountCommandPalette(this)`, which returns a cleanup function. The command
 * palette chunk is shared with the combobox, so a page using both downloads it
 * once. If the import fails the static fallback markup remains usable.
 */
export const CommandPalette = {
  mounted() {
    if (this._aui) return
    this._aui = { cleanup: null, destroyed: false }
    import("../command.js")
      .then(({ mountCommandPalette }) => {
        if (this._aui.destroyed) return
        this._aui.cleanup = mountCommandPalette(this)
      })
      .catch((err) => {
        console.warn("[AuroraCommandPalette] enhancement unavailable:", err)
      })
  },

  updated() {
    if (this._aui && this._aui.onUpdated) this._aui.onUpdated()
  },

  destroyed() {
    if (!this._aui) return
    this._aui.destroyed = true
    if (this._aui.cleanup) this._aui.cleanup()
    this._aui = null
  }
}
