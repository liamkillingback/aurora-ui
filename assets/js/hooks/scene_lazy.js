/**
 * AuroraSceneHost — lazy wrapper for the optional Three.js scene.
 *
 * The Three.js renderer (and `three` itself, an optional peer dependency) are
 * only loaded on pages that render a scene host, via the code-split
 * `../three/scene.js` entry. This wrapper mounts the server-rendered static
 * fallback (already in the DOM), then attempts to enhance it.
 *
 * If WebGL is unavailable, `three` isn't installed, or the import otherwise
 * fails, we do nothing and leave the static fallback visible — the page never
 * breaks and no error surfaces to the user.
 */
export const SceneHost = {
  mounted() {
    if (this._aui) return
    this._aui = { cleanup: null, destroyed: false }
    import("../three/scene.js")
      .then(({ mountScene }) => {
        if (this._aui.destroyed) return
        // mountScene returns a cleanup fn on success, or null if it declined
        // (no WebGL / no three) — in which case the static fallback stays.
        this._aui.cleanup = mountScene(this) || null
      })
      .catch((err) => {
        // `three` not installed or chunk failed: keep the static fallback.
        console.warn("[AuroraSceneHost] scene unavailable, using static fallback:", err)
      })
  },

  destroyed() {
    if (!this._aui) return
    this._aui.destroyed = true
    if (this._aui.cleanup) this._aui.cleanup()
    this._aui = null
  }
}
