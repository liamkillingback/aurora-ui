/**
 * Aurora UI — shared vanilla-JS helpers used across hooks.
 *
 * Kept tiny and dependency-free. Everything here is tree-shakeable: hooks import
 * only the named helpers they use. Nothing here touches the network or globals
 * beyond `window`/`document`/`navigator` feature probes.
 */

/** True when the user asked the platform to reduce motion. Re-read live (not
 *  cached) because the OS setting can change while the page is open. */
export function prefersReducedMotion() {
  return (
    typeof window !== "undefined" &&
    typeof window.matchMedia === "function" &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches
  )
}

/** True on touch/pen (coarse) pointers where hover/tilt-style affordances are
 *  inappropriate or unreliable. */
export function isCoarsePointer() {
  return (
    typeof window !== "undefined" &&
    typeof window.matchMedia === "function" &&
    window.matchMedia("(pointer: coarse)").matches
  )
}

/** Selector matching natively focusable / tabbable elements. */
export const FOCUSABLE_SELECTOR = [
  "a[href]",
  "area[href]",
  "button:not([disabled])",
  'input:not([disabled]):not([type="hidden"])',
  "select:not([disabled])",
  "textarea:not([disabled])",
  "iframe",
  "object",
  "embed",
  '[tabindex]:not([tabindex="-1"])',
  '[contenteditable="true"]',
  "audio[controls]",
  "video[controls]",
  "summary",
  "details > summary:first-of-type"
].join(",")

/** Is the element actually rendered (not display:none / visibility:hidden)? */
export function isVisible(el) {
  if (!el) return false
  if (el.hidden) return false
  // offsetParent is null for display:none (and for position:fixed, handled by rects).
  const rects = el.getClientRects()
  if (rects.length === 0 && el.offsetParent === null) return false
  const style = window.getComputedStyle(el)
  return style.visibility !== "hidden" && style.display !== "none"
}

/** Ordered list of visible, tabbable descendants of `root` (inclusive is false). */
export function focusableWithin(root) {
  if (!root) return []
  const nodes = Array.from(root.querySelectorAll(FOCUSABLE_SELECTOR))
  return nodes.filter((el) => isVisible(el) && !el.closest("[inert]"))
}

/** Focus the [autofocus] element, else the first focusable, else the container. */
export function focusInitial(root) {
  const preferred = root.querySelector("[autofocus]")
  if (preferred && isVisible(preferred)) {
    preferred.focus()
    return preferred
  }
  const focusables = focusableWithin(root)
  const target = focusables[0] || root
  if (target === root && !root.hasAttribute("tabindex")) {
    root.setAttribute("tabindex", "-1")
  }
  target.focus()
  return target
}

/**
 * Install a Tab/Shift+Tab focus trap that keeps focus inside `root`.
 * Returns a teardown function. Recomputes the focusable set on each Tab so it
 * survives DOM changes from LiveView patches.
 */
export function trapFocus(root) {
  function onKeydown(e) {
    if (e.key !== "Tab") return
    const focusables = focusableWithin(root)
    if (focusables.length === 0) {
      // Nothing focusable — keep focus on the container itself.
      e.preventDefault()
      root.focus()
      return
    }
    const first = focusables[0]
    const last = focusables[focusables.length - 1]
    const active = document.activeElement
    if (e.shiftKey) {
      if (active === first || !root.contains(active)) {
        e.preventDefault()
        last.focus()
      }
    } else if (active === last || !root.contains(active)) {
      e.preventDefault()
      first.focus()
    }
  }
  root.addEventListener("keydown", onKeydown)
  return () => root.removeEventListener("keydown", onKeydown)
}

// --- Scroll lock (reference-counted so nested overlays don't fight) ---------

let scrollLockCount = 0
let savedScroll = null

/** Lock body scroll, compensating for scrollbar width to avoid layout shift. */
export function lockScroll() {
  scrollLockCount += 1
  if (scrollLockCount > 1) return
  const doc = document.documentElement
  const scrollbar = window.innerWidth - doc.clientWidth
  savedScroll = {
    overflow: doc.style.overflow,
    paddingRight: doc.style.paddingRight
  }
  doc.style.overflow = "hidden"
  if (scrollbar > 0) {
    const current = parseFloat(window.getComputedStyle(doc).paddingRight) || 0
    doc.style.paddingRight = `${current + scrollbar}px`
  }
}

/** Release one scroll lock; restores styles when the last lock is released. */
export function unlockScroll() {
  if (scrollLockCount === 0) return
  scrollLockCount -= 1
  if (scrollLockCount > 0) return
  const doc = document.documentElement
  if (savedScroll) {
    doc.style.overflow = savedScroll.overflow
    doc.style.paddingRight = savedScroll.paddingRight
    savedScroll = null
  }
}

/**
 * Run `fn` after the element's current CSS transition(s) settle, or after
 * `fallback` ms if no transitionend fires (or reduced motion). Returns a
 * *cancel* function that drops the pending callback WITHOUT running it — use it
 * to abort an in-flight exit when the element is reopened. Safe against the
 * transitionend never arriving.
 */
export function afterTransition(el, fn, fallback = 400) {
  let done = false
  let timer
  const finish = () => {
    if (done) return
    done = true
    el.removeEventListener("transitionend", onEnd)
    clearTimeout(timer)
    fn()
  }
  const onEnd = (e) => {
    if (e.target === el) finish()
  }
  const cancel = () => {
    if (done) return
    done = true
    el.removeEventListener("transitionend", onEnd)
    clearTimeout(timer)
  }
  if (prefersReducedMotion()) {
    // Still async so callers can rely on consistent ordering.
    timer = setTimeout(finish, 0)
    return cancel
  }
  el.addEventListener("transitionend", onEnd)
  timer = setTimeout(finish, fallback)
  return cancel
}

/**
 * Wrap a function so it runs at most once per animation frame with the latest
 * args. Returns the throttled function plus a `.cancel()` to drop a pending
 * frame during teardown.
 */
export function rafThrottle(fn) {
  let frame = null
  let lastArgs = null
  const wrapped = (...args) => {
    lastArgs = args
    if (frame !== null) return
    frame = requestAnimationFrame(() => {
      frame = null
      fn(...lastArgs)
    })
  }
  wrapped.cancel = () => {
    if (frame !== null) {
      cancelAnimationFrame(frame)
      frame = null
    }
  }
  return wrapped
}

/**
 * Position a floating panel next to an anchor with viewport collision flipping.
 * Pure geometry — no external lib. Writes `left`/`top` (fixed positioning) onto
 * `floating.style` and returns the resolved placement so callers can reflect it
 * (e.g. for arrow direction) via `data-aui-placement`.
 *
 * @param {DOMRect|Element} anchor  anchor rect or element
 * @param {HTMLElement} floating    the panel (must be measurable / in the DOM)
 * @param {object} opts             { placement, offset, padding }
 */
export function positionFloating(anchor, floating, opts = {}) {
  const placement = opts.placement || "bottom"
  const offset = opts.offset ?? 8
  const padding = opts.padding ?? 8
  const anchorRect = anchor instanceof Element ? anchor.getBoundingClientRect() : anchor
  const fRect = floating.getBoundingClientRect()
  const vw = document.documentElement.clientWidth
  const vh = document.documentElement.clientHeight

  const [side, align = "center"] = placement.split("-")

  // Space available on each side of the anchor.
  const space = {
    top: anchorRect.top,
    bottom: vh - anchorRect.bottom,
    left: anchorRect.left,
    right: vw - anchorRect.right
  }
  const needed = { top: fRect.height, bottom: fRect.height, left: fRect.width, right: fRect.width }

  // Flip to the opposite side if there isn't room and the opposite side has more.
  let resolvedSide = side
  const opposite = { top: "bottom", bottom: "top", left: "right", right: "left" }[side]
  if (space[side] < needed[side] + offset && space[opposite] > space[side]) {
    resolvedSide = opposite
  }

  let left
  let top
  if (resolvedSide === "top" || resolvedSide === "bottom") {
    top = resolvedSide === "bottom" ? anchorRect.bottom + offset : anchorRect.top - fRect.height - offset
    if (align === "start") left = anchorRect.left
    else if (align === "end") left = anchorRect.right - fRect.width
    else left = anchorRect.left + anchorRect.width / 2 - fRect.width / 2
  } else {
    left = resolvedSide === "right" ? anchorRect.right + offset : anchorRect.left - fRect.width - offset
    if (align === "start") top = anchorRect.top
    else if (align === "end") top = anchorRect.bottom - fRect.height
    else top = anchorRect.top + anchorRect.height / 2 - fRect.height / 2
  }

  // Clamp within the viewport padding on the cross axis.
  left = Math.max(padding, Math.min(left, vw - fRect.width - padding))
  top = Math.max(padding, Math.min(top, vh - fRect.height - padding))

  floating.style.position = "fixed"
  floating.style.left = `${Math.round(left)}px`
  floating.style.top = `${Math.round(top)}px`

  const resolvedPlacement = align === "center" ? resolvedSide : `${resolvedSide}-${align}`
  return resolvedPlacement
}

/** Resolve an anchor element for a hook: an id in `data-aui-anchor`, a selector,
 *  or the previous element sibling as a sensible default. */
export function resolveAnchor(el) {
  const ref = el.getAttribute("data-aui-anchor")
  if (ref) {
    return document.getElementById(ref) || document.querySelector(ref) || el.previousElementSibling
  }
  return el.previousElementSibling
}
