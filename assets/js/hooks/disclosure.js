/**
 * AuroraDisclosure — smooth height animation for a native <details> element.
 *
 * DOM contract:
 *   - root element is a `<details>` with a `<summary>` and content
 *   - the content after the summary is animated open/closed by height
 *
 * Keeps native semantics: the <details> stays a real disclosure widget (screen
 * readers, Find-in-page expansion, and no-JS all keep working). We only animate
 * the height on toggle, cancelling any in-flight animation so rapid toggles
 * don't glitch. Reduced motion = instant (native default behavior).
 */
import { prefersReducedMotion } from "../aui"

export const Disclosure = {
  mounted() {
    if (this._aui) return
    this._aui = { animation: null }

    // The animated region: everything after <summary>. Prefer an explicit
    // wrapper marked [data-aui-disclosure-content]; else wrap nothing and animate
    // the details' own content box via a content element if present.
    this._summary = this.el.querySelector("summary")
    this._content =
      this.el.querySelector("[data-aui-disclosure-content]") ||
      this._nextContentElement()

    if (!this._summary || !this._content) return

    this._onClick = (e) => {
      if (prefersReducedMotion()) return // let native toggle happen instantly
      e.preventDefault()
      this._toggle()
    }
    this._summary.addEventListener("click", this._onClick)
  },

  updated() {
    // Re-resolve the content element if the patch replaced it; no state to keep
    // beyond the open attribute which LiveView renders directly.
    if (this._summary) {
      this._content =
        this.el.querySelector("[data-aui-disclosure-content]") || this._nextContentElement()
    }
  },

  destroyed() {
    if (!this._aui) return
    if (this._summary && this._onClick) this._summary.removeEventListener("click", this._onClick)
    if (this._aui.animation) this._aui.animation.cancel()
    this._aui = null
  },

  // --- internals ------------------------------------------------------------

  _nextContentElement() {
    let node = this._summary ? this._summary.nextElementSibling : null
    return node || null
  },

  _toggle() {
    if (this.el.open) this._collapse()
    else this._expand()
  },

  _expand() {
    if (this._aui.animation) this._aui.animation.cancel()
    // Open natively first so content is measurable, then animate from 0.
    this.el.open = true
    const target = this._content.scrollHeight
    const anim = this._content.animate(
      [{ height: "0px", opacity: 0 }, { height: `${target}px`, opacity: 1 }],
      { duration: this._duration(), easing: "cubic-bezier(0.2, 0, 0, 1)" }
    )
    this._aui.animation = anim
    anim.onfinish = () => {
      this._content.style.height = ""
      this._aui.animation = null
    }
    anim.oncancel = () => (this._aui.animation = null)
  },

  _collapse() {
    if (this._aui.animation) this._aui.animation.cancel()
    const start = this._content.offsetHeight
    const anim = this._content.animate(
      [{ height: `${start}px`, opacity: 1 }, { height: "0px", opacity: 0 }],
      { duration: this._duration(), easing: "cubic-bezier(0.3, 0, 0.8, 0.15)" }
    )
    this._aui.animation = anim
    anim.onfinish = () => {
      this.el.open = false // collapse natively once the animation finishes
      this._content.style.height = ""
      this._aui.animation = null
    }
    anim.oncancel = () => (this._aui.animation = null)
  },

  _duration() {
    // Longer content gets a slightly longer, capped duration.
    const h = this._content.scrollHeight
    return Math.min(120 + h * 0.25, 320)
  }
}
