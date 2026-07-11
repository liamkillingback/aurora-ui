#!/usr/bin/env node
/**
 * Aurora UI — bundle budget & code-splitting proof.
 *
 * Enforces the plan's hard rule: "a build importing only a button contains no
 * overlay, command, animation, or Three.js code." We check this structurally by
 * verifying that the core entry graph never *statically* imports the heavy,
 * lazy-only entry points — those must be reached with dynamic `import()` so a
 * bundler code-splits them out of any chunk that doesn't render their component.
 *
 * Also enforces coarse size budgets on the shipped CSS.
 *
 * Exit non-zero on any violation. Run in CI (see .github/workflows/ci.yml).
 */
import { readFileSync, existsSync, statSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const js = join(root, "assets", "js");

let failures = 0;
const fail = (msg) => {
  console.error(`✗ ${msg}`);
  failures++;
};
const ok = (msg) => console.log(`✓ ${msg}`);

// 1. The lazy-only entry points must never be reached by a STATIC import from
//    the core graph. They may only appear inside a dynamic import().
//    Match the actual heavy entry modules precisely — NOT the `*_lazy` wrappers,
//    which legitimately live in core and merely share a name stem.
const heavyEntryRe = [
  /(^|\/)command(\.js)?$/, // ./command, ../command
  /(^|\/)motion(\.js)?$/, // ./motion, ../motion
  /(^|\/)three\/scene(\.js)?$/, // ../three/scene
  /^three$/ // the three package itself
];
const isHeavyEntry = (spec) => heavyEntryRe.some((re) => re.test(spec));
const coreFiles = [
  "index.js",
  "hooks/dialog.js",
  "hooks/drawer.js",
  "hooks/popover.js",
  "hooks/menu.js",
  "hooks/tooltip.js",
  "hooks/tabs.js",
  "hooks/disclosure.js",
  "hooks/toast.js",
  "hooks/reveal.js",
  "hooks/spotlight.js",
  "hooks/connection_state.js",
  "hooks/copy_button.js",
  "hooks/combobox_lazy.js",
  "hooks/command_lazy.js",
  "hooks/scene_lazy.js",
  "hooks/tilt_lazy.js"
];

// Matches a static import statement (not a dynamic import() call expression).
const staticImportRe =
  /^\s*import\s[^;]*?from\s*["']([^"']+)["']|^\s*import\s*["']([^"']+)["']/gm;

for (const rel of coreFiles) {
  const path = join(js, rel);
  if (!existsSync(path)) {
    fail(`core file missing: assets/js/${rel}`);
    continue;
  }
  const src = readFileSync(path, "utf8");
  let m;
  staticImportRe.lastIndex = 0;
  while ((m = staticImportRe.exec(src))) {
    const spec = m[1] || m[2];
    if (isHeavyEntry(spec)) {
      fail(`assets/js/${rel} STATICALLY imports heavy entry "${spec}" — must be dynamic import()`);
    }
  }
}
if (failures === 0) ok("core JS never statically imports command/motion/three");

// 2. The lazy wrappers must actually use a dynamic import().
const lazyPairs = [
  ["hooks/combobox_lazy.js", "command"],
  ["hooks/command_lazy.js", "command"],
  ["hooks/scene_lazy.js", "scene"],
  ["hooks/tilt_lazy.js", "motion"]
];
for (const [rel, needle] of lazyPairs) {
  const path = join(js, rel);
  if (!existsSync(path)) continue;
  const src = readFileSync(path, "utf8");
  if (!/import\s*\(/.test(src)) {
    fail(`assets/js/${rel} should use a dynamic import() to load "${needle}"`);
  }
}
if (failures === 0) ok("lazy wrappers use dynamic import()");

// 3. CSS budgets (uncompressed source; a coarse guard, refined with gzip in
//    docs/evidence/phase-08/performance.md).
const cssBudgets = [
  ["assets/css/aurora_ui.css", 40 * 1024]
];
for (const [rel, budget] of cssBudgets) {
  const path = join(root, rel);
  if (!existsSync(path)) {
    fail(`css missing: ${rel}`);
    continue;
  }
  const size = statSync(path).size;
  if (size > budget) {
    fail(`${rel} is ${size}B, over budget ${budget}B`);
  } else {
    ok(`${rel} ${size}B within ${budget}B budget`);
  }
}

if (failures > 0) {
  console.error(`\n${failures} bundle-budget violation(s).`);
  process.exit(1);
}
console.log("\nAll bundle budgets pass.");
