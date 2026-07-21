import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_STATISTICS = 8;
const SCREEN_SIMULT = 9;
const SCREEN_POLYNOMIAL = 10;
const STATS_RESULT = 0x8d20;
const SIM_STATUS = 0x8d08;
const SIM_RESULT = 0x8ec0;
const POLY_ROOTS = 0x9040;

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function enterValues(harness, values) {
  for (const value of values) {
    for (const character of String(value)) harness.tap(character === "-" ? "(-)" : character);
    harness.tap("ENTER");
  }
}

function assertClose(actual, expected, tolerance = 1e-10) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

function rootValues(harness, degree) {
  return Array.from({ length: degree }, (_, index) => [
    harness.packedNumber(POLY_ROOTS + index * 18),
    harness.packedNumber(POLY_ROOTS + index * 18 + 9)
  ]);
}

test("[statistics.editors] physical and home-menu statistics and specialist solvers open real editors", () => {
  for (const [keys, screen, golden] of [
    [["STAT"], SCREEN_STATISTICS, "phase8-statistics-editor"],
    [["2ND", "STAT"], SCREEN_SIMULT, "phase8-simultaneous-editor"],
    [["2ND", "PRGM"], SCREEN_POLYNOMIAL, "phase8-polynomial-editor"]
  ]) {
    const harness = Free85Harness.boot();
    tapAll(harness, keys);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), screen);
    assertLcdGolden(golden, harness.machine.renderLcdBitmap());
  }

  const menu = Free85Harness.boot();
  tapAll(menu, ["MORE", "F4"]);
  assert.equal(menu.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_STATISTICS);
});

test("[statistics.one-variable] independent summary data distinguishes sample and population formulas", () => {
  const harness = Free85Harness.boot();
  harness.tap("STAT");
  tapAll(harness, ["+", "+", "+", "+"]);
  enterValues(harness, [2, 4, 4, 4, 5, 5, 7, 9]);
  harness.tap("F1");
  harness.runFrames(400);

  assertClose(harness.packedNumber(STATS_RESULT + 0 * 9), 5);
  assertClose(harness.packedNumber(STATS_RESULT + 1 * 9), 4.5);
  assertClose(harness.packedNumber(STATS_RESULT + 2 * 9), 32 / 7);
  assertClose(harness.packedNumber(STATS_RESULT + 3 * 9), Math.sqrt(32 / 7));
  assertClose(harness.packedNumber(STATS_RESULT + 4 * 9), 2);
  assertClose(harness.packedNumber(STATS_RESULT + 5 * 9), 2);
  assertClose(harness.packedNumber(STATS_RESULT + 6 * 9), 9);
  assertClose(harness.packedNumber(STATS_RESULT + 7 * 9), 4);
  assertClose(harness.packedNumber(STATS_RESULT + 8 * 9), 6);
  assertClose(harness.packedNumber(STATS_RESULT + 13 * 9), 4);
});

test("[statistics.two-variable] linear regression and correlation match an independent reference data set", () => {
  const harness = Free85Harness.boot();
  harness.tap("STAT");
  harness.tap("+");
  enterValues(harness, [1, 2, 3, 4, 5]);
  harness.tap("ALPHA");
  enterValues(harness, [2, 4, 5, 4, 5]);
  harness.tap("F3");
  harness.runFrames(600);

  assertClose(harness.packedNumber(STATS_RESULT + 0 * 9), 3);
  assertClose(harness.packedNumber(STATS_RESULT + 9 * 9), 4);
  assertClose(harness.packedNumber(STATS_RESULT + 10 * 9), 0.6);
  assertClose(harness.packedNumber(STATS_RESULT + 11 * 9), 2.2);
  assertClose(harness.packedNumber(STATS_RESULT + 12 * 9), 6 / Math.sqrt(60));
});

test("[statistics.plots] scatter, histogram, and box plots render calculator LCD output", () => {
  const makeData = () => {
    const harness = Free85Harness.boot();
    harness.tap("STAT");
    enterValues(harness, [1, 2, 3, 4]);
    harness.tap("ALPHA");
    enterValues(harness, [2, 4, 3, 8]);
    return harness;
  };

  const scatter = makeData();
  scatter.tap("F4");
  scatter.runFrames(500);
  assertLcdGolden("phase8-scatter-plot", scatter.machine.renderLcdBitmap());

  const histogram = makeData();
  histogram.tap("F5");
  histogram.runFrames(500);
  assertLcdGolden("phase8-histogram-plot", histogram.machine.renderLcdBitmap());

  const box = makeData();
  tapAll(box, ["MORE", "MORE", "F5"]);
  box.runFrames(500);
  assertLcdGolden("phase8-box-plot", box.machine.renderLcdBitmap());
});

test("[solver.simultaneous] 2x2 and 3x3 systems return unique packed-decimal solutions", () => {
  const two = Free85Harness.boot();
  tapAll(two, ["2ND", "STAT"]);
  enterValues(two, [2, 1, 5, 1, -1, 1]);
  two.tap("F1");
  two.runFrames(800);
  assert.equal(two.machine.read8(SIM_STATUS), 1);
  assertClose(two.packedNumber(SIM_RESULT), 2);
  assertClose(two.packedNumber(SIM_RESULT + 9), 1);

  const three = Free85Harness.boot();
  tapAll(three, ["2ND", "STAT", "F3"]);
  enterValues(three, [2, 1, -1, 8, -3, -1, 2, -11, -2, 1, 2, -3]);
  three.tap("F1");
  three.runFrames(1500);
  assert.equal(three.machine.read8(SIM_STATUS), 1);
  [2, 3, -1].forEach((expected, index) => assertClose(three.packedNumber(SIM_RESULT + index * 9), expected));
});

test("[solver.simultaneous-status] inconsistent and dependent systems have distinct recoverable states", () => {
  const solve = (values) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "STAT"]);
    enterValues(harness, values);
    harness.tap("F1");
    harness.runFrames(800);
    return harness.machine.read8(SIM_STATUS);
  };
  assert.equal(solve([1, 1, 1, 1, 1, 2]), 2);
  assert.equal(solve([1, 1, 2, 2, 2, 4]), 3);
});

test("[solver.polynomial] degree 2-4 solvers retain real and complex roots", () => {
  const solve = (degree, coefficients) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "PRGM"]);
    if (degree === 3) harness.tap("F3");
    if (degree === 4) harness.tap("F4");
    enterValues(harness, coefficients);
    harness.tap("F1");
    harness.runFrames(30_000);
    return rootValues(harness, degree);
  };

  const quadratic = solve(2, [1, 0, 1]);
  assert.deepEqual(quadratic.map(([real]) => Math.abs(real) < 1e-10), [true, true]);
  assert.deepEqual(quadratic.map(([, imaginary]) => Math.round(imaginary)).sort(), [-1, 1]);

  const cubic = solve(3, [1, -6, 11, -6]);
  const cubicReal = cubic.map(([real]) => real).sort((left, right) => left - right);
  [1, 2, 3].forEach((expected, index) => assertClose(cubicReal[index], expected, 1e-8));
  cubic.forEach(([, imaginary]) => assertClose(imaginary, 0, 1e-8));

  const quartic = solve(4, [1, 0, 0, 0, 1]);
  quartic.forEach(([real, imaginary]) => {
    assertClose(Math.hypot(real, imaginary), 1, 1e-8);
    assertClose((real ** 4) - (6 * real * real * imaginary * imaginary) + (imaginary ** 4), -1, 1e-8);
    assertClose(4 * real * imaginary * ((real * real) - (imaginary * imaginary)), 0, 1e-8);
  });
});

test("[solver.polynomial] quadratics with opposite-sign real roots converge", () => {
  const solve = (coefficients) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "PRGM"]);
    enterValues(harness, coefficients);
    harness.tap("F1");
    harness.runFrames(30_000);
    return rootValues(harness, 2);
  };

  const assertRealRoots = (roots, expected) => {
    const reals = roots.map(([real]) => real).sort((left, right) => left - right);
    expected.forEach((value, index) => assertClose(reals[index], value, 1e-8));
    roots.forEach(([, imaginary]) => assertClose(imaginary, 0, 1e-8));
  };

  assertRealRoots(solve([1, -1, -6]), [-2, 3]);
  assertRealRoots(solve([1, 0, -4]), [-2, 2]);
  assertRealRoots(solve([1, -6, 8]), [2, 4]);
});

test("[solver.polynomial] non-monic leading coefficients are normalised", () => {
  const solve = (degree, coefficients) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "PRGM"]);
    if (degree === 3) harness.tap("F3");
    enterValues(harness, coefficients);
    harness.tap("F1");
    harness.runFrames(30_000);
    return rootValues(harness, degree);
  };

  const negativeQuadratic = solve(2, [-1, 0, 4]);
  const reals = negativeQuadratic.map(([real]) => real).sort((left, right) => left - right);
  [-2, 2].forEach((value, index) => assertClose(reals[index], value, 1e-8));
  negativeQuadratic.forEach(([, imaginary]) => assertClose(imaginary, 0, 1e-8));

  const scaledCubic = solve(3, [2, -12, 22, -12]);
  const cubicReals = scaledCubic.map(([real]) => real).sort((left, right) => left - right);
  [1, 2, 3].forEach((value, index) => assertClose(cubicReals[index], value, 1e-8));
  scaledCubic.forEach(([, imaginary]) => assertClose(imaginary, 0, 1e-8));
});

test("[solver.polynomial] solver output stays clean packed decimal", () => {
  // Before the seed and normalisation fixes, -x^2 + 1 sent the iteration
  // through huge magnitudes and a denormalised root once rendered as
  // ";.0974990147". The input converges now, but whatever the solver
  // stores must remain valid normalised BCD and render as digits, never
  // as punctuation.
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "PRGM"]);
  enterValues(harness, [-1, 0, 1]);
  harness.tap("F1");
  harness.runFrames(30_000);

  for (let component = 0; component < 4; component += 1) {
    const base = POLY_ROOTS + component * 9;
    const digits = [];
    for (let index = 0; index < 7; index += 1) {
      const byte = harness.machine.read8(base + 2 + index);
      digits.push(byte >>> 4, byte & 0x0f);
    }
    assert.ok(digits.every((digit) => digit <= 9), `component ${component}: non-BCD ${digits}`);
    if (digits.some((digit) => digit !== 0)) {
      assert.notEqual(digits[0], 0, `component ${component}: denormalised ${digits}`);
    }
  }

  const length = harness.machine.read8(0x8059);
  const text = String.fromCharCode(...Array.from(
    { length },
    (_, index) => harness.machine.read8(0x8060 + index)
  ));
  assert.match(text, /^-?[0-9.E-]*$/, `rendered root contains punctuation: ${JSON.stringify(text)}`);
});
