import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import {
  FREE85_NUMERIC_ERROR_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

const GRAPH_EQ1 = 0x8510;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_ERROR = 0x9506;
const P10_OUTPUT = 0x9be0;

const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

function typeExpression(harness, expression) {
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    if (/[A-Z]/.test(character)) {
      harness.tap("ALPHA");
      harness.tap(alphaKeys.get(character));
    } else if (character === "-" && (index === 0 || "(,+-*/^".includes(expression[index - 1]))) {
      harness.tap("(-)");
    } else harness.tap(character);
  }
}

function writeEquation(harness, source) {
  harness.machine.write8(GRAPH_EQ1, source.length);
  for (let index = 0; index < source.length; index += 1) {
    harness.machine.write8(GRAPH_EQ1 + 1 + index, source.charCodeAt(index));
  }
}

function evaluate(expression, { equation, frames = 1800 } = {}) {
  const harness = Free85Harness.boot();
  if (equation) writeEquation(harness, equation);
  typeExpression(harness, expression);
  harness.tap("ENTER");
  harness.runFrames(frames);
  return harness;
}

function assertClose(actual, expected, tolerance = 1e-10) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

function writeProgram(harness, lines) {
  harness.machine.write8(P10_EXISTS, 1);
  for (const [index, character] of [..."TEST"].entries()) harness.machine.write8(P10_NAMES + index, character.charCodeAt(0));
  for (let line = 0; line < lines.length; line += 1) {
    const address = P10_DATA + line * P10_LINE_SIZE;
    harness.machine.write8(address, lines[line].length);
    for (let index = 0; index < lines[line].length; index += 1) {
      harness.machine.write8(address + 1 + index, lines[line].charCodeAt(index));
    }
  }
}

function programOutput(harness) {
  const bytes = [];
  for (let index = 0; index < 24; index += 1) {
    const byte = harness.machine.read8(P10_OUTPUT + index);
    if (!byte) break;
    bytes.push(byte);
  }
  return String.fromCharCode(...bytes);
}

test("[phase15.trig-range] large representable angles remain numerically supported", () => {
  for (const angle of [400, 1000, -1000]) {
    const harness = evaluate(`SIN(${angle})`);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, `SIN(${angle})`);
    assertClose(Number(harness.resultText()), Math.sin(angle), 1e-9);
  }
});

test("[phase15.integration-safety] an endpoint singularity cannot publish an unqualified nonsense result", () => {
  const harness = Free85Harness.boot();
  typeExpression(harness, "PI/4");
  harness.tap("STO▶");
  harness.tap("ALPHA");
  harness.tap(alphaKeys.get("A"));
  harness.tap("ENTER");
  harness.tap("CLEAR");
  writeEquation(harness, "1/SQRT(COS(X)-COS(A))");
  typeExpression(harness, "FNINT(0,A)");
  harness.tap("ENTER");
  harness.runFrames(5000);
  const error = harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS);
  assert.ok([2, 6].includes(error), `expected DIVIDE BY ZERO or NO CONVERGENCE, got ${error} and ${harness.resultText()}`);
});

test.todo("[phase15.calculus-target] calculus commands can explicitly evaluate a stored graph slot", () => {
  const derivative = evaluate("NDER(1,2)", { equation: "X^2" });
  assert.equal(derivative.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
  assertClose(Number(derivative.resultText()), 4, 1e-8);

  const integral = evaluate("FNINT(1,0,2)", { equation: "X^2", frames: 3000 });
  assert.equal(integral.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0);
  assertClose(Number(integral.resultText()), 8 / 3, 1e-9);
});

test.todo("[phase15.program-for] FOR accepts multi-digit expression bounds and an explicit step", () => {
  const harness = Free85Harness.boot();
  writeProgram(harness, ["FOR A,2,12,2", "DISP A", "END", "STOP"]);
  harness.tap("PRGM");
  harness.tap("F3");
  harness.runFrames(300);
  assert.equal(harness.machine.read8(P10_ERROR), 0);
  assert.equal(programOutput(harness), "12");
});
