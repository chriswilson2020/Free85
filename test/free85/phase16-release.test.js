import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_NUMERIC_ERROR_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";

const NUM_RESULT = 0x8092;
const NUM_ERR_DIV_ZERO = 2;
const NUM_ERR_OVERFLOW = 3;
const NUM_ERR_DOMAIN = 4;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_ERROR = 0x9506;
const P10_OUTPUT = 0x9be0;

function expressionKeys(expression) {
  const keys = [];
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (character === "-" && (index === 0 || "+-*/^(".includes(expression[index - 1]))) keys.push("(-)");
    else keys.push(character);
  }
  return keys;
}

function evaluate(expression, frames = 10) {
  const harness = Free85Harness.boot();
  for (const key of expressionKeys(expression)) harness.tap(key);
  harness.tap("ENTER");
  harness.runFrames(frames);
  return harness;
}

function assertClose(actual, expected, tolerance = 2e-11) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

test("[phase16.power-real] positive bases accept fractional and general real exponents", () => {
  for (const [expression, expected] of [
    ["9^0.5", 3],
    ["27^(1/3)", 3],
    ["16^(-0.25)", 0.5],
    ["1.05^30", 1.05 ** 30]
  ]) {
    const harness = evaluate(expression, 240);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
    assertClose(harness.packedNumber(NUM_RESULT), expected);
  }
});

test("[phase16.power-integer] exponentiation by squaring removes the single-digit ceiling", () => {
  for (const [expression, expected] of [
    ["2^20", 1_048_576],
    ["2^(-12)", 1 / 4096],
    ["(-2)^11", -2048],
    ["0^0", 1]
  ]) {
    const harness = evaluate(expression, 20);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
    assertClose(harness.packedNumber(NUM_RESULT), expected);
  }
});

test("[phase16.power-domains] invalid and overflowing powers retain precise error classes", () => {
  for (const [expression, error] of [
    ["(-2)^0.5", NUM_ERR_DOMAIN],
    ["0^(-1)", NUM_ERR_DIV_ZERO],
    ["10^200", NUM_ERR_OVERFLOW]
  ]) {
    const harness = evaluate(expression, 30);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), error, expression);
  }
});

test("[phase16.power-precedence] power remains right-associative with unary-minus precedence", () => {
  assertClose(evaluate("2^3^2", 20).packedNumber(NUM_RESULT), 512);
  assertClose(evaluate("-2^2", 20).packedNumber(NUM_RESULT), -4);
});

test("[phase16.power-program] the banked real-power engine returns safely to a running program", () => {
  const harness = Free85Harness.boot();
  harness.machine.write8(P10_EXISTS, 1);
  [..."TEST"].forEach((character, index) => harness.machine.write8(P10_NAMES + index, character.charCodeAt(0)));
  for (const [lineIndex, line] of ["DISP 9^0.5", "STOP"].entries()) {
    const address = P10_DATA + lineIndex * P10_LINE_SIZE;
    harness.machine.write8(address, line.length);
    [...line].forEach((character, index) => harness.machine.write8(address + 1 + index, character.charCodeAt(0)));
  }
  harness.tap("PRGM");
  harness.tap("F3");
  harness.runFrames(500);
  const output = String.fromCharCode(...Array.from({ length: 24 }, (_, index) => harness.machine.read8(P10_OUTPUT + index)))
    .split("\0", 1)[0];
  assert.equal(harness.machine.read8(P10_ERROR), 0);
  assertClose(Number(output), 3);
});
