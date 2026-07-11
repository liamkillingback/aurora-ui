/**
 * Aurora UI — combobox + command palette (code-split entry, "aurora_ui/command").
 *
 * Loaded on demand by the AuroraCombobox / AuroraCommandPalette lazy wrappers,
 * so this keyboard-heavy module never enters a bundle for a page that doesn't
 * render one. Exports `mountCombobox(hook)` and `mountCommandPalette(hook)`;
 * each returns a cleanup function the wrapper calls in `destroyed()`.
 *
 * ---------------------------------------------------------------------------
 * SERVER EVENT CONTRACT (the Elixir components must match these names)
 * ---------------------------------------------------------------------------
 * Combobox — pushed via hook.pushEventTo(hook.el, …):
 *   "aui:combobox:filter" {id, query}       // input changed; server may re-filter
 *   "aui:combobox:select" {id, value, label}// an option was chosen
 *   "aui:combobox:open"   {id}              // list opened
 *   "aui:combobox:close"  {id}              // list closed
 *   "aui:combobox:clear"  {id}              // value cleared
 *
 * Command palette — pushed via hook.pushEventTo(hook.el, …):
 *   "aui:command:filter"  {id, query}       // query changed; server may re-filter
 *   "aui:command:run"     {id, value}       // a command was activated
 *   "aui:command:open"    {id}
 *   "aui:command:close"   {id}
 *
 * DOM contract is documented above each mount function. Client-side filtering is
 * used by default; add `data-aui-remote` to defer filtering to the server (the
 * hook then only pushes "…:filter" and re-reads options after the patch).
 * ---------------------------------------------------------------------------
 */
import { lockScroll, unlockScroll, trapFocus } from "./aui"

/**
 * Shared listbox controller implementing the WAI-ARIA combobox keyboard model
 * with aria-activedescendant (DOM focus stays on the input). Both public mounts
 * build on this.
 *
 * @param {object} cfg
 *   input:    HTMLInputElement (role=combobox)
 *   list:     HTMLElement (role=listbox)
 *   getOptions: () => HTMLElement[]  (role=option, visible only)
 *   remote:   boolean (server-side filtering)
 *   onFilter(query), onSelect(option), onOpen(), onClose()
 *   emptyEl:  optional element toggled when no options match
 */
function createListController(cfg) {
  const { input, list } = cfg
  let open = false
  let activeId = null

  const options = () => cfg.getOptions().filter((o) => !isHidden(o))

  function isHidden(o) {
    return o.hidden || o.getAttribute("aria-hidden") === "true" || o.style.display === "none"
  }

  function ensureIds() {
    options().forEach((o, i) => {
      if (!o.id) o.id = `${list.id || "aui-list"}-opt-${i}`
      o.setAttribute("role", "option")
    })
  }

  function setActive(option) {
    const opts = options()
    opts.forEach((o) => o.removeAttribute("data-aui-active"))
    if (option) {
      option.setAttribute("data-aui-active", "")
      activeId = option.id
      input.setAttribute("aria-activedescendant", option.id)
      // Keep the active option in view within a scrolling list.
      option.scrollIntoView({ block: "nearest" })
    } else {
      activeId = null
      input.removeAttribute("aria-activedescendant")
    }
  }

  function activeIndex() {
    const opts = options()
    return opts.findIndex((o) => o.id === activeId)
  }

  function move(delta) {
    const opts = options()
    if (!opts.length) return
    const current = activeIndex()
    const next = current === -1 ? (delta > 0 ? 0 : opts.length - 1) : (current + delta + opts.length) % opts.length
    setActive(opts[next])
  }

  function openList() {
    if (open) return
    open = true
    list.hidden = false
    input.setAttribute("aria-expanded", "true")
    ensureIds()
    cfg.onOpen && cfg.onOpen()
  }

  function closeList() {
    if (!open) return
    open = false
    list.hidden = true
    input.setAttribute("aria-expanded", "false")
    setActive(null)
    cfg.onClose && cfg.onClose()
  }

  function filter(query) {
    if (cfg.remote) {
      cfg.onFilter && cfg.onFilter(query)
      return // server re-renders; syncAfterPatch() re-reads options
    }
    const q = query.trim().toLowerCase()
    let visible = 0
    cfg.getOptions().forEach((o) => {
      const text = (o.getAttribute("data-aui-label") || o.textContent || "").toLowerCase()
      const match = q === "" || text.includes(q)
      o.hidden = !match
      if (match) visible++
    })
    if (cfg.emptyEl) cfg.emptyEl.hidden = visible !== 0
    ensureIds()
    // Keep a valid active option.
    const opts = options()
    if (opts.length) setActive(opts[0])
    else setActive(null)
  }

  function selectOption(option) {
    if (!option) return
    const value = option.getAttribute("data-aui-value") ?? option.textContent.trim()
    const label = option.getAttribute("data-aui-label") ?? option.textContent.trim()
    cfg.onSelect && cfg.onSelect({ option, value, label })
  }

  function onInput() {
    if (!open) openList()
    filter(input.value)
  }

  function onKeydown(e) {
    switch (e.key) {
      case "ArrowDown":
        e.preventDefault()
        if (!open) {
          openList()
          filter(input.value)
        }
        move(1)
        break
      case "ArrowUp":
        e.preventDefault()
        if (!open) {
          openList()
          filter(input.value)
        }
        move(-1)
        break
      case "Home":
        if (open) {
          e.preventDefault()
          const opts = options()
          if (opts.length) setActive(opts[0])
        }
        break
      case "End":
        if (open) {
          e.preventDefault()
          const opts = options()
          if (opts.length) setActive(opts[opts.length - 1])
        }
        break
      case "Enter": {
        const opts = options()
        const active = opts.find((o) => o.id === activeId)
        if (open && active) {
          e.preventDefault()
          selectOption(active)
        }
        break
      }
      case "Escape":
        if (open) {
          e.preventDefault()
          closeList()
        }
        break
      case "Tab":
        if (open) closeList()
        break
      default:
        break
    }
  }

  function onListPointerdown(e) {
    // Prevent the input from losing focus before we handle the click.
    const option = e.target.closest("[role=option]")
    if (option) e.preventDefault()
  }

  function onListClick(e) {
    const option = e.target.closest("[role=option]")
    if (option && list.contains(option)) selectOption(option)
  }

  input.addEventListener("input", onInput)
  input.addEventListener("keydown", onKeydown)
  list.addEventListener("pointerdown", onListPointerdown)
  list.addEventListener("click", onListClick)

  // Wire baseline ARIA if the server didn't.
  input.setAttribute("role", input.getAttribute("role") || "combobox")
  input.setAttribute("aria-autocomplete", input.getAttribute("aria-autocomplete") || "list")
  input.setAttribute("aria-expanded", "false")
  if (list.id) input.setAttribute("aria-controls", list.id)
  ensureIds()

  return {
    open: openList,
    close: closeList,
    isOpen: () => open,
    filter,
    syncAfterPatch() {
      ensureIds()
      // Re-assert active option if it still exists; else pick first.
      const opts = options()
      const still = opts.find((o) => o.id === activeId)
      if (open) setActive(still || opts[0] || null)
    },
    destroy() {
      input.removeEventListener("input", onInput)
      input.removeEventListener("keydown", onKeydown)
      list.removeEventListener("pointerdown", onListPointerdown)
      list.removeEventListener("click", onListClick)
      input.removeAttribute("aria-activedescendant")
    }
  }
}

/**
 * mountCombobox — enhance an inline combobox.
 *
 * DOM contract (on hook.el, which has `data-aui-combobox`):
 *   - `[data-aui-combobox-input]`  the text input
 *   - `[data-aui-combobox-list]`   role=listbox container of `[role=option]`
 *   - each option: `data-aui-value`, optional `data-aui-label`
 *   - optional `[data-aui-combobox-empty]` empty-state element
 *   - optional `[data-aui-combobox-clear]` clear button
 *   - `data-aui-remote` => server-side filtering
 */
export function mountCombobox(hook) {
  const el = hook.el
  const input = el.querySelector("[data-aui-combobox-input]")
  const list = el.querySelector("[data-aui-combobox-list]")
  if (!input || !list) return () => {}
  if (!list.id) list.id = `${el.id || "aui-cb"}-list`

  const id = el.id
  const push = (event, payload) =>
    typeof hook.pushEventTo === "function" && hook.pushEventTo(el, event, { id, ...payload })

  const controller = createListController({
    input,
    list,
    remote: el.hasAttribute("data-aui-remote"),
    getOptions: () => Array.from(list.querySelectorAll("[role=option]")),
    emptyEl: el.querySelector("[data-aui-combobox-empty]"),
    onFilter: (query) => push("aui:combobox:filter", { query }),
    onOpen: () => push("aui:combobox:open", {}),
    onClose: () => push("aui:combobox:close", {}),
    onSelect: ({ option, value, label }) => {
      input.value = label
      controller.close()
      push("aui:combobox:select", { value, label })
      option.setAttribute("aria-selected", "true")
    }
  })

  const clear = el.querySelector("[data-aui-combobox-clear]")
  const onClear = () => {
    input.value = ""
    controller.filter("")
    push("aui:combobox:clear", {})
    input.focus()
  }
  if (clear) clear.addEventListener("click", onClear)

  const onFocus = () => controller.open()
  input.addEventListener("focus", onFocus)

  const onDocPointer = (e) => {
    if (!el.contains(e.target)) controller.close()
  }
  document.addEventListener("pointerdown", onDocPointer, true)

  // Let the lazy wrapper forward LiveView updated() to us.
  hook._aui && (hook._aui.onUpdated = () => controller.syncAfterPatch())

  return () => {
    controller.destroy()
    if (clear) clear.removeEventListener("click", onClear)
    input.removeEventListener("focus", onFocus)
    document.removeEventListener("pointerdown", onDocPointer, true)
  }
}

/**
 * mountCommandPalette — enhance a command palette (typically inside a dialog).
 *
 * DOM contract (on hook.el, which has `data-aui-command`):
 *   - `[data-aui-command-input]`  the query input
 *   - `[data-aui-command-list]`   role=listbox of `[role=option]` commands
 *   - each option: `data-aui-value`, optional `data-aui-label`
 *   - optional `[data-aui-command-empty]` empty state
 *   - `data-aui-modal` => trap focus + lock scroll while open (palette overlay)
 *   - `data-aui-remote` => server-side filtering
 *   - `data-aui-open` reflects open/close (server- or trigger-driven)
 */
export function mountCommandPalette(hook) {
  const el = hook.el
  const input = el.querySelector("[data-aui-command-input]")
  const list = el.querySelector("[data-aui-command-list]")
  if (!input || !list) return () => {}
  if (!list.id) list.id = `${el.id || "aui-cmd"}-list`

  const id = el.id
  const modal = el.hasAttribute("data-aui-modal")
  const push = (event, payload) =>
    typeof hook.pushEventTo === "function" && hook.pushEventTo(el, event, { id, ...payload })

  let releaseTrap = null
  let locked = false
  let invoker = null

  const controller = createListController({
    input,
    list,
    remote: el.hasAttribute("data-aui-remote"),
    getOptions: () => Array.from(list.querySelectorAll("[role=option]")),
    emptyEl: el.querySelector("[data-aui-command-empty]"),
    onFilter: (query) => push("aui:command:filter", { query }),
    onOpen: () => push("aui:command:open", {}),
    onClose: () => push("aui:command:close", {}),
    onSelect: ({ value }) => {
      push("aui:command:run", { value })
      closePalette()
    }
  })

  function openPalette() {
    if (el.hasAttribute("data-aui-open") && controller.isOpen()) return
    invoker = document.activeElement
    el.setAttribute("data-aui-open", "")
    el.hidden = false
    controller.open()
    if (modal) {
      lockScroll()
      locked = true
      releaseTrap = trapFocus(el)
    }
    requestAnimationFrame(() => {
      input.focus()
      input.select && input.select()
    })
  }

  function closePalette() {
    el.removeAttribute("data-aui-open")
    controller.close()
    if (releaseTrap) {
      releaseTrap()
      releaseTrap = null
    }
    if (locked) {
      unlockScroll()
      locked = false
    }
    if (modal) el.hidden = true
    if (invoker && document.contains(invoker) && typeof invoker.focus === "function") {
      invoker.focus()
    }
    invoker = null
  }

  // Global open shortcut (Cmd/Ctrl-K) if the palette opts in.
  const shortcut = el.getAttribute("data-aui-command-shortcut") // e.g. "k"
  const onGlobalKey = (e) => {
    if (!shortcut) return
    if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === shortcut.toLowerCase()) {
      e.preventDefault()
      el.hasAttribute("data-aui-open") ? closePalette() : openPalette()
    }
  }
  if (shortcut) document.addEventListener("keydown", onGlobalKey)

  // Escape closes the whole palette (in addition to the list-level Escape).
  const onKeydown = (e) => {
    if (e.key === "Escape" && el.hasAttribute("data-aui-open")) {
      e.preventDefault()
      closePalette()
    }
  }
  el.addEventListener("keydown", onKeydown)

  // Wire the visible trigger button. It lives OUTSIDE the palette element (a
  // sibling in the `.aui-command` root) and is linked by aria-controls, so find
  // it there. Without this, only the Cmd/Ctrl-K shortcut could open the palette.
  const trigger =
    document.querySelector(`[data-aui-command-open][aria-controls="${CSS.escape(el.id)}"]`) ||
    (el.closest("[data-aui='command']") || el.parentElement || document).querySelector(
      "[data-aui-command-open]"
    )
  const onTriggerClick = (e) => {
    e.preventDefault()
    el.hasAttribute("data-aui-open") ? closePalette() : openPalette()
    if (trigger) trigger.setAttribute("aria-expanded", String(el.hasAttribute("data-aui-open")))
  }
  if (trigger) trigger.addEventListener("click", onTriggerClick)

  const onDocPointer = (e) => {
    if (!el.hasAttribute("data-aui-open")) return
    const panel = el.querySelector("[data-aui-command-panel]") || list.parentElement || el
    if (!panel.contains(e.target) && el.contains(e.target)) closePalette()
    else if (!el.contains(e.target) && !modal) closePalette()
  }
  document.addEventListener("pointerdown", onDocPointer, true)

  // Sync initial + patched open state driven by the server.
  function syncOpen() {
    const shouldOpen = el.hasAttribute("data-aui-open")
    if (shouldOpen && !controller.isOpen()) openPalette()
    else if (!shouldOpen && controller.isOpen()) closePalette()
  }
  hook._aui &&
    (hook._aui.onUpdated = () => {
      controller.syncAfterPatch()
      syncOpen()
    })
  syncOpen()

  return () => {
    controller.destroy()
    if (shortcut) document.removeEventListener("keydown", onGlobalKey)
    if (trigger) trigger.removeEventListener("click", onTriggerClick)
    el.removeEventListener("keydown", onKeydown)
    document.removeEventListener("pointerdown", onDocPointer, true)
    if (releaseTrap) releaseTrap()
    if (locked) unlockScroll()
  }
}
