import { mkdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { Free85Harness } from "../test/helpers/free85-harness.js";
import { renderLcdPng } from "../test/helpers/lcd-visual.js";

const OUT_DIR = fileURLToPath(new URL("../docs/guidebook/images/", import.meta.url));

// Each case boots a fresh machine and taps the listed keys. A number in the
// key list means "run that many frames" and is used to let slow work (such as
// an incremental graph plot) finish before the next key or the capture.
// Names must be kebab-case and are referenced from the Markdown chapters.
export const SCREEN_CASES = [
  { name: "ch01-home-screen", keys: [] },
  { name: "ch01-mode-screen", keys: ["2ND", "MORE"] },
  // The palette opens on the space character, which renders as an empty
  // middle, so the capture steps one character right to show a visible glyph.
  { name: "ch01-char-palette", keys: ["2ND", "0", "RIGHT"] },
  { name: "ch01-error-screen", keys: ["1", "/", "0", "ENTER"] },
  { name: "ch02-store-recall", keys: ["5", "STO", "ALPHA", "LOG", "ENTER"] },
  { name: "ch02-variables-browser", keys: ["2ND", "STO"] },
  { name: "ch02-memory-stored", keys: ["4", "2", "2ND", "F1"] },
  { name: "ch03-test-menu", keys: ["2ND", "2"] },
  // Store X^2 as Y1 (entry line + GRAPH), let the plot finish, return to the
  // home screen, and evaluate the active equation at 3 with EVAL(3).
  {
    name: "ch03-calculus-eval",
    keys: ["X-VAR", "X^2", "GRAPH", 600, "EXIT", "CLEAR",
      "ALPHA", "^", "ALPHA", "2", "ALPHA", "LOG", "ALPHA", "7",
      "(", "3", ")", "ENTER", 120]
  },
  { name: "ch18-memory-browser", keys: ["2ND", "+"] },
  { name: "manual-boot", keys: [] },
  { name: "manual-first-calc", keys: ["2", "+", "3", "ENTER"] },
  // GRAPH alone plots the axes without labels, so the soft-menu example uses
  // the home screen's first soft item (F1 = MATH), which shows a paged menu.
  { name: "manual-soft-menu", keys: ["F1"] },
  { name: "manual-catalog", keys: ["2ND", "CUSTOM"] }
];

function capture({ keys }) {
  const harness = Free85Harness.boot();
  for (const key of keys) {
    if (typeof key === "number") harness.runFrames(key);
    else harness.tap(key);
  }
  return harness.machine.renderLcdBitmap();
}

mkdirSync(OUT_DIR, { recursive: true });
for (const screenCase of SCREEN_CASES) {
  if (!/^[a-z0-9-]+$/.test(screenCase.name)) throw new Error(`bad name ${screenCase.name}`);
  writeFileSync(`${OUT_DIR}${screenCase.name}.png`, renderLcdPng(capture(screenCase)));
  console.log(`wrote ${screenCase.name}.png`);
}
