import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_DIALOG = 1;
const MATRIX_A = 0xf2e0;
const MATRIX_B = 0xf384;
const MATRIX_R = 0xf428;
const MATRIX_A_IMAG = 0xf570;
const MATRIX_B_IMAG = 0xf612;
const MATRIX_R_IMAG = 0xf6b4;

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

function writeMatrix(harness, base, rows, cols, values) {
  assert.equal(values.length, rows * cols);
  harness.machine.write8(base, rows);
  harness.machine.write8(base + 1, cols);
  values.forEach((value, index) => writeNumber(harness, base + 2 + index * 9, value));
}

function readMatrix(harness, base) {
  const rows = harness.machine.read8(base);
  const cols = harness.machine.read8(base + 1);
  return {
    rows,
    cols,
    values: Array.from({ length: rows * cols }, (_, index) => harness.packedNumber(base + 2 + index * 9))
  };
}

function readPlane(harness, base, count) {
  return Array.from({ length: count }, (_, index) => harness.packedNumber(base + index * 9));
}

function openMatrix(harness) {
  harness.tap("2ND");
  harness.tap("7");
}

test("[phase17.4.editor] matrix columns grow visibly and stop at six", () => {
  const harness = Free85Harness.boot();
  openMatrix(harness);
  harness.tap("X-VAR");
  for (let index = 0; index < 8; index += 1) harness.tap("+");
  assert.equal(harness.machine.read8(MATRIX_A), 2);
  assert.equal(harness.machine.read8(MATRIX_A + 1), 6);
  assertLcdGolden("phase17-matrix-3x6-editor", harness.machine.renderLcdBitmap());
});

test("[phase17.4.rows-rref] row operations and RREF consume all six columns", () => {
  const swap = Free85Harness.boot();
  writeMatrix(swap, MATRIX_A, 3, 6, Array.from({ length: 18 }, (_, index) => index + 1));
  openMatrix(swap);
  swap.tap("MORE");
  swap.tap("MORE");
  swap.tap("F2");
  assert.deepEqual(readMatrix(swap, MATRIX_R), {
    rows: 3,
    cols: 6,
    values: [7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 17, 18]
  });

  const rref = Free85Harness.boot();
  writeMatrix(rref, MATRIX_A, 3, 6, [1, 2, 0, 5, 7, 9, 0, 1, 0, 2, 3, 4, 0, 0, 1, 6, 8, 10]);
  openMatrix(rref);
  rref.tap("F5");
  rref.runFrames(1200);
  assert.deepEqual(readMatrix(rref, MATRIX_R), {
    rows: 3,
    cols: 6,
    values: [1, 0, 0, 1, 1, 1, 0, 1, 0, 2, 3, 4, 0, 0, 1, 6, 8, 10]
  });
});

test("[phase17.4.augment-multiply] rectangular results fill the complete 3x6 capacity", () => {
  const augment = Free85Harness.boot();
  writeMatrix(augment, MATRIX_A, 3, 3, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  writeMatrix(augment, MATRIX_B, 3, 3, [10, 11, 12, 13, 14, 15, 16, 17, 18]);
  openMatrix(augment);
  augment.tap("MORE");
  augment.tap("MORE");
  augment.tap("F5");
  assert.deepEqual(readMatrix(augment, MATRIX_R), {
    rows: 3,
    cols: 6,
    values: [1, 2, 3, 10, 11, 12, 4, 5, 6, 13, 14, 15, 7, 8, 9, 16, 17, 18]
  });

  const multiply = Free85Harness.boot();
  writeMatrix(multiply, MATRIX_A, 2, 3, [1, 0, 0, 0, 1, 0]);
  writeMatrix(multiply, MATRIX_B, 3, 6, Array.from({ length: 18 }, (_, index) => index + 1));
  openMatrix(multiply);
  multiply.tap("MORE");
  multiply.tap("F3");
  multiply.runFrames(1600);
  assert.deepEqual(readMatrix(multiply, MATRIX_R), {
    rows: 2,
    cols: 6,
    values: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  });
});

test("[phase17.4.complex-chain] 3x6 complex arithmetic and ENTER USE R preserve both planes", () => {
  const harness = Free85Harness.boot();
  const realA = Array.from({ length: 18 }, (_, index) => index + 1);
  const realB = Array.from({ length: 18 }, () => 10);
  const imagA = Array.from({ length: 18 }, (_, index) => index % 3);
  const imagB = Array.from({ length: 18 }, () => -1);
  writeMatrix(harness, MATRIX_A, 3, 6, realA);
  writeMatrix(harness, MATRIX_B, 3, 6, realB);
  imagA.forEach((value, index) => writeNumber(harness, MATRIX_A_IMAG + index * 9, value));
  imagB.forEach((value, index) => writeNumber(harness, MATRIX_B_IMAG + index * 9, value));
  openMatrix(harness);
  harness.tap("MORE");
  harness.tap("F1");
  assert.deepEqual(readMatrix(harness, MATRIX_R).values, realA.map((value) => value + 10));
  assert.deepEqual(readPlane(harness, MATRIX_R_IMAG, 18), imagA.map((value) => value - 1));
  harness.tap("ENTER");
  assert.deepEqual(readMatrix(harness, MATRIX_A), readMatrix(harness, MATRIX_R));
  assert.deepEqual(readPlane(harness, MATRIX_A_IMAG, 18), readPlane(harness, MATRIX_R_IMAG, 18));
});

test("[phase17.4.transpose-boundary] an unrepresentable 6x3 transpose fails without changing R", () => {
  const harness = Free85Harness.boot();
  writeMatrix(harness, MATRIX_A, 3, 6, Array.from({ length: 18 }, (_, index) => index + 1));
  writeMatrix(harness, MATRIX_R, 1, 1, [42]);
  openMatrix(harness);
  harness.tap("F2");
  assert.equal(harness.machine.read8(0x800b), SCREEN_DIALOG);
  assert.deepEqual(readMatrix(harness, MATRIX_R), { rows: 1, cols: 1, values: [42] });
});
