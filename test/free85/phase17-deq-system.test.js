import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_TRACE_X = 0x8504;
const GRAPH_EQ1 = 0x8510;
const GRAPH_EQ2 = 0x8541;
const GRAPH_XMIN = 0x8600;
const GRAPH_XMAX = 0x8609;
const GRAPH_YMIN = 0x8612;
const GRAPH_YMAX = 0x861b;
const GRAPH_XSTEP = 0x8624;
const GRAPH_TABLE_STEP = 0x863f;
const GRAPH_WORK_3 = 0x866c;
const GRAPH_RESULT_X = 0x8675;
const GRAPH_RESULT_Y = 0x867e;
const GRAPH_MODE = 0x869a;
const P23_INITIAL_Y2 = 0x8756;
const P23_SYSTEM_FLAGS = 0x875f;
const P16_INITIAL_X = 0x8760;
const P16_INITIAL_Y = 0x8769;
const P16_METHOD = 0x877b;
const P23_FLAG_SYSTEM = 1;
const P23_FLAG_PHASE = 2;

function packed(value) {
  if (value === 0) return Uint8Array.of(0, 0, 0, 0, 0, 0, 0, 0, 0);
  const sign = value < 0 ? 0x80 : 0;
  const magnitude = Math.abs(value);
  const exponent = Math.floor(Math.log10(magnitude));
  const digits = (magnitude / (10 ** exponent)).toPrecision(14).replace(".", "").slice(0, 14);
  return Uint8Array.of(sign, exponent < 0 ? exponent + 256 : exponent,
    ...Array.from({ length: 7 }, (_, index) => (Number(digits[index * 2]) << 4) | Number(digits[index * 2 + 1])));
}

function writeNumber(harness, address, value) {
  packed(value).forEach((byte, index) => harness.machine.write8(address + index, byte));
}

function writeSlot(harness, address, source) {
  harness.machine.write8(address, source.length);
  [...source].forEach((character, index) => harness.machine.write8(address + 1 + index, character.charCodeAt(0)));
}

function finishPlot(harness, limit = 40_000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < limit) {
    harness.machine.runFrame();
    frames += 1;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `system plot exceeded ${limit} frames`);
}

function configuredSystem({ method = 2, phase = false } = {}) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness);
  harness.runFrames(3);
  harness.machine.write8(GRAPH_MODE, 3);
  harness.machine.write8(GRAPH_ENABLED, 3);
  harness.machine.write8(P23_SYSTEM_FLAGS, P23_FLAG_SYSTEM | (phase ? P23_FLAG_PHASE : 0));
  harness.machine.write8(P16_METHOD, method);
  writeSlot(harness, GRAPH_EQ1, "Y");
  writeSlot(harness, GRAPH_EQ2, "0-X");
  writeNumber(harness, P16_INITIAL_X, 0);
  writeNumber(harness, P16_INITIAL_Y, 1);
  writeNumber(harness, P23_INITIAL_Y2, 0);
  writeNumber(harness, GRAPH_XMIN, phase ? -1.2 : 0);
  writeNumber(harness, GRAPH_XMAX, phase ? 1.2 : 6.4);
  writeNumber(harness, GRAPH_YMIN, -1.2);
  writeNumber(harness, GRAPH_YMAX, 1.2);
  if (phase) writeNumber(harness, GRAPH_TABLE_STEP, 0.05);
  harness.tap("GRAPH");
  finishPlot(harness);
  return harness;
}

function solve(method, step, steps) {
  const harness = configuredSystem({ method });
  writeNumber(harness, GRAPH_XSTEP, step);
  harness.machine.write8(GRAPH_TRACE_X, steps - 1);
  harness.tap("RIGHT");
  harness.runFrames(4000);
  return {
    x: harness.packedNumber(GRAPH_RESULT_Y),
    y: harness.packedNumber(GRAPH_WORK_3)
  };
}

test("[phase17.3.system-orders] both coupled states share Euler, Heun, and RK4 stages", () => {
  for (const [method, range] of [[0, [1.7, 2.4]], [1, [3.3, 4.8]], [2, [10, 24]]]) {
    const coarse = solve(method, 0.1, 10);
    const fine = solve(method, 0.05, 20);
    const coarseError = Math.hypot(coarse.x - Math.cos(1), coarse.y + Math.sin(1));
    const fineError = Math.hypot(fine.x - Math.cos(1), fine.y + Math.sin(1));
    const ratio = coarseError / fineError;
    assert.ok(ratio > range[0] && ratio < range[1], `method ${method} convergence ratio ${ratio}`);
  }
});

test("[phase17.3.views] time and phase-plane views produce reviewed framebuffers", () => {
  const time = configuredSystem();
  assertLcdGolden("phase17-deq-system-time", time.machine.renderLcdBitmap());
  const phase = configuredSystem({ phase: true });
  assertLcdGolden("phase17-deq-phase-plane", phase.machine.renderLcdBitmap());
  assert.equal(phase.machine.read8(P23_SYSTEM_FLAGS), P23_FLAG_SYSTEM | P23_FLAG_PHASE);
  phase.runFrames(20);
  assert.equal(phase.machine.read8(0x869c), 0, "phase plot preparation succeeds");
  assert.equal(phase.machine.read8(0x850e), 0, "plot input guard clears after key release");
  assert.equal(phase.machine.read8(0x8691), 0, "phase plot leaves no panel open");
  assert.equal(phase.machine.read8(0x800b), 2, "phase plot remains on graph screen");
  const beforeTrace = phase.machine.read8(GRAPH_TRACE_X);
  phase.tap("RIGHT");
  assert.equal(phase.machine.read8(GRAPH_TRACE_X), beforeTrace + 1, "RIGHT starts a phase trace sample");
  phase.runFrames(20_000);
  const traceX = phase.packedNumber(GRAPH_RESULT_X);
  const traceY = phase.packedNumber(GRAPH_RESULT_Y);
  assert.ok(Math.abs(traceX) <= 1.01, `trace X is the first state, got ${traceX}`);
  assert.ok(Math.abs(traceY) <= 1.01, `trace Y is the second state, got ${traceY}`);
});

test("[phase17.3.setup] SYS, initial-state selection, and MORE view toggle are explicit", () => {
  const harness = configuredSystem();
  for (const key of ["2ND", "MORE", "MORE", "MORE", "MORE"]) harness.tap(key);
  assertLcdGolden("phase17-deq-system-setup", harness.machine.renderLcdBitmap());
  harness.tap("MORE");
  assert.equal(harness.machine.read8(P23_SYSTEM_FLAGS), P23_FLAG_SYSTEM | P23_FLAG_PHASE);
  harness.tap("F3");
  harness.tap("F3");
  harness.tap("+");
  assert.equal(harness.packedNumber(P23_INITIAL_Y2), 1, "third field edits system Y0");
  harness.tap("F1");
  assert.equal(harness.machine.read8(P23_SYSTEM_FLAGS), 0, "single mode clears the phase-only flag");
});

test("[phase17.3.persistence] coupled equations, view, method, and three initial values survive mode switches", () => {
  const harness = configuredSystem({ phase: true });
  harness.runFrames(20);
  for (const key of ["2ND", "MORE", "MORE", "MORE", "F1"]) harness.tap(key);
  finishPlot(harness);
  harness.runFrames(20);
  for (const key of ["2ND", "MORE", "MORE", "MORE", "F4"]) harness.tap(key);
  finishPlot(harness);
  assert.equal(harness.machine.read8(P23_SYSTEM_FLAGS), P23_FLAG_SYSTEM | P23_FLAG_PHASE);
  assert.equal(harness.machine.read8(P16_METHOD), 2);
  assert.equal(harness.packedNumber(P16_INITIAL_X), 0);
  assert.equal(harness.packedNumber(P16_INITIAL_Y), 1);
  assert.equal(harness.packedNumber(P23_INITIAL_Y2), 0);
  assert.equal(harness.machine.read8(GRAPH_EQ1), 1);
  assert.equal(harness.machine.read8(GRAPH_EQ2), 3);
});

test("[phase17.3.cancel] a long coupled solve remains cancellable", () => {
  const harness = configuredSystem();
  harness.runFrames(20);
  writeNumber(harness, P16_INITIAL_X, 100);
  harness.tap("GRAPH");
  harness.machine.pressKey("EXIT");
  for (let frames = 0; frames < 500 && harness.machine.read8(0x869c) !== 7; frames += 1) {
    harness.machine.runFrame();
  }
  harness.machine.releaseKey("EXIT");
  assert.equal(harness.machine.read8(0x869c), 7);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
});
