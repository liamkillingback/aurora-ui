/**
 * AuroraConnectionState — reflects the LiveView socket connection to the DOM.
 *
 * DOM contract:
 *   - element gets `data-aui-conn` = "connected" | "connecting" | "disconnected"
 *   - optional `[data-aui-conn-label]` descendant receives a text status
 *
 * Uses the global `phx:*` lifecycle events that LiveView dispatches on `window`
 * (phx:page-loading-start/stop carry a `kind` of "initial" | "error" | ...), plus
 * the LiveSocket instance on `this.liveSocket` when available, to derive a calm,
 * debounced status. We debounce the "disconnected" state so a fast reconnect
 * never flashes an alarming message. No polling, no timers left running.
 */
export const ConnectionState = {
  mounted() {
    if (this._aui) return
    this._aui = { state: null, pendingDisconnect: null }

    // LiveView's own connection lifecycle callbacks (per-hook) are the most
    // reliable signal for *this* socket.
    this._set(this._deriveInitial())

    // Global page-loading events: "error" kind means the socket dropped and is
    // retrying; a following stop means we're back.
    this._onLoadingStart = (e) => {
      const kind = e.detail && e.detail.kind
      if (kind === "error") this._scheduleDisconnected()
      else if (this._aui.state !== "connected") this._set("connecting")
    }
    this._onLoadingStop = () => {
      this._cancelDisconnected()
      this._set("connected")
    }
    window.addEventListener("phx:page-loading-start", this._onLoadingStart)
    window.addEventListener("phx:page-loading-stop", this._onLoadingStop)
  },

  // Phoenix calls these on the hook when the socket drops/returns.
  disconnected() {
    this._scheduleDisconnected()
  },

  reconnected() {
    this._cancelDisconnected()
    this._set("connected")
  },

  destroyed() {
    if (!this._aui) return
    window.removeEventListener("phx:page-loading-start", this._onLoadingStart)
    window.removeEventListener("phx:page-loading-stop", this._onLoadingStop)
    this._cancelDisconnected()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _deriveInitial() {
    const socket = this.liveSocket && this.liveSocket.socket
    if (socket && typeof socket.isConnected === "function") {
      return socket.isConnected() ? "connected" : "connecting"
    }
    return "connecting"
  },

  _scheduleDisconnected() {
    if (this._aui.pendingDisconnect) return
    // Debounce so a quick reconnect doesn't flash a scary state.
    this._aui.pendingDisconnect = setTimeout(() => {
      this._aui.pendingDisconnect = null
      this._set("disconnected")
    }, 700)
  },

  _cancelDisconnected() {
    if (this._aui.pendingDisconnect) {
      clearTimeout(this._aui.pendingDisconnect)
      this._aui.pendingDisconnect = null
    }
  },

  _set(state) {
    if (!state || this._aui.state === state) return
    this._aui.state = state
    this.el.setAttribute("data-aui-conn", state)
    const label = this.el.querySelector("[data-aui-conn-label]")
    if (label) {
      label.textContent =
        state === "connected" ? "Connected" : state === "connecting" ? "Reconnecting…" : "Offline"
    }
  }
}
