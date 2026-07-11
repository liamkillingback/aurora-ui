/**
 * Aurora UI — core LiveView hooks entry point.
 *
 * This module contains ONLY the lightweight hooks needed by core components
 * (overlays, tabs, disclosure, toast, reveal/spotlight, connection state).
 * Heavier, optional capabilities live in separate entry points that are
 * dynamically imported at mount time so they never enter a consumer bundle that
 * does not render them:
 *
 *   - "aurora_ui/command"  → command palette + enhanced combobox
 *   - "aurora_ui/motion"   → advanced tilt/magnetic behavior
 *   - "aurora_ui/three"    → the Three.js scene host
 *
 * Register:
 *   import { AuroraHooks } from "aurora_ui"
 *   new LiveSocket("/live", Socket, { hooks: { ...AuroraHooks } })
 */

import { Dialog } from "./hooks/dialog"
import { Drawer } from "./hooks/drawer"
import { Popover } from "./hooks/popover"
import { Menu } from "./hooks/menu"
import { Tooltip } from "./hooks/tooltip"
import { Tabs } from "./hooks/tabs"
import { Disclosure } from "./hooks/disclosure"
import { Toast } from "./hooks/toast"
import { Reveal } from "./hooks/reveal"
import { Spotlight } from "./hooks/spotlight"
import { ConnectionState } from "./hooks/connection_state"
import { CopyButton } from "./hooks/copy_button"
import { Combobox } from "./hooks/combobox_lazy"
import { CommandPalette } from "./hooks/command_lazy"
import { SceneHost } from "./hooks/scene_lazy"
import { Tilt } from "./hooks/tilt_lazy"

export const AuroraHooks = {
  AuroraDialog: Dialog,
  AuroraDrawer: Drawer,
  AuroraPopover: Popover,
  AuroraMenu: Menu,
  AuroraTooltip: Tooltip,
  AuroraTabs: Tabs,
  AuroraDisclosure: Disclosure,
  AuroraToast: Toast,
  AuroraReveal: Reveal,
  AuroraSpotlight: Spotlight,
  AuroraConnectionState: ConnectionState,
  AuroraCopyButton: CopyButton,
  // Lazy wrappers — the real implementation is code-split and imported on mount.
  AuroraCombobox: Combobox,
  AuroraCommandPalette: CommandPalette,
  AuroraSceneHost: SceneHost,
  AuroraTilt: Tilt
}

export default AuroraHooks
