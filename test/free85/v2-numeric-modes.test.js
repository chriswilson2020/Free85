import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import {
  FREE85_NUMERIC_ERROR_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

const DISPLAY_MODE = 0x9d03;
const FIX_DIGITS = 0x9d94;
const GRAPH_EQ1 = 0x8510;
const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

function typeExpression(harness, expression) {
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (/[A-Za-z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character.toUpperCase()));
    } else if (character === "-" && (index === 0 || "(,+-*/^".includes(expression[index - 1]))) {
      harness.tap("(-)");
    } else harness.tap(character);
  }
}

function evaluate(expression, { mode = 0, fixed = 0, equation } = {}) {
  const harness = Free85Harness.boot();
  harness.machine.write8(DISPLAY_MODE, mode);
  harness.machine.write8(FIX_DIGITS, fixed);
  if (equation) {
    harness.machine.write8(GRAPH_EQ1, equation.length);
    for (let index = 0; index < equation.length; index += 1) {
      harness.machine.write8(GRAPH_EQ1 + 1 + index, equation.charCodeAt(index));
    }
  }
  typeExpression(harness, expression);
  harness.tap("ENTER");
  harness.runFrames(1500);
  return harness;
}

function assertResult(expression, expected, options) {
  const harness = evaluate(expression, options);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
  assert.equal(harness.resultText(), expected, expression);
}

function assertClose(expression, expected, tolerance, options) {
  const harness = evaluate(expression, options);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
  assert.ok(Math.abs(Number(harness.resultText()) - expected) <= tolerance,
    `${expression}: ${harness.resultText()}`);
}

test("[v2.numeric.utilities] scalar, integer, random, root, and range utilities", () => {
  for (const [expression, expected] of [
    ["INT(-12.9)", "-12"], ["FRAC(12.75)", "0.75"],
    ["ROUND(12.345,2)", "12.35"], ["SIGN(-3)", "-1"],
    ["ROUND(1.234567891235,11)", "1.23456789124"],
    ["MOD(17,5)", "2"], ["GCD(84,30)", "6"], ["LCM(6,8)", "24"],
    ["MIN(-2,3)", "-2"], ["MAX(-2,3)", "3"], ["PCT(200,15)", "30"],
    ["RAND()", "0.7968"], ["RANDI(4,9)", "6"]
  ]) assertResult(expression, expected);
  assertClose("ROOT(27,3)", 3, 1e-10);
});

test("[v2.mode.display] normal, scientific, engineering, and fixed rounding", () => {
  assertResult("12345", "12345", { mode: 0 });
  assertResult("12345", "1.2345E4", { mode: 1 });
  assertResult("12345", "12.345E3", { mode: 2 });
  assertResult("0.00123", "1.23E-3", { mode: 2 });
  assertResult("0.00012", "120E-6", { mode: 2 });
  assertResult("12345", "12345.00", { mode: 3, fixed: 2 });
  assertResult("0.005", "0.01", { mode: 3, fixed: 2 });
  assertResult("99.995", "100.00", { mode: 3, fixed: 2 });
  assertResult("0", "0.000", { mode: 3, fixed: 3 });
  assertResult("1.2", "1.20000000000", { mode: 3, fixed: 11 });
  assertResult("1E30", "1E30", { mode: 3, fixed: 2 });
});

test("[v2.mode.display] system controls cycle modes and adjust fixed precision", () => {
  const harness = Free85Harness.boot();
  harness.tap("2ND");
  harness.tap("MORE");
  harness.tap("F1");
  for (const expected of [1, 2, 3]) {
    harness.tap("F2");
    assert.equal(harness.machine.read8(DISPLAY_MODE), expected);
  }
  harness.tap("UP");
  assert.equal(harness.machine.read8(FIX_DIGITS), 1);
  harness.tap("DOWN");
  assert.equal(harness.machine.read8(FIX_DIGITS), 0);
  harness.tap("F2");
  assert.equal(harness.machine.read8(DISPLAY_MODE), 0);
});

test("[v2.base.full] prefixed literals participate in normal arithmetic", () => {
  for (const [expression, expected] of [
    ["0x2A+1", "43"], ["0b101010", "42"], ["0o52", "42"],
    ["0x7FFF", "32767"], ["0x8000", "-32768"], ["0xFFFF", "-1"]
  ]) assertResult(expression, expected);
  assert.equal(evaluate("0x10000").machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 3);
});

test("[v2.base.boolean] signed word logic, shifts, and rotations are exact", () => {
  for (const [expression, expected] of [
    ["AND(6,3)", "2"], ["OR(6,3)", "7"], ["XOR(6,3)", "5"],
    ["NOT(0)", "-1"], ["SHL(3,2)", "12"], ["SHR(-1,1)", "32767"],
    ["ROL(32767,1)", "-2"], ["ROR(1,1)", "-32768"]
  ]) assertResult(expression, expected);
});

test("[v2.numeric.calculus] active-function callables evaluate, derive, integrate, and analyse", () => {
  const equation = "X^2";
  assertResult("EVAL(3)", "9", { equation });
  assertClose("NDER(3)", 6, 1e-8, { equation });
  assertClose("FNINT(0,2)", 8 / 3, 1e-10, { equation });
  assertClose("FMIN(-2,2)", 0, 2e-4, { equation });
  assertClose("FMAX(-2,2)", -2, 4e-4, { equation });
  assertResult("INTER(0,2)", "2", { equation });
  assertClose("ARC(0,1)", 1.4789428575, 3e-5, { equation });
});

test("[v2.catalog] every Phase 14.2 callable is available from the catalog", () => {
  const names = [
    "AND", "ARC", "EVAL", "FMAX", "FMIN", "FNINT", "FRAC", "GCD", "INT", "INTER",
    "LCM", "MAX", "MIN", "MOD", "NDER", "NOT", "OR", "PCT", "RAND", "RANDI",
    "ROL", "ROOT", "ROR", "ROUND", "SHL", "SHR", "SIGN", "XOR"
  ];
  for (const [offset, name] of names.entries()) {
    const harness = Free85Harness.boot();
    harness.tap("2ND");
    harness.tap("CUSTOM");
    harness.machine.write8(0x9305, 56 + offset);
    harness.tap("ENTER");
    assert.equal(harness.editorText(), `${name}(`, name);
  }
});
