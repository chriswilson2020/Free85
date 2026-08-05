import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { FREE85_NUMERIC_ERROR_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";

const ANGLE_MODE = 0x801a;
const EVENT_QUEUE_HEAD = 0x8015;
const EVENT_QUEUE_TAIL = 0x8016;
const EVENT_QUEUE = 0x8050;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_ERROR = 0x9506;
const P10_ERROR_LINE = 0x9507;
const NUM_ERR_CANCELLED = 7;
const NUM_ERR_PRECISION = 8;

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

function evaluate(expression, { degrees = false, frames = 1200 } = {}) {
  const harness = Free85Harness.boot();
  if (degrees) harness.machine.write8(ANGLE_MODE, 1);
  typeExpression(harness, expression);
  harness.tap("ENTER");
  harness.runFrames(frames);
  return harness;
}

function assertClose(expression, expected, tolerance, options) {
  const harness = evaluate(expression, options);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, expression);
  const actual = Number(harness.resultText());
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)),
    `${expression}: expected ${expected}, got ${harness.resultText()}`);
}

function writeProgram(harness, lines) {
  harness.machine.write8(P10_EXISTS, 1);
  for (const [index, character] of [..."TEST"].entries()) {
    harness.machine.write8(P10_NAMES + index, character.charCodeAt(0));
  }
  for (let line = 0; line < lines.length; line += 1) {
    const address = P10_DATA + line * P10_LINE_SIZE;
    harness.machine.write8(address, lines[line].length);
    for (let index = 0; index < lines[line].length; index += 1) {
      harness.machine.write8(address + 1 + index, lines[line].charCodeAt(index));
    }
  }
}

test("[phase15.trig-range-reduction] SIN and COS retain measured accuracy through one million radians", () => {
  for (const angle of [400, 1000, -1000, 10_000]) {
    assertClose(`SIN(${angle})`, Math.sin(angle), 1e-9);
    assertClose(`COS(${angle})`, Math.cos(angle), 1e-9);
  }
  for (const angle of [100_000, 999_999, 1_000_000]) {
    assertClose(`SIN(${angle})`, Math.sin(angle), 1e-7);
    assertClose(`COS(${angle})`, Math.cos(angle), 1e-7);
  }
});

test("[phase15.trig-quadrants] quotient reduction preserves signs and boundaries", () => {
  const turns = 10_000;
  for (const delta of [-0.001, -0.0001, 0.0001, 0.001]) {
    const angle = Number((turns * 2 * Math.PI + delta).toPrecision(14));
    assertClose(`SIN(${angle})`, Math.sin(angle), 1e-8);
    assertClose(`COS(${angle})`, Math.cos(angle), 1e-8);
  }
  for (const angle of [400, 1000, 10_000, 100_000, 999_999]) {
    assertClose(`TAN(${angle})`, Math.tan(angle), 1e-6);
  }
  const pole = evaluate("TAN(PI/2)");
  assert.equal(pole.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 4);
  assertClose("TAN(PI/2-.001)", Math.tan(Math.PI / 2 - 0.001), 1e-5);
});

test("[phase15.trig-degrees] degree values reduce before conversion through one hundred million degrees", () => {
  for (const angle of [36_000_000, 99_999_999, 100_000_000, -100_000_000]) {
    assertClose(`SIN(${angle})`, Math.sin(angle * Math.PI / 180), 1e-7, { degrees: true });
    assertClose(`COS(${angle})`, Math.cos(angle * Math.PI / 180), 1e-7, { degrees: true });
  }
});

test("[phase15.trig-precision] unsupported phase ranges fail explicitly at home and in programs", () => {
  const radians = evaluate("SIN(1000001)");
  assert.equal(radians.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_PRECISION);

  const degrees = evaluate("COS(100000001)", { degrees: true });
  assert.equal(degrees.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_PRECISION);

  const program = Free85Harness.boot();
  writeProgram(program, ["DISP SIN(1000001)", "STOP"]);
  program.tap("PRGM");
  program.tap("F3");
  program.runFrames(1200);
  assert.equal(program.machine.read8(P10_ERROR), 12);
  assert.equal(program.machine.read8(P10_ERROR_LINE), 1);
  assert.equal(program.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_PRECISION);
});

test("[phase15.trig-cancel] large-angle reduction consumes EXIT as cancellation", () => {
  const harness = Free85Harness.boot();
  typeExpression(harness, "SIN(1000000)");
  harness.machine.write8(EVENT_QUEUE_HEAD, 0);
  harness.machine.write8(EVENT_QUEUE_TAIL, 2);
  harness.machine.write8(EVENT_QUEUE, 49);
  harness.machine.write8(EVENT_QUEUE + 1, 6);
  harness.runFrames(100);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_CANCELLED);
});
