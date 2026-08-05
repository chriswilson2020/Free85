import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function enterValues(harness, values) {
  for (const value of values) {
    for (const character of String(value)) harness.tap(character === "-" ? "(-)" : character);
    harness.tap("ENTER");
  }
}

const simult = Free85Harness.boot();
tapAll(simult, ["2ND", "STAT", "RIGHT"]);
writeLcdGolden("phase16-simult-cell-1-2", simult.machine.renderLcdBitmap());

const lu = Free85Harness.boot();
tapAll(lu, ["2ND", "7"]);
enterValues(lu, [0, 1, 2, 3]);
tapAll(lu, ["MORE", "MORE", "MORE", "MORE", "F1"]);
lu.runFrames(1500);
writeLcdGolden("phase16-lu-permutation", lu.machine.renderLcdBitmap());

console.log("Approved Phase 16 release LCD fixtures");
