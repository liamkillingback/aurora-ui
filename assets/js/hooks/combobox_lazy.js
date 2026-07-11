/**
 * AuroraCombobox — lazy wrapper.
 *
 * The full accessible combobox keyboard model is heavy and only needed on pages
 * that render one, so it lives in the code-split `../command.js` entry. This
 * wrapper mounts a tiny shell, dynamically imports the real implementation, and
 * delegates to `mountCombobox(this)` which returns a cleanup function.
 *
 * Until the chunk loads the server-rendered markup is fully usable (the input is
 * a real <input>, the list a real list) — this only layers on the rich a11y
 * interactions. If the import fails we leave the static markup in place.
 */
export const Combobox = {
  mounted() {
    if (this._aui) return
    this._aui = { cleanup: null, destroyed: false }
    import("../command.js")
      .then(({ mountCombobox }) => {
        if (this._aui.destroyed) return
        this._aui.cleanup = mountCombobox(this)
      })
      .catch((err) => {
        // Non-fatal: keep the progressively-enhanced static combobox.
        console.warn("[AuroraCombobox] enhancement unavailable:", err)
      })
  },

  updated() {
    // Let the delegate observe patches if it exposed an updated handler.
    if (this._aui && this._aui.onUpdated) this._aui.onUpdated()
  },

  destroyed() {
    if (!this._aui) return
    this._aui.destroyed = true
    if (this._aui.cleanup) this._aui.cleanup()
    this._aui = null
  }
}
