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
  // Store X^2-4 as Y1 from the home entry line and let the plot finish.
  { name: "ch04-parabola-plot", keys: ["X-VAR", "X^2", "-", "4", "GRAPH", 600] },
  // Same plot, then trace two columns right of centre to show the X=/Y=
  // coordinate readout at the bottom of the graph screen.
  { name: "ch04-trace", keys: ["X-VAR", "X^2", "-", "4", "GRAPH", 600, "RIGHT", 30, "RIGHT", 30] },
  // Y1=X, then 2nd 2 on the graph screen selects the empty Y2 slot and
  // returns home; 2-X stored there plots both slots together.
  { name: "ch04-two-equations", keys: ["X-VAR", "GRAPH", 100, "2ND", "2", 10, "2", "-", "X-VAR", "GRAPH", 1200] },
  // MORE on the graph screen opens the table of values.
  { name: "ch04-table", keys: ["X-VAR", "X^2", "-", "4", "GRAPH", 600, "MORE", 120] },
  // F1 on the graph screen finds a root of the active equation and
  // publishes it on the home screen with its residual line.
  { name: "ch04-root-result", keys: ["X-VAR", "X^2", "-", "4", "GRAPH", 600, "F1", 1500] },
  { name: "ch08-constants-menu", keys: ["2ND", "4"] },
  // CTOF( from the conversions menu's second page, applied to 100 degrees
  // Celsius, shows a conversion evaluated on the home screen.
  { name: "ch08-conversion-example", keys: ["2ND", "5", "MORE", "F4", "1", "0", "0", ")", "ENTER", 200] },
  // The strings editor opens on empty registers, so the capture types HELLO
  // into register A first (letters are ALPHA plus the letter's key).
  {
    name: "ch09-strings-editor",
    keys: ["2ND", "6", "ALPHA", "(", "ALPHA", "^", "ALPHA", "7", "ALPHA", "7", "ALPHA", "*"]
  },
  // 42 evaluated on the home screen, then the number-base screen's HEX view.
  { name: "ch10-number-base", keys: ["4", "2", "ENTER", "2ND", "1", "F2"] },
  // The collections editors open on zeroed registers, so each capture enters
  // the values its chapter's examples use before photographing the screen.
  { name: "ch11-complex-editor", keys: ["2ND", "9", "3", "ENTER", "4", "ENTER"] },
  {
    name: "ch12-list-editor",
    keys: ["2ND", "-", "4", "ENTER", "1", "ENTER", "3", "ENTER", "2", "ENTER"]
  },
  {
    name: "ch13-matrix-editor",
    keys: ["2ND", "7", "1", "ENTER", "2", "ENTER", "3", "ENTER", "4", "ENTER"]
  },
  // The same matrix, inverted with F3; the frames let the division finish.
  {
    name: "ch13-matrix-inverse",
    keys: ["2ND", "7", "1", "ENTER", "2", "ENTER", "3", "ENTER", "4", "ENTER", "F3", 600]
  },
  { name: "ch13-vector-editor", keys: ["2ND", "8", "3", "ENTER", "4", "ENTER", "0", "ENTER"] },
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
