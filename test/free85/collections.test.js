import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_DIALOG = 1;
const SCREEN_COMPLEX = 4;
const SCREEN_LIST = 5;
const SCREEN_MATRIX = 6;
const SCREEN_VECTOR = 7;

const COMPLEX_RESULT = 0x8744;
const LIST_RESULT = 0x8880;
const MATRIX_RESULT = 0x8a00;
const VECTOR_A = 0x8b00;
const VECTOR_RESULT = 0x8b80;
const P7_ERROR = 0x8705;

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function enterValues(harness, values) {
  for (const value of values) {
    for (const character of String(value)) harness.tap(character === "-" ? "(-)" : character);
    harness.tap("ENTER");
  }
}

function values(harness, base, count, header = 0) {
  return Array.from({ length: count }, (_, index) => harness.packedNumber(base + header + index * 9));
}

function assertClose(actual, expected, tolerance = 1e-11) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

test("[collections.editors] every Phase 7 physical and home-menu entry opens a working editor", () => {
  for (const [keys, expected, golden] of [
    [["2ND", "9"], SCREEN_COMPLEX, "phase7-complex-editor"],
    [["2ND", "-"], SCREEN_LIST, "phase7-list-editor"],
    [["2ND", "7"], SCREEN_MATRIX, "phase7-matrix-editor"],
    [["2ND", "8"], SCREEN_VECTOR, "phase7-vector-editor"]
  ]) {
    const harness = Free85Harness.boot();
    tapAll(harness, keys);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), expected);
    assertLcdGolden(golden, harness.machine.renderLcdBitmap());
    harness.tap("5");
    harness.tap("ENTER");
    assert.equal(harness.packedNumber(expected === SCREEN_COMPLEX ? 0x8720
      : expected === SCREEN_LIST ? 0x8781
        : expected === SCREEN_MATRIX ? 0x8902 : 0x8b01), 5);
  }

  for (const [key, expected] of [["F1", SCREEN_LIST], ["F2", SCREEN_MATRIX], ["F3", SCREEN_VECTOR]]) {
    const menu = Free85Harness.boot();
    menu.tap("MORE");
    menu.tap(key);
    assert.equal(menu.machine.read8(FREE85_UI_MODE_ADDRESS), expected);
  }
});

test("[complex.operations] rectangular, polar, arithmetic, powers, roots, and conjugates use packed decimal values", () => {
  const magnitude = Free85Harness.boot();
  tapAll(magnitude, ["2ND", "9"]);
  enterValues(magnitude, [3, 4]);
  magnitude.tap("F3");
  magnitude.runFrames(40);
  assertClose(magnitude.packedNumber(COMPLEX_RESULT), 5);

  const arithmetic = Free85Harness.boot();
  tapAll(arithmetic, ["2ND", "9"]);
  enterValues(arithmetic, [3, 4]);
  arithmetic.tap("ALPHA");
  enterValues(arithmetic, [1, 2]);
  arithmetic.tap("MORE");
  arithmetic.tap("F3");
  arithmetic.runFrames(40);
  assert.deepEqual(values(arithmetic, COMPLEX_RESULT, 2), [-5, 10]);

  const root = Free85Harness.boot();
  tapAll(root, ["2ND", "9"]);
  enterValues(root, [-9, 0]);
  tapAll(root, ["MORE", "MORE", "F3"]);
  root.runFrames(80);
  assertClose(root.packedNumber(COMPLEX_RESULT), 0);
  assertClose(root.packedNumber(COMPLEX_RESULT + 9), 3);

  const conjugate = Free85Harness.boot();
  tapAll(conjugate, ["2ND", "9"]);
  enterValues(conjugate, [3, 4]);
  conjugate.tap("F5");
  assert.deepEqual(values(conjugate, COMPLEX_RESULT, 2), [3, -4]);

  const polar = Free85Harness.boot();
  tapAll(polar, ["2ND", "9"]);
  enterValues(polar, [3, 4]);
  tapAll(polar, ["MORE", "MORE", "F2"]);
  polar.runFrames(180);
  assertClose(polar.packedNumber(COMPLEX_RESULT), 5);
  assertClose(polar.packedNumber(COMPLEX_RESULT + 9), Math.atan2(4, 3), 1e-9);

  const rectangular = Free85Harness.boot();
  tapAll(rectangular, ["2ND", "9"]);
  enterValues(rectangular, [2, Math.PI / 2]);
  tapAll(rectangular, ["MORE", "MORE", "F1"]);
  rectangular.runFrames(180);
  assertClose(rectangular.packedNumber(COMPLEX_RESULT), 0, 1e-9);
  assertClose(rectangular.packedNumber(COMPLEX_RESULT + 9), 2, 1e-9);
});

test("[list.operations] bounded lists aggregate, sort, accumulate, sequence, and report population deviation", () => {
  const run = (menuKey, secondPage = false, frames = 80) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "-"]);
    enterValues(harness, [4, 1, 3, 2]);
    if (secondPage) harness.tap("MORE");
    harness.tap(menuKey);
    harness.runFrames(frames);
    return harness;
  };

  assertClose(run("F1").packedNumber(LIST_RESULT + 1), 10);
  assertClose(run("F2").packedNumber(LIST_RESULT + 1), 2.5);
  assert.deepEqual(values(run("F3"), LIST_RESULT, 4, 1), [1, 2, 3, 4]);
  assert.deepEqual(values(run("F4"), LIST_RESULT, 4, 1), [4, 5, 8, 10]);
  assert.deepEqual(values(run("F5"), LIST_RESULT, 4, 1), [1, 2, 3, 4]);
  assertClose(run("F1", true).packedNumber(LIST_RESULT + 1), 24);
  assertClose(run("F2", true).packedNumber(LIST_RESULT + 1), 1);
  assertClose(run("F3", true).packedNumber(LIST_RESULT + 1), 4);
  assertClose(run("F4", true).packedNumber(LIST_RESULT + 1), 2.5);
  assertClose(run("F5", true, 150).packedNumber(LIST_RESULT + 1), Math.sqrt(1.25));

  const elementWise = Free85Harness.boot();
  tapAll(elementWise, ["2ND", "-"]);
  enterValues(elementWise, [1, 2, 3, 4]);
  elementWise.tap("ALPHA");
  enterValues(elementWise, [5, 6, 7, 8]);
  tapAll(elementWise, ["MORE", "MORE", "F1"]);
  assert.deepEqual(values(elementWise, LIST_RESULT, 4, 1), [6, 8, 10, 12]);
});

test("[matrix.operations] matrices support determinant, transpose, multiplication, inverse, RREF, and solve", () => {
  const matrix = (keys, frames = 100) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "7"]);
    enterValues(harness, [1, 2, 3, 4]);
    tapAll(harness, keys);
    harness.runFrames(frames);
    return harness;
  };
  assertClose(matrix(["F1"]).packedNumber(MATRIX_RESULT + 2), -2);
  assert.deepEqual(values(matrix(["F2"]), MATRIX_RESULT, 4, 2), [1, 3, 2, 4]);
  const inverse = values(matrix(["F3"], 500), MATRIX_RESULT, 4, 2);
  [-2, 1, 1.5, -0.5].forEach((expected, index) => assertClose(inverse[index], expected));
  assert.deepEqual(values(matrix(["F5"], 500), MATRIX_RESULT, 4, 2), [1, 0, 0, 1]);

  const multiply = Free85Harness.boot();
  tapAll(multiply, ["2ND", "7"]);
  enterValues(multiply, [1, 2, 3, 4]);
  multiply.tap("ALPHA");
  enterValues(multiply, [5, 6, 7, 8]);
  tapAll(multiply, ["MORE", "F3"]);
  multiply.runFrames(400);
  assert.deepEqual(values(multiply, MATRIX_RESULT, 4, 2), [19, 22, 43, 50]);

  const solve = Free85Harness.boot();
  tapAll(solve, ["2ND", "7"]);
  enterValues(solve, [2, 1, 1, -1]);
  solve.tap("ALPHA");
  enterValues(solve, [5, 0, 1, 0]);
  tapAll(solve, ["MORE", "F5"]);
  solve.runFrames(900);
  assert.equal(solve.machine.read8(MATRIX_RESULT), 2);
  assert.equal(solve.machine.read8(MATRIX_RESULT + 1), 1);
  assertClose(solve.packedNumber(MATRIX_RESULT + 2), 2);
  assertClose(solve.packedNumber(MATRIX_RESULT + 11), 1);
  assert.equal(solve.packedNumber(0x8982), 5, "solving must preserve matrix B");
});

test("[matrix.identity] ID fills R with a 2x2 identity and leaves the vector registers untouched", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "8"]);
  enterValues(harness, [7, 8, 9]);
  harness.tap("EXIT");
  tapAll(harness, ["2ND", "7", "F4"]);
  harness.runFrames(300);
  assert.equal(harness.machine.read8(MATRIX_RESULT), 2);
  assert.equal(harness.machine.read8(MATRIX_RESULT + 1), 2);
  assert.deepEqual(values(harness, MATRIX_RESULT, 4, 2), [1, 0, 0, 1]);
  assert.equal(harness.machine.read8(VECTOR_A), 3, "ID must not clobber vector A's length");
  assert.equal(harness.packedNumber(VECTOR_A + 1), 7, "ID must not clobber vector A's components");
});

test("[matrix.errors] singular and dimension errors are recoverable", () => {
  const singular = Free85Harness.boot();
  tapAll(singular, ["2ND", "7"]);
  enterValues(singular, [1, 2, 2, 4]);
  singular.tap("F3");
  singular.runFrames(200);
  assert.equal(singular.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_DIALOG);
  assert.equal(singular.machine.read8(P7_ERROR), 2);

  const dimension = Free85Harness.boot();
  tapAll(dimension, ["2ND", "7", "ALPHA", "+", "MORE", "F1"]);
  assert.equal(dimension.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_DIALOG);
  assert.equal(dimension.machine.read8(P7_ERROR), 1);
});

test("[vector.operations] 2D/3D vectors support arithmetic, norm, dot, cross, and angle", () => {
  const vector = (key, frames = 100) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "8"]);
    enterValues(harness, [3, 4, 0]);
    harness.tap("ALPHA");
    enterValues(harness, [1, 2, 3]);
    harness.tap(key);
    harness.runFrames(frames);
    return harness;
  };
  assertClose(vector("F1").packedNumber(VECTOR_RESULT + 1), 5);
  assertClose(vector("F3").packedNumber(VECTOR_RESULT + 1), 11);
  assert.deepEqual(values(vector("F4"), VECTOR_RESULT, 3, 1), [12, -9, 2]);
  assertClose(vector("F5", 180).packedNumber(VECTOR_RESULT + 1), Math.acos(11 / (5 * Math.sqrt(14))), 1e-9);

  const normal = vector("F2", 180);
  const components = values(normal, VECTOR_RESULT, 3, 1);
  assertClose(Math.hypot(...components), 1, 1e-10);
});

test("[coordinates.modes] vectors convert between rectangular, cylindrical, and spherical forms", () => {
  const convert = (valuesIn, key, frames = 500) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "8"]);
    enterValues(harness, valuesIn);
    tapAll(harness, ["MORE", "MORE", key]);
    harness.runFrames(frames);
    return harness;
  };
  const cylindrical = convert([3, 4, 5], "F1");
  assert.deepEqual(values(cylindrical, VECTOR_RESULT, 3, 1).map((value) => Math.round(value * 1e9) / 1e9),
    [5, Math.round(Math.atan2(4, 3) * 1e9) / 1e9, 5]);
  assert.equal(cylindrical.machine.read8(0x8707), 1);

  const rectangular = convert([2, Math.PI / 2, 7], "F2");
  const rect = values(rectangular, VECTOR_RESULT, 3, 1);
  assertClose(rect[0], 0, 1e-9);
  assertClose(rect[1], 2, 1e-9);
  assertClose(rect[2], 7);

  const spherical = convert([3, 4, 12], "F3", 700);
  const sph = values(spherical, VECTOR_RESULT, 3, 1);
  assertClose(sph[0], 13);
  assertClose(sph[1], Math.atan2(4, 3), 1e-9);
  assertClose(sph[2], Math.acos(12 / 13), 1e-9);

  const sphRect = convert([2, 0, Math.PI / 2], "F4", 700);
  const back = values(sphRect, VECTOR_RESULT, 3, 1);
  assertClose(back[0], 2, 1e-9);
  assertClose(back[1], 0, 1e-9);
  assertClose(back[2], 0, 1e-9);
});
