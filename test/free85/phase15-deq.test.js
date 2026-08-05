import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const GRAPH_ENABLED = 0x8501;
const GRAPH_ACTIVE = 0x8502;
const GRAPH_TRACE_X = 0x8504;
const GRAPH_EQ1 = 0x8510;
const GRAPH_XMIN = 0x8600;
const GRAPH_XMAX = 0x8609;
const GRAPH_XSTEP = 0x8624;
const GRAPH_RESULT_Y = 0x867e;
const GRAPH_MODE = 0x869a;
const GRAPH_LAST_ERROR = 0x869c;
const P16_INITIAL_X = 0x8760;
const P16_INITIAL_Y = 0x8769;
const P16_METHOD = 0x877b;
const NAME_BUFFER = 0x80c0;

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

function writeEquation(harness, source) {
  harness.machine.write8(GRAPH_EQ1, source.length);
  [...source].forEach((character, index) => harness.machine.write8(GRAPH_EQ1 + 1 + index, character.charCodeAt(0)));
  harness.machine.write8(GRAPH_ENABLED, 1);
}

function finishPlot(harness, limit = 20000) {
  let frames = 0;
  while (harness.machine.read8(GRAPH_ACTIVE) && frames < limit) {
    harness.machine.runFrame();
    frames += 1;
  }
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0, `plot exceeded ${limit} frames`);
  return frames;
}

function openModePage(harness) {
  harness.runFrames(3);
  for (const key of ["2ND", "MORE", "MORE", "MORE"]) harness.tap(key);
}

function callStore(machine, address, { A = 0, BC = 0, HL = 0 } = {}) {
  machine.writePort(0x05, 7);
  machine.write8(0x800a, 7);
  const stack = 0xfae0;
  const sentinel = 0x0200;
  machine.write16(stack, sentinel);
  const state = machine.cpu.getState();
  machine.cpu.setState({
    ...state,
    registers: { ...state.registers, A, B: BC >> 8, C: BC, H: HL >> 8, L: HL, SP: stack, PC: address },
    IFF1: false, IFF2: false, halted: false, pendingInterrupt: false
  });
  for (let steps = 0; machine.cpu.PC !== sentinel; steps += 1) {
    assert.ok(steps < 100_000, "object-store call did not return");
    machine.step();
  }
  const result = machine.cpu.getState();
  machine.writePort(0x05, 1);
  machine.write8(0x800a, 1);
  machine.cpu.setState(state);
  return result;
}

function createLegacyGdeq(harness) {
  for (let index = 0; index < 9; index += 1) {
    harness.machine.write8(NAME_BUFFER + index, index < 4 ? "GDEQ".charCodeAt(index) : 0);
  }
  const state = callStore(harness.machine, 0x400e, { A: 10, BC: 213, HL: NAME_BUFFER });
  assert.equal(state.flags.C, false);
  const entry = state.registers.HL;
  const payload = state.registers.DE;
  harness.machine.write8(payload, 1);
  harness.machine.write8(payload + 1, 0);
  harness.machine.write8(payload + 2, 0);
  packed(2).forEach((byte, index) => harness.machine.write8(payload + 3 + index, byte));
  for (let index = 0; index < 36; index += 1) harness.machine.write8(payload + 12 + index, harness.machine.read8(GRAPH_XMIN + index));
  for (let index = 0; index < 18; index += 1) harness.machine.write8(payload + 48 + index, harness.machine.read8(0x8636 + index));
  for (let index = 0; index < 147; index += 1) harness.machine.write8(payload + 66 + index, 0);
  harness.machine.write8(payload + 66, 1);
  harness.machine.write8(payload + 67, "1".charCodeAt(0));
  return { entry, payload };
}

function configuredDeq({ equation = "1", x0 = -10, y0 = 0, method = 0, xmin = -10, xmax = 10 } = {}) {
  const harness = Free85Harness.boot();
  harness.tap("GRAPH");
  finishPlot(harness);
  harness.runFrames(3);
  harness.machine.write8(GRAPH_MODE, 3);
  writeEquation(harness, equation);
  writeNumber(harness, GRAPH_XMIN, xmin);
  writeNumber(harness, GRAPH_XMAX, xmax);
  writeNumber(harness, P16_INITIAL_X, x0);
  writeNumber(harness, P16_INITIAL_Y, y0);
  harness.machine.write8(P16_METHOD, method);
  harness.tap("GRAPH");
  return harness;
}

function solveTrace(method, step, steps) {
  const harness = configuredDeq({ equation: "Y", x0: 0, y0: 1, method, xmin: 0, xmax: 1 });
  finishPlot(harness, 30000);
  harness.runFrames(3);
  writeNumber(harness, GRAPH_XSTEP, step);
  harness.machine.write8(GRAPH_TRACE_X, steps - 1);
  harness.tap("RIGHT");
  harness.runFrames(3000);
  return harness.packedNumber(GRAPH_RESULT_Y);
}

test("[phase15.deq-setup] X0, Y0, method, reset, and redraw have a visible editing page", () => {
  const harness = configuredDeq();
  finishPlot(harness);
  harness.runFrames(3);
  harness.tap("2ND");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("MORE");
  harness.tap("MORE");
  assertLcdGolden("phase15-deq-setup", harness.machine.renderLcdBitmap());

  harness.tap("F1");
  assert.equal(harness.machine.read8(P16_METHOD), 1, "F1 selects Heun");
  harness.tap("F2");
  harness.tap("+");
  assert.equal(harness.packedNumber(P16_INITIAL_X), -9);
  harness.tap("F3");
  harness.tap("+");
  assert.equal(harness.packedNumber(P16_INITIAL_Y), 1);
  harness.tap("F4");
  assert.equal(harness.packedNumber(P16_INITIAL_X), -10);
  assert.equal(harness.packedNumber(P16_INITIAL_Y), 0);
  assert.equal(harness.machine.read8(P16_METHOD), 0);
});

test("[phase15.deq-orders] Euler, Heun, and RK4 exhibit first-, second-, and fourth-order convergence", () => {
  const ratios = [];
  for (const method of [0, 1, 2]) {
    const coarse = Math.abs(solveTrace(method, 0.1, 10) - Math.E);
    const fine = Math.abs(solveTrace(method, 0.05, 20) - Math.E);
    ratios.push(coarse / fine);
  }
  assert.ok(ratios[0] > 1.8 && ratios[0] < 2.3, `Euler ratio ${ratios[0]}`);
  assert.ok(ratios[1] > 3.5 && ratios[1] < 4.5, `Heun ratio ${ratios[1]}`);
  assert.ok(ratios[2] > 12 && ratios[2] < 20, `RK4 ratio ${ratios[2]}`);
});

test("[phase15.deq-persistence] edited setup survives mode switches without deleting GDEQ", () => {
  const harness = configuredDeq({ x0: -9, y0: 2, method: 2 });
  finishPlot(harness);
  openModePage(harness);
  harness.tap("F1");
  finishPlot(harness);
  openModePage(harness);
  harness.tap("F4");
  finishPlot(harness);
  assert.equal(harness.packedNumber(P16_INITIAL_X), -9);
  assert.equal(harness.packedNumber(P16_INITIAL_Y), 2);
  assert.equal(harness.machine.read8(P16_METHOD), 2);
  assert.equal(harness.machine.read8(GRAPH_EQ1), 1);
});

test("[phase15.deq-migration] a v1 GDEQ loads compatibly and grows transactionally on save", () => {
  const harness = Free85Harness.boot();
  const { entry } = createLegacyGdeq(harness);
  harness.tap("GRAPH");
  finishPlot(harness);
  openModePage(harness);
  harness.tap("F4");
  finishPlot(harness);
  assert.equal(harness.packedNumber(P16_INITIAL_X), -10, "legacy X0 derives from Xmin");
  assert.equal(harness.packedNumber(P16_INITIAL_Y), 2);
  assert.equal(harness.machine.read8(P16_METHOD), 0);
  assert.equal(harness.machine.read16(entry + 13), 213, "load is non-mutating");

  openModePage(harness);
  harness.tap("F1");
  finishPlot(harness);
  assert.equal(harness.machine.read16(entry + 13), 224);
  const payload = harness.machine.read16(entry + 11);
  assert.equal(harness.machine.read8(payload), 2);
});

test("[phase15.deq-work-limit] distant initial conditions fail with bounded non-convergence", () => {
  const harness = configuredDeq({ x0: 100, y0: 0 });
  harness.runFrames(6000);
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
  assert.equal(harness.machine.read8(GRAPH_LAST_ERROR), 6);
});

test("[phase15.deq-cancel] EXIT cancels a long initial-condition solve", () => {
  const harness = configuredDeq({ x0: 100, y0: 0, method: 2 });
  harness.machine.pressKey("EXIT");
  for (let frames = 0; frames < 500 && harness.machine.read8(GRAPH_LAST_ERROR) !== 7; frames += 1) {
    harness.machine.runFrame();
  }
  harness.machine.releaseKey("EXIT");
  assert.equal(harness.machine.read8(GRAPH_ACTIVE), 0);
  assert.equal(harness.machine.read8(GRAPH_LAST_ERROR), 7);
});
