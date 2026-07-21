import { Free85Harness } from "../test/helpers/free85-harness.js";
import { writeLcdGolden } from "../test/helpers/lcd-visual.js";

const ACTIVE = 0x8502;
function finish(harness, limit = 10000) {
  let frames = 0;
  while (harness.machine.read8(ACTIVE) && frames < limit) {
    harness.runFrames(100);
    frames += 100;
  }
  if (harness.machine.read8(ACTIVE)) throw new Error(`plot exceeded ${limit} frames`);
}
function select(harness, key) {
  for (const item of ["2ND", "MORE", "MORE", "MORE", key]) harness.tap(item);
  finish(harness);
}
function type(harness, expression) {
  for (const character of expression) harness.tap(character === "X" ? "X-VAR" : character);
}
function prepare(mode, first, second) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finish(harness);
  select(harness, mode);
  harness.tap("EXIT");
  type(harness, first);
  harness.tap("GRAPH");
  finish(harness);
  if (second) {
    harness.tap("2ND");
    harness.tap("2");
    type(harness, second);
    harness.tap("GRAPH");
    finish(harness);
  }
  return harness.machine.renderLcdBitmap();
}
for (const [name, mode, first, second] of [
  ["phase16-polar-circle", "F2", "5"],
  ["phase16-parametric", "F3", "X", "X^2"],
  ["phase16-diffeq", "F4", "1"]
]) {
  const bitmap = prepare(mode, first, second);
  writeLcdGolden(name, bitmap);
  console.log(`Approved ${name}: ${bitmap.litPixelCount} pixels`);
}
