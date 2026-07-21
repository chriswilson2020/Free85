import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const GRAPH_EQ1 = 0x8510;
const GRAPH_EQ2 = 0x8541;
const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_MODE = 0x869a;
const GRAPH_RESULT_X = 0x8675;
const GRAPH_RESULT_Y = 0x867e;

function finishPlot(harness, limit = 10000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < limit) {
    harness.runFrames(100);
    frames += 100;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${limit} frames`);
}

function selectMode(harness, key) {
  harness.tap("2ND");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap(key);
  finishPlot(harness);
}

function type(harness, expression) {
  for (const character of expression) {
    if (character === "X") harness.tap("X-VAR");
    else if (character === "-") harness.tap("(-)");
    else harness.tap(character);
  }
}

function enterModeEquation(modeKey, expression) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness);
  selectMode(harness, modeKey);
  harness.tap("EXIT");
  type(harness, expression);
  harness.tap("GRAPH");
  finishPlot(harness);
  return harness;
}

test("[graph.polar] polar editor plots, traces, tables, and preserves its equation", () => {
  const harness = enterModeEquation("F2", "5");
  assert.equal(harness.machine.read8(GRAPH_MODE), 1);
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 1, 1);
  assertLcdGolden("phase16-polar-circle", harness.machine.renderLcdBitmap());
  harness.tap("MORE");
  assert.equal(harness.machine.read8(0x800b), 3);
  harness.tap("GRAPH");
  finishPlot(harness);
  for (const key of ["2ND", "MORE", "MORE", "MORE", "F5", "EXIT"]) harness.tap(key);
  finishPlot(harness);
  harness.tap("RIGHT");
  assert.ok(Math.abs(harness.packedNumber(GRAPH_RESULT_X) - 5) < 1e-8, "PolarGC trace reports radius");
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_Y)), "PolarGC trace reports theta");
  selectMode(harness, "F1");
  selectMode(harness, "F2");
  assert.equal(harness.machine.read8(GRAPH_EQ1), 1);
  assert.equal(harness.machine.read8(GRAPH_EQ1 + 1), "5".charCodeAt(0));
});

test("[graph.parametric] paired x(t),y(t) editors render through the shared engine", () => {
  const harness = enterModeEquation("F3", "X");
  harness.tap("2ND");
  harness.tap("2");
  type(harness, "X^2");
  harness.tap("GRAPH");
  finishPlot(harness);
  assert.equal(harness.machine.read8(GRAPH_MODE), 2);
  assert.equal(harness.machine.read8(GRAPH_EQ2), 3);
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 3, 3);
  assertLcdGolden("phase16-parametric", harness.machine.renderLcdBitmap());
  harness.tap("LEFT");
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_X)));
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_Y)));
  harness.tap("MORE");
  assert.equal(harness.machine.read8(0x800b), 3);
});

test("[graph.diffeq] Euler solve, trace reintegration, table, and cancellation are deterministic", () => {
  const harness = enterModeEquation("F4", "1");
  assert.equal(harness.machine.read8(GRAPH_MODE), 3);
  assertLcdGolden("phase16-diffeq", harness.machine.renderLcdBitmap());
  harness.tap("LEFT");
  assert.ok(Number.isFinite(harness.packedNumber(GRAPH_RESULT_Y)));
  harness.tap("MORE");
  assert.equal(harness.machine.read8(0x800b), 3);
  harness.tap("GRAPH");
  harness.runFrames(8);
  if (harness.machine.read8(0x800b) === 3) harness.tap("GRAPH");
  while (harness.machine.read8(0x850e)) harness.runFrames(1);
  assert.equal(harness.machine.read8(0x800b), 2);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 1);
  harness.runFrames(8);
  harness.tap("EXIT");
  harness.runFrames(8);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
});
