import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import {
  FREE85_NUMERIC_ERROR_ADDRESS,
  FREE85_UI_MODE_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

const alphaKeys = new Map(
  TI85_PHYSICAL_KEYS
    .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
    .map(({ alpha, key }) => [alpha, key])
);

function typeExpression(harness, expression) {
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (/[A-Z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character));
    } else if (character === "-" && (index === 0 || ",( +*/^-".includes(expression[index - 1]))) {
      harness.tap("(-)");
    } else {
      harness.tap(character);
    }
  }
}

function evaluate(expression, { degrees = false, settleFrames = 120 } = {}) {
  const harness = Free85Harness.boot();
  if (degrees) {
    harness.tap("2ND");
    harness.tap("MORE");
    harness.tap("F1");
    harness.tap("EXIT");
  }
  typeExpression(harness, expression);
  harness.tap("ENTER");
  harness.runFrames(settleFrames);
  return harness;
}

function assertClose(expression, expected, tolerance = 1e-10, options) {
  const harness = evaluate(expression, options);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
  const actual = Number(harness.resultText());
  const scale = Math.max(1, Math.abs(expected));
  assert.ok(Math.abs(actual - expected) <= tolerance * scale,
    `${expression}: expected ${expected}, got ${harness.resultText()}`);
}

test("[scientific.functions] logarithmic, exponential, and trigonometric vectors", () => {
  for (const [expression, expected] of [
    ["EXP(1)", Math.E],
    ["LN(E)", 1],
    ["LOG(1000)", 3],
    ["TEN(3)", 1000],
    ["SIN(PI/2)", 1],
    ["COS(0)", 1],
    ["TAN(PI/4)", 1],
    ["ASIN(1)", Math.PI / 2],
    ["ACOS(1)", 0],
    ["ATAN(1)", Math.PI / 4]
  ]) assertClose(expression, expected);
});

test("[scientific.hyperbolic] hyperbolic and inverse-hyperbolic vectors", () => {
  for (const [expression, expected] of [
    ["SINH(1)", Math.sinh(1)],
    ["COSH(1)", Math.cosh(1)],
    ["TANH(1)", Math.tanh(1)],
    ["ASINH(1)", Math.asinh(1)],
    ["ACOSH(2)", Math.acosh(2)],
    ["ATANH(0.5)", Math.atanh(0.5)]
  ]) assertClose(expression, expected);
});

test("[scientific.combinatorics] factorial, permutations, and combinations", () => {
  for (const [expression, expected] of [
    ["FACT(0)", 1],
    ["FACT(5)", 120],
    ["NPR(5,2)", 20],
    ["NCR(5,2)", 10],
    ["NCR(20,10)", 184756]
  ]) assertClose(expression, expected);
});

test("[scientific.angle-modes] degree mode and explicit conversions are deterministic", () => {
  assertClose("SIN(30)", 0.5, 1e-10, { degrees: true });
  assertClose("ASIN(0.5)", 30, 1e-10, { degrees: true });
  assertClose("RAD(180)", Math.PI);
  assertClose("DEG(PI)", 180);
});

test("[scientific.constants] physical constants are packed decimal source data", () => {
  for (const [expression, expected] of [
    ["LIGHT", 299792458],
    ["GRAV", 9.80665],
    ["PLANCK", 6.62607015e-34],
    ["BOLTZ", 1.380649e-23],
    ["AVOG", 6.02214076e23]
  ]) assertClose(expression, expected);
});

test("[scientific.conversions] every required conversion category has a decimal vector", () => {
  for (const [expression, expected] of [
    ["CMIN(2.54)", 1],
    ["SQMFT(1)", 10.76391041671],
    ["LGAL(1)", 0.26417205235815],
    ["KGLB(1)", 2.2046226218488],
    ["CTOF(100)", 212],
    ["MINS(2)", 120],
    ["KMHMPH(100)", 62.137119223733],
    ["BARPSI(1)", 14.503773773022],
    ["JCAL(1)", 0.23900573613767],
    ["WHP(1000)", 1.341022089595],
    ["RAD(180)", Math.PI]
  ]) assertClose(expression, expected);
  assertClose("FTOC(32)", 0);
  assertClose("INCM(1)", 2.54);
});

test("scientific domains and arity errors remain recoverable", () => {
  for (const expression of ["LN(0)", "ASIN(2)", "ATANH(1)", "FACT(2.5)", "NCR(2,3)"]) {
    const harness = evaluate(expression);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 4, expression);
    assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), 1, expression);
  }
  const arity = evaluate("SIN(1,2)");
  assert.equal(arity.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 1);
});
