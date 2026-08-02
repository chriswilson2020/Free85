import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_EDITOR_BUFFER_ADDRESS, FREE85_EDITOR_CURSOR_ADDRESS, FREE85_EDITOR_LENGTH_ADDRESS, FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_DIALOG = 1;
const SCREEN_GRAPH = 2;
const SCREEN_STATISTICS = 8;
const SCREEN_SOLVER = 10;
const LIST_X = 0x8780;
const LIST_Y = 0x8800;
const STATS_RESULT_KIND = 0x8d05;
const SOLVER_VARIABLE = 0x91d2;
const SOLVER_STATUS = 0x91d4;
const SOLVER_LOWER = 0x91e9;
const SOLVER_UPPER = 0x91f2;
const SOLVER_RESULT = 0x91fb;
const SOLVER_RESIDUAL = 0x9204;
const REGRESSION_COEFFICIENTS = 0x9220;
const FORECAST_X = 0x924d;
const FORECAST_Y = 0x9256;

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function writePacked(harness, address, value) {
  if (value === 0) {
    for (let index = 0; index < 9; index += 1) harness.machine.write8(address + index, 0);
    return;
  }
  const sign = value < 0 ? 0x80 : 0;
  const [mantissa, exponentText] = Math.abs(value).toExponential(13).split("e");
  const digits = mantissa.replace(".", "");
  harness.machine.write8(address, sign);
  harness.machine.write8(address + 1, Number(exponentText) & 0xff);
  for (let index = 0; index < 7; index += 1) {
    harness.machine.write8(address + 2 + index, Number.parseInt(digits.slice(index * 2, index * 2 + 2), 16));
  }
}

function setData(harness, xs, ys) {
  harness.machine.write8(LIST_X, xs.length);
  harness.machine.write8(LIST_Y, ys.length);
  xs.forEach((value, index) => writePacked(harness, LIST_X + 1 + index * 9, value));
  ys.forEach((value, index) => writePacked(harness, LIST_Y + 1 + index * 9, value));
}

function setHomeExpression(harness, expression) {
  harness.machine.write8(FREE85_EDITOR_LENGTH_ADDRESS, expression.length);
  harness.machine.write8(FREE85_EDITOR_CURSOR_ADDRESS, expression.length);
  [...expression].forEach((character, index) => harness.machine.write8(FREE85_EDITOR_BUFFER_ADDRESS + index, character.charCodeAt(0)));
}

function assertClose(actual, expected, tolerance = 1e-9) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

function coefficients(harness) {
  return Array.from({ length: 5 }, (_, index) => harness.packedNumber(REGRESSION_COEFFICIENTS + index * 9));
}

function runRegression(xs, ys, pages, key, frames = 10_000) {
  const harness = Free85Harness.boot();
  harness.tap("STAT");
  setData(harness, xs, ys);
  for (let index = 0; index < pages; index += 1) harness.tap("MORE");
  harness.tap(key);
  harness.runFrames(frames);
  return harness;
}

test("[solver.phase19.workspace] equation, variable, estimate, bounds, result, and residual persist", () => {
  const harness = Free85Harness.boot();
  setHomeExpression(harness, "A^2-9");
  tapAll(harness, ["2ND", "GRAPH"]);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_SOLVER);
  const golden = Free85Harness.boot();
  tapAll(golden, ["2ND", "GRAPH"]);
  assertLcdGolden("phase19-solver-workspace", golden.machine.renderLcdBitmap());

  tapAll(harness, ["F3", "F3", "F3"]); // X -> Y -> Z -> A
  assert.equal(harness.machine.read8(SOLVER_VARIABLE), "A".charCodeAt(0));
  harness.tap("F1");
  harness.runFrames(6000);
  assert.equal(harness.machine.read8(SOLVER_STATUS), 1);
  assertClose(harness.packedNumber(SOLVER_RESULT), -3, 1e-6);
  assertClose(harness.packedNumber(SOLVER_RESIDUAL), 0, 1e-6);
});

test("[solver.phase19.bounds] editable estimate and bounds select a bounded root", () => {
  const harness = Free85Harness.boot();
  setHomeExpression(harness, "X^2-4");
  tapAll(harness, ["2ND", "GRAPH", "F5", "F5"]); // GUESS
  tapAll(harness, ["(-)", "3", "ENTER", "(-)", "5", "ENTER", "0", "ENTER"]);
  assertClose(harness.packedNumber(SOLVER_LOWER), -5);
  assertClose(harness.packedNumber(SOLVER_UPPER), 0);
  harness.tap("F1");
  harness.runFrames(6000);
  assert.equal(harness.machine.read8(SOLVER_STATUS), 1);
  assertClose(harness.packedNumber(SOLVER_RESULT), -2, 1e-6);
  assertClose(harness.packedNumber(SOLVER_RESIDUAL), 0, 1e-6);

  // Bounds that exclude the root the default -10..10 window would find
  // first: only a committed LOWER makes the solver land on +2.
  const bounded = Free85Harness.boot();
  setHomeExpression(bounded, "X^2-4");
  tapAll(bounded, ["2ND", "GRAPH", "F5", "F5", "F5"]); // LOWER
  tapAll(bounded, ["1", "ENTER", "5", "ENTER"]);
  assertClose(bounded.packedNumber(SOLVER_LOWER), 1);
  assertClose(bounded.packedNumber(SOLVER_UPPER), 5);
  bounded.tap("F1");
  bounded.runFrames(6000);
  assert.equal(bounded.machine.read8(SOLVER_STATUS), 1);
  assertClose(bounded.packedNumber(SOLVER_RESULT), 2, 1e-6);
  assertClose(bounded.packedNumber(SOLVER_RESIDUAL), 0, 1e-6);
});

test("[solver.phase19.graph] selected solver variables hand off as graph X", () => {
  const harness = Free85Harness.boot();
  setHomeExpression(harness, "TAN(A)-1");
  tapAll(harness, ["2ND", "GRAPH", "F3", "F3", "F3", "F2"]);
  harness.runFrames(100);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_GRAPH);
  const length = harness.machine.read8(0x8510);
  const equation = String.fromCharCode(...Array.from({ length }, (_, index) => harness.machine.read8(0x8511 + index)));
  assert.equal(equation, "TAN(X)-1");
});

test("[statistics.phase19.models] logarithmic, exponential, and power coefficients match references", () => {
  const logarithmic = runRegression([1, 2, 4, 8], [1, 3, 5, 7], 3, "F1");
  assertClose(coefficients(logarithmic)[0], 1);
  assertClose(coefficients(logarithmic)[1], 2 / Math.log(2));

  const xs = [0, 1, 2, 3];
  const exponential = runRegression(xs, xs.map((x) => 2 * Math.exp(0.5 * x)), 3, "F2");
  assertClose(coefficients(exponential)[0], 2);
  assertClose(coefficients(exponential)[1], 0.5);

  const power = runRegression([1, 2, 3, 4], [3, 12, 27, 48], 3, "F3");
  assertClose(coefficients(power)[0], 3);
  assertClose(coefficients(power)[1], 2);
});

test("[statistics.phase19.polynomial] degree 2-4 least-squares coefficients match independent polynomials", () => {
  for (const degree of [2, 3, 4]) {
    const xs = Array.from({ length: degree + 2 }, (_, index) => index - 1);
    const expected = [1, 2, 3, 4, 5].slice(0, degree + 1);
    const ys = xs.map((x) => expected.reduce((sum, coefficient, exponent) => sum + coefficient * (x ** exponent), 0));
    const harness = runRegression(xs, ys, degree === 4 ? 4 : 3, degree === 2 ? "F4" : degree === 3 ? "F5" : "F1", 15_000);
    coefficients(harness).slice(0, degree + 1).forEach((actual, index) => assertClose(actual, expected[index], 2e-8));
  }
});

test("[statistics.phase19.forecast] forward and inverse forecasts satisfy fitted models", () => {
  const power = runRegression([1, 2, 3, 4], [3, 12, 27, 48], 3, "F3");
  power.tap("MORE");
  power.tap("F3");
  power.runFrames(1000);
  assertClose(power.packedNumber(FORECAST_X), 1);
  assertClose(power.packedNumber(FORECAST_Y), 3);
  power.tap("CLEAR");
  power.tap("F2");
  power.runFrames(1000);
  assertClose(power.packedNumber(FORECAST_X), 1);

  const polynomial = runRegression([0, 1, 2, 3, 4], [1, 6, 17, 34, 57], 3, "F4");
  polynomial.tap("MORE");
  polynomial.tap("F2");
  polynomial.runFrames(5000);
  assertClose(polynomial.packedNumber(FORECAST_X), 0, 1e-7);
  assertClose(polynomial.packedNumber(FORECAST_Y), 1);
});

test("[statistics.phase19.commands] paired Sortx/Sorty and ShwSt retain associated values and results", () => {
  const runSort = (key, xs, ys) => {
    const harness = Free85Harness.boot();
    harness.tap("STAT");
    setData(harness, xs, ys);
    tapAll(harness, ["MORE", "MORE", "MORE", "MORE", key]);
    harness.runFrames(500);
    return [
      Array.from({ length: xs.length }, (_, index) => harness.packedNumber(LIST_X + 1 + index * 9)),
      Array.from({ length: ys.length }, (_, index) => harness.packedNumber(LIST_Y + 1 + index * 9))
    ];
  };
  assert.deepEqual(runSort("F4", [3, 1, 2], [30, 10, 20]), [[1, 2, 3], [10, 20, 30]]);
  assert.deepEqual(runSort("F5", [3, 1, 2], [20, 30, 10]), [[2, 3, 1], [10, 20, 30]]);

  const show = Free85Harness.boot();
  show.tap("STAT");
  setData(show, [1, 2, 3], [2, 4, 6]);
  show.tap("F1");
  show.tap("CLEAR");
  tapAll(show, ["MORE", "MORE", "MORE", "MORE", "MORE", "F1"]);
  assert.equal(show.machine.read8(STATS_RESULT_KIND), 1);
});

test("[statistics.phase19.xyline] connected paired points have an exact LCD golden", () => {
  const harness = Free85Harness.boot();
  harness.tap("STAT");
  setData(harness, [1, 2, 3, 4], [2, 4, 3, 8]);
  tapAll(harness, ["MORE", "MORE", "MORE", "MORE", "MORE", "F2"]);
  harness.runFrames(500);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_STATISTICS);
  assertLcdGolden("phase19-xyline-plot", harness.machine.renderLcdBitmap());
});

test("[statistics.phase19.errors] invalid transformed and undersampled models recover visibly", () => {
  const logarithmic = Free85Harness.boot();
  logarithmic.tap("STAT");
  setData(logarithmic, [-1, 1, 2], [1, 2, 3]);
  tapAll(logarithmic, ["MORE", "MORE", "MORE", "F1"]);
  assert.equal(logarithmic.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_DIALOG);

  const quartic = Free85Harness.boot();
  quartic.tap("STAT");
  setData(quartic, [0, 1, 2, 3], [1, 2, 3, 4]);
  tapAll(quartic, ["MORE", "MORE", "MORE", "MORE", "F1"]);
  assert.equal(quartic.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_DIALOG);
});
