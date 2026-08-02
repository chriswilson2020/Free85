import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_COMPLEX = 4;
const LIST_A = 0x8780;
const LIST_B = 0x8800;
const LIST_RESULT = 0x8880;
const LIST_A_IMAG = 0xf800;
const LIST_B_IMAG = 0xf848;
const LIST_RESULT_IMAG = 0xf890;
const MATRIX_RESULT = 0x8a00;
const MATRIX_A_IMAG = 0xf8d8;
const MATRIX_B_IMAG = 0xf929;
const MATRIX_RESULT_IMAG = 0xf97a;
const VECTOR_RESULT = 0x8b80;
const VECTOR_A_IMAG = 0xfa1c;
const VECTOR_B_IMAG = 0xfa37;
const VECTOR_RESULT_IMAG = 0xfa52;

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function enterValues(harness, input) {
  for (const value of input) {
    for (const character of String(value)) harness.tap(character === "-" ? "(-)" : character);
    harness.tap("ENTER");
  }
}

function writePacked(harness, address, value) {
  if (value === 0) {
    for (let index = 0; index < 9; index += 1) harness.machine.write8(address + index, 0);
    return;
  }
  const sign = value < 0 ? 0x80 : 0;
  const exponential = Math.abs(value).toExponential(13);
  const [mantissa, exponentText] = exponential.split("e");
  const digits = mantissa.replace(".", "");
  harness.machine.write8(address, sign);
  harness.machine.write8(address + 1, Number(exponentText) & 0xff);
  for (let index = 0; index < 7; index += 1) {
    harness.machine.write8(address + 2 + index, Number.parseInt(digits.slice(index * 2, index * 2 + 2), 16));
  }
}

function setImaginaryPlane(harness, base, values) {
  values.forEach((value, index) => writePacked(harness, base + index * 9, value));
}

function packedValues(harness, base, count, header = 0) {
  return Array.from({ length: count }, (_, index) => harness.packedNumber(base + header + index * 9));
}

function assertClose(actual, expected, tolerance = 1e-10) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

test("[collections.phase18.storage] CSET/CGET round-trips a complex list element and real edits clear its shadow", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "9"]);
  enterValues(harness, [3, -4]);
  tapAll(harness, ["EXIT", "2ND", "-", "MORE", "MORE", "MORE", "MORE", "F1"]);
  assertClose(harness.packedNumber(LIST_A + 1), 3);
  assertClose(harness.packedNumber(LIST_A_IMAG), -4);

  harness.tap("F2");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_COMPLEX);
  assertClose(harness.packedNumber(0x8744), 3);
  assertClose(harness.packedNumber(0x874d), -4);

  tapAll(harness, ["EXIT", "2ND", "-"]);
  enterValues(harness, [7]);
  assertClose(harness.packedNumber(LIST_A + 1), 7);
  assertClose(harness.packedNumber(LIST_A_IMAG), 0);
});

test("[collections.phase18.menus] complex list, matrix, and vector pages have exact LCD goldens", () => {
  for (const [name, keys, pages] of [
    ["phase18-list-complex-menu", ["2ND", "-"], 4],
    ["phase18-matrix-complex-menu", ["2ND", "7"], 5],
    ["phase18-vector-complex-menu", ["2ND", "8"], 4]
  ]) {
    const harness = Free85Harness.boot();
    tapAll(harness, keys);
    for (let index = 0; index < pages; index += 1) harness.tap("MORE");
    assertLcdGolden(name, harness.machine.renderLcdBitmap());
  }
});

test("[collections.phase18.list] element-wise complex add, multiply, and divide retain both components", () => {
  const operation = (key) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "-"]);
    enterValues(harness, [2, -1, 0, 0]);
    harness.tap("ALPHA");
    enterValues(harness, [1, 3, 0, 0]);
    setImaginaryPlane(harness, LIST_A_IMAG, [3, 2, 0, 0]);
    setImaginaryPlane(harness, LIST_B_IMAG, [-2, 4, 0, 0]);
    tapAll(harness, ["MORE", "MORE", key]);
    harness.runFrames(900);
    return {
      real: packedValues(harness, LIST_RESULT, 2, 1),
      imag: packedValues(harness, LIST_RESULT_IMAG, 2)
    };
  };

  assert.deepEqual(operation("F1"), { real: [3, 2], imag: [1, 6] });
  assert.deepEqual(operation("F3"), { real: [8, -11], imag: [-1, 2] });
  const quotient = operation("F4");
  assertClose(quotient.real[0], -0.8);
  assertClose(quotient.imag[0], 1.4);
  assertClose(quotient.real[1], 0.2);
  assertClose(quotient.imag[1], 0.4);
});

test("[collections.phase18.aggregates] list sum and product preserve complex components", () => {
  const run = (pages) => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "-"]);
    harness.machine.write8(LIST_A, 2);
    writePacked(harness, LIST_A + 1, 1);
    writePacked(harness, LIST_A + 10, 3);
    setImaginaryPlane(harness, LIST_A_IMAG, [2, -1]);
    for (let index = 0; index < pages; index += 1) harness.tap("MORE");
    harness.tap("F1");
    harness.runFrames(900);
    return [harness.packedNumber(LIST_RESULT + 1), harness.packedNumber(LIST_RESULT_IMAG)];
  };
  assert.deepEqual(run(0), [4, 1]);
  const product = run(1);
  assertClose(product[0], 5);
  assertClose(product[1], 5);
});

test("[collections.phase18.matrix-products] complex scale and matrix product match independent arithmetic", () => {
  const setup = () => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "7"]);
    harness.machine.write8(0x8900, 2);
    harness.machine.write8(0x8901, 2);
    harness.machine.write8(0x8980, 2);
    harness.machine.write8(0x8981, 2);
    [1, 2, 3, 4].forEach((value, index) => writePacked(harness, 0x8902 + index * 9, value));
    [2, 0, 1, 2].forEach((value, index) => writePacked(harness, 0x8982 + index * 9, value));
    setImaginaryPlane(harness, MATRIX_A_IMAG, [1, 0, -1, 2]);
    setImaginaryPlane(harness, MATRIX_B_IMAG, [1, 0, 0, -1]);
    return harness;
  };

  const scale = setup();
  tapAll(scale, ["MORE", "F4"]);
  scale.runFrames(1400);
  assert.deepEqual(packedValues(scale, MATRIX_RESULT, 4, 2), [1, 4, 7, 6]);
  assert.deepEqual(packedValues(scale, MATRIX_RESULT_IMAG, 4), [3, 2, 1, 8]);

  const multiply = setup();
  tapAll(multiply, ["MORE", "F3"]);
  multiply.runFrames(5000);
  const expected = [[3, 3], [4, -2], [11, 3], [10, 0]];
  expected.forEach(([real, imag], index) => {
    assertClose(multiply.packedNumber(MATRIX_RESULT + 2 + index * 9), real);
    assertClose(multiply.packedNumber(MATRIX_RESULT_IMAG + index * 9), imag);
  });
});

test("[collections.phase18.vector-products] complex scale, dot, and cross products retain both planes", () => {
  const setup = () => {
    const harness = Free85Harness.boot();
    tapAll(harness, ["2ND", "8"]);
    harness.machine.write8(0x8b00, 3);
    harness.machine.write8(0x8b40, 3);
    [1, 2, 0].forEach((value, index) => writePacked(harness, 0x8b01 + index * 9, value));
    [0, 1, 2].forEach((value, index) => writePacked(harness, 0x8b41 + index * 9, value));
    setImaginaryPlane(harness, VECTOR_A_IMAG, [1, 0, 1]);
    setImaginaryPlane(harness, VECTOR_B_IMAG, [1, -1, 0]);
    return harness;
  };

  const dot = setup();
  dot.tap("F3");
  dot.runFrames(2200);
  assertClose(dot.packedNumber(VECTOR_RESULT + 1), 1);
  assertClose(dot.packedNumber(VECTOR_RESULT_IMAG), 1);

  const cross = setup();
  cross.tap("F4");
  cross.runFrames(3500);
  [[3, -1], [-3, -2], [2, -2]].forEach(([real, imag], index) => {
    assertClose(cross.packedNumber(VECTOR_RESULT + 1 + index * 9), real);
    assertClose(cross.packedNumber(VECTOR_RESULT_IMAG + index * 9), imag);
  });

  const scale = setup();
  tapAll(scale, ["MORE", "F3"]);
  scale.runFrames(1800);
  [[-1, 1], [0, 2], [-1, 0]].forEach(([real, imag], index) => {
    assertClose(scale.packedNumber(VECTOR_RESULT + 1 + index * 9), real);
    assertClose(scale.packedNumber(VECTOR_RESULT_IMAG + index * 9), imag);
  });
});

test("[collections.phase18.lu] zero-leading pivots report a permutation and reconstruct P*A=L*U", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "7"]);
  enterValues(harness, [0, 1, 2, 3]);
  tapAll(harness, ["MORE", "MORE", "MORE", "MORE", "F1"]);
  harness.runFrames(1500);
  assert.deepEqual(packedValues(harness, MATRIX_RESULT, 4, 2), [2, 3, 0, 1]);
  assert.deepEqual(packedValues(harness, VECTOR_RESULT, 2, 1), [2, 1]);
});

test("[collections.phase18.eigenvalues] a general 3x3 matrix returns its real and complex roots", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "7"]);
  harness.machine.write8(0x8900, 3);
  harness.machine.write8(0x8901, 3);
  [0, -1, 0, 1, 0, 0, 0, 0, 2].forEach((value, index) => writePacked(harness, 0x8902 + index * 9, value));
  tapAll(harness, ["MORE", "MORE", "MORE", "MORE", "F2"]);
  harness.runFrames(30_000);
  const roots = Array.from({ length: 3 }, (_, index) => [
    harness.packedNumber(MATRIX_RESULT + 2 + index * 9),
    harness.packedNumber(MATRIX_RESULT_IMAG + index * 9)
  ]);
  const realRoot = roots.find(([real, imag]) => Math.abs(imag) < 1e-8 && Math.abs(real - 2) < 1e-8);
  assert.ok(realRoot, JSON.stringify(roots));
  const complex = roots.filter((root) => root !== realRoot).sort((left, right) => left[1] - right[1]);
  assertClose(complex[0][0], 0, 1e-8);
  assertClose(complex[0][1], -1, 1e-8);
  assertClose(complex[1][0], 0, 1e-8);
  assertClose(complex[1][1], 1, 1e-8);
});

test("[collections.phase18.eigensystem] a 2x2 rotation returns normalized complex eigenpairs", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "7"]);
  harness.machine.write8(0x8900, 2);
  harness.machine.write8(0x8901, 2);
  const matrix = [0, -1, 1, 0];
  matrix.forEach((value, index) => writePacked(harness, 0x8902 + index * 9, value));
  tapAll(harness, ["MORE", "MORE", "MORE", "MORE", "F3"]);
  harness.runFrames(35_000);

  const multiply = ([ar, ai], [br, bi]) => [(ar * br) - (ai * bi), (ar * bi) + (ai * br)];
  for (let column = 0; column < 2; column += 1) {
    const lambda = [harness.packedNumber(0x9040 + column * 18), harness.packedNumber(0x9049 + column * 18)];
    assertClose(lambda[0], 0, 1e-8);
    assertClose(Math.abs(lambda[1]), 1, 1e-8);
    const vector = Array.from({ length: 2 }, (_, row) => [
      harness.packedNumber(MATRIX_RESULT + 2 + ((row * 2) + column) * 9),
      harness.packedNumber(MATRIX_RESULT_IMAG + ((row * 2) + column) * 9)
    ]);
    const norm = Math.sqrt(vector.reduce((sum, [real, imag]) => sum + (real * real) + (imag * imag), 0));
    assertClose(norm, 1, 1e-8);
    for (let row = 0; row < 2; row += 1) {
      const av = vector.reduce((sum, value, inner) => {
        const term = multiply([matrix[(row * 2) + inner], 0], value);
        return [sum[0] + term[0], sum[1] + term[1]];
      }, [0, 0]);
      const lv = multiply(lambda, vector[row]);
      assertClose(av[0] - lv[0], 0, 1e-7);
      assertClose(av[1] - lv[1], 0, 1e-7);
    }
  }
});

test("[collections.phase18.eigenvectors] normalized complex 3x3 vectors satisfy A*v=lambda*v", () => {
  const harness = Free85Harness.boot();
  tapAll(harness, ["2ND", "7"]);
  harness.machine.write8(0x8900, 3);
  harness.machine.write8(0x8901, 3);
  const matrix = [2, 1, 0, 0, 3, 1, 1, 0, 4];
  matrix.forEach((value, index) => writePacked(harness, 0x8902 + index * 9, value));
  tapAll(harness, ["MORE", "MORE", "MORE", "MORE", "F3"]);
  harness.runFrames(40_000);

  const multiply = ([ar, ai], [br, bi]) => [(ar * br) - (ai * bi), (ar * bi) + (ai * br)];
  const subtract = ([ar, ai], [br, bi]) => [ar - br, ai - bi];
  for (let column = 0; column < 3; column += 1) {
    const lambda = [harness.packedNumber(0x9040 + column * 18), harness.packedNumber(0x9049 + column * 18)];
    const vector = Array.from({ length: 3 }, (_, row) => [
      harness.packedNumber(MATRIX_RESULT + 2 + ((row * 3) + column) * 9),
      harness.packedNumber(MATRIX_RESULT_IMAG + ((row * 3) + column) * 9)
    ]);
    const norm = Math.sqrt(vector.reduce((sum, [real, imag]) => sum + (real * real) + (imag * imag), 0));
    assertClose(norm, 1, 1e-8);
    for (let row = 0; row < 3; row += 1) {
      const av = vector.reduce((sum, value, inner) => {
        const term = multiply([matrix[(row * 3) + inner], 0], value);
        return [sum[0] + term[0], sum[1] + term[1]];
      }, [0, 0]);
      const residual = subtract(av, multiply(lambda, vector[row]));
      assertClose(residual[0], 0, 1e-7);
      assertClose(residual[1], 0, 1e-7);
    }
  }
});
