import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";
import { readNumericLines } from "../../scripts/free85-lcd-ocr.js";

const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_EQ1 = 0x8510;
const GRAPH_EQ2 = 0x8541;
const GRAPH_EQ3 = 0x8572;
const GRAPH_LAST_ERROR = 0x869c;
const SCREEN_MODE = 0x800b;

function writeSlot(harness, address, source) {
  harness.machine.write8(address, source.length);
  for (let index = 0; index < source.length; index += 1) {
    harness.machine.write8(address + 1 + index, source.charCodeAt(index));
  }
}

function finishPlot(harness, limit = 10000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < limit) {
    harness.runFrames(100);
    frames += 100;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${limit} frames`);
  return frames;
}

function plotSlots(sources, enabled, limit = 10000) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness);
  for (const [index, source] of sources.entries()) {
    writeSlot(harness, [GRAPH_EQ1, GRAPH_EQ2, GRAPH_EQ3][index], source);
  }
  harness.machine.write8(GRAPH_ENABLED, enabled);
  harness.tap("GRAPH");
  const frames = finishPlot(harness, limit);
  return { harness, frames };
}

function tableRows(harness) {
  return readNumericLines(harness.machine.renderLcdBitmap(), { originX: 0, originY: 0 })
    .filter(({ row }) => row >= 1 && row <= 6)
    .map(({ text }) => text.replace(/\s+/g, " "));
}

test("[phase15.calculus-derivative-plot] explicit NDER target plots and tabulates without caller-state damage", () => {
  const { harness, frames } = plotSlots(["X^2", "NDER(1,X)"], 3);
  assert.ok(frames <= 1000, `derivative plot used ${frames} frames`);
  assertLcdGolden("phase15-calculus-derivative", harness.machine.renderLcdBitmap());

  harness.tap("MORE");
  harness.runFrames(1200);
  assert.equal(harness.machine.read8(SCREEN_MODE), 3);
  assert.deepEqual(tableRows(harness), [
    "0 0 0 -", "1 1 2 -", "2 4 4 -", "3 9 6 -", "4 16 8 -", "5 25 10 -"
  ]);
});

test("[phase15.calculus-accumulator-plot] explicit FNINT target produces a bounded accumulator plot and table", () => {
  const { harness, frames } = plotSlots(["2*X", "FNINT(1,0,X)"], 3, 25000);
  assert.ok(frames <= 25000, `accumulator plot used ${frames} frames`);
  assertLcdGolden("phase15-calculus-accumulator", harness.machine.renderLcdBitmap());

  harness.tap("MORE");
  harness.runFrames(2500);
  assert.equal(harness.machine.read8(SCREEN_MODE), 3);
  assert.deepEqual(tableRows(harness), [
    "0 0 0 -", "1 2 1 -", "2 4 4 -", "3 6 9 -", "4 8 16 -", "5 10 25 -"
  ]);
});

test("[phase15.calculus-cycles] direct and indirect slot cycles fail while unrelated equations continue", () => {
  const direct = plotSlots(["NDER(1,X)", "X"], 3);
  const directReference = plotSlots(["", "X"], 2);
  assert.deepEqual(
    direct.harness.machine.renderLcdBitmap().pixels,
    directReference.harness.machine.renderLcdBitmap().pixels,
    "a direct Y1 cycle leaves the unrelated Y2 graph intact"
  );
  assert.equal(direct.harness.machine.read8(GRAPH_LAST_ERROR), 5);

  const indirect = plotSlots(["EVAL(2,X)", "EVAL(1,X)", "X"], 7);
  const indirectReference = plotSlots(["", "", "X"], 4);
  assert.deepEqual(
    indirect.harness.machine.renderLcdBitmap().pixels,
    indirectReference.harness.machine.renderLcdBitmap().pixels,
    "an indirect Y1/Y2 cycle leaves the unrelated Y3 graph intact"
  );
  assert.equal(indirect.harness.machine.read8(GRAPH_LAST_ERROR), 5);
});
