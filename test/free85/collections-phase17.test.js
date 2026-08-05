import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_HOME = 0;
const SCREEN_DIALOG = 1;
const SCREEN_LIST = 5;
const SCREEN_VECTOR = 7;
const LIST_RESULT = 0x8880;
const MATRIX_RESULT = 0xf428;
const VECTOR_RESULT = 0x8b80;
const P7_ERROR = 0x8705;

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}
function enterValues(harness, input) {
  for (const value of input) {
    for (const character of String(value)) harness.tap(character === "-" ? "(-)" : character);
    harness.tap("ENTER");
  }
}
function values(harness, base, count, header = 0) {
  return Array.from({ length: count }, (_, index) => harness.packedNumber(base + header + index * 9));
}
function assertClose(actual, expected, tolerance = 1e-9) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}
function listHarness(input = [4, 1, 3, 2]) {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "-"]);
  enterValues(harness, input);
  tapAll(harness, ["MORE", "MORE", "MORE"]);
  return harness;
}
function matrixHarness(input = [1, 2, 3, 4], page = 2) {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "7"]);
  enterValues(harness, input);
  for (let index = 0; index < page; index += 1) harness.tap("MORE");
  return harness;
}

test("[collections.phase17.menus] every added collection menu has an exact LCD golden", () => {
  for (const [name, keys, pages] of [
    ["phase17-list-menu", ["2ND", "-"], 3],
    ["phase17-matrix-row-menu", ["2ND", "7"], 2],
    ["phase17-matrix-decomposition-menu", ["2ND", "7"], 4],
    ["phase17-vector-menu", ["2ND", "8"], 3]
  ]) {
    const harness = Free85Harness.boot();
    tapAll(harness, keys);
    for (let index = 0; index < pages; index += 1) harness.tap("MORE");
    assertLcdGolden(name, harness.machine.renderLcdBitmap());
  }
});

test("[collections.phase17.list] dimensions, fill, descending sort, and vector conversion preserve packed values", () => {
  const dimension = listHarness();
  dimension.tap("F1");
  assert.equal(dimension.machine.read8(LIST_RESULT), 1);
  assertClose(dimension.packedNumber(LIST_RESULT + 1), 4);

  const fill = listHarness();
  fill.tap("ALPHA");
  enterValues(fill, [9]);
  fill.tap("F2");
  assert.deepEqual(values(fill, LIST_RESULT, 4, 1), [9, 9, 9, 9]);

  const descending = listHarness();
  descending.tap("F3");
  assert.deepEqual(values(descending, LIST_RESULT, 4, 1), [4, 3, 2, 1]);

  const convert = Free85Harness.boot();
  tapAll(convert, ["2ND", "-", "-"]);
  enterValues(convert, [7, 8, 9]);
  tapAll(convert, ["MORE", "MORE", "MORE", "F4"]);
  assert.equal(convert.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_VECTOR);
  assert.deepEqual(values(convert, VECTOR_RESULT, 3, 1), [7, 8, 9]);

  const reverse = Free85Harness.boot();
  tapAll(reverse, ["2ND", "8"]);
  enterValues(reverse, [7, 8, 9]);
  tapAll(reverse, ["MORE", "MORE", "MORE", "F4"]);
  assert.equal(reverse.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_LIST);
  assert.deepEqual(values(reverse, LIST_RESULT, 3, 1), [7, 8, 9]);
});

test("[collections.phase17.matrix.rows] REF, row operations, and augmentation are deterministic", () => {
  const ref = matrixHarness();
  ref.tap("F1");
  ref.runFrames(500);
  assert.deepEqual(values(ref, MATRIX_RESULT, 4, 2).map((value) => Math.round(value * 1e10) / 1e10), [1, 0, 0, 1]);

  const swap = matrixHarness();
  swap.tap("F2");
  assert.deepEqual(values(swap, MATRIX_RESULT, 4, 2), [3, 4, 1, 2]);

  const multiply = matrixHarness();
  multiply.tap("ALPHA");
  enterValues(multiply, [2]);
  multiply.tap("F4");
  assert.deepEqual(values(multiply, MATRIX_RESULT, 4, 2), [2, 4, 3, 4]);

  const add = matrixHarness();
  add.tap("ALPHA");
  enterValues(add, [2]);
  add.tap("F3");
  assert.deepEqual(values(add, MATRIX_RESULT, 4, 2), [7, 10, 3, 4]);

  const augment = Free85Harness.boot();
  tapAll(augment, ["2ND", "7"]);
  enterValues(augment, [1, 2, 3, 4]);
  tapAll(augment, ["ALPHA", "X-VAR", "-"]);
  enterValues(augment, [5, 6]);
  tapAll(augment, ["MORE", "MORE", "F5"]);
  assert.equal(augment.machine.read8(MATRIX_RESULT), 2);
  assert.equal(augment.machine.read8(MATRIX_RESULT + 1), 3);
  assert.deepEqual(values(augment, MATRIX_RESULT, 6, 2), [1, 2, 5, 3, 4, 6]);
});

test("[collections.phase17.vector] dimension, fill, norm, and list conversion retain vector semantics", () => {
  const vector = (key) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "8"]);
    enterValues(harness, [3, 4, 0]);
    tapAll(harness, ["MORE", "MORE", "MORE", key]);
    harness.runFrames(300);
    return harness;
  };
  const dimension = vector("F1");
  assert.equal(dimension.machine.read8(VECTOR_RESULT), 1);
  assertClose(dimension.packedNumber(VECTOR_RESULT + 1), 3);
  assertClose(vector("F3").packedNumber(VECTOR_RESULT + 1), 5);
  const asList = vector("F4");
  assert.equal(asList.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_LIST);
  assert.deepEqual(values(asList, LIST_RESULT, 3, 1), [3, 4, 0]);

  const fill = Free85Harness.boot();
  tapAll(fill, ["2ND", "8"]);
  enterValues(fill, [1, 2, 3]);
  fill.tap("ALPHA");
  enterValues(fill, [6]);
  tapAll(fill, ["MORE", "MORE", "MORE", "F2"]);
  assert.deepEqual(values(fill, VECTOR_RESULT, 3, 1), [6, 6, 6]);
});

test("[collections.phase17.matrix.norms] Frobenius, row, column, and condition norms are validated", () => {
  const operation = (key, frames = 800) => {
    const harness = matrixHarness([1, 2, 3, 4], 3);
    harness.tap(key);
    harness.runFrames(frames);
    return harness.packedNumber(MATRIX_RESULT + 2);
  };
  assertClose(operation("F1"), Math.sqrt(30));
  assertClose(operation("F2"), 7);
  assertClose(operation("F3"), 6);
  assertClose(operation("F4", 1800), 15, 1e-8);

  const random = matrixHarness([1, 2, 3, 4], 3);
  random.tap("F5");
  const cells = values(random, MATRIX_RESULT, 4, 2);
  for (const value of cells) assert.ok(value > 0 && value < 1, `cell ${value} outside (0,1)`);
  assert.equal(new Set(cells).size, 4, `cells not distinct: ${cells}`);
});

test("[collections.phase17.matrix.cond-singular] COND on a singular matrix raises the singular notice", () => {
  const harness = matrixHarness([1, 2, 2, 4], 3);
  harness.tap("F4");
  harness.runFrames(1800);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_DIALOG);
  assert.equal(harness.machine.read8(P7_ERROR), 2); // SINGULAR MATRIX
  harness.tap("EXIT");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_HOME);
});

test("[collections.phase17.matrix.decomposition] LU reconstructs A and eigensystems satisfy residuals", () => {
  const lu = matrixHarness([4, 3, 6, 3], 4);
  lu.tap("F1");
  lu.runFrames(900);
  const combined = values(lu, MATRIX_RESULT, 4, 2);
  [4, 3, 1.5, -1.5].forEach((expected, index) => assertClose(combined[index], expected));
  assertClose(combined[0] * combined[2], 6);
  assertClose(combined[2] * combined[1] + combined[3], 3);

  const eigenvalues = matrixHarness([2, 1, 1, 2], 4);
  eigenvalues.tap("F2");
  eigenvalues.runFrames(900);
  const lambda = values(eigenvalues, MATRIX_RESULT, 2, 2);
  assertClose(lambda[0], 3);
  assertClose(lambda[1], 1);

  const eigenvectors = matrixHarness([2, 1, 1, 2], 4);
  eigenvectors.tap("F3");
  eigenvectors.runFrames(1400);
  const vector = values(eigenvectors, MATRIX_RESULT, 4, 2);
  for (let column = 0; column < 2; column += 1) {
    const x = vector[column];
    const y = vector[2 + column];
    assertClose(Math.hypot(x, y), 1);
    assertClose(2 * x + y, lambda[column] * x);
    assertClose(x + 2 * y, lambda[column] * y);
  }
});
