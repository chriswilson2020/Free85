import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import {
  FREE85_NUMERIC_ERROR_ADDRESS,
  Free85Harness
} from "../helpers/free85-harness.js";

const GRAPH_ACTIVE = 0x8502;
const GRAPH_EQ1 = 0x8510;
const GRAPH_ENABLED = 0x8501;
const GRAPH_LAST_ERROR = 0x869c;
const GRAPH_INTEGRAL_PANELS = 0x869d;
const EVENT_QUEUE_HEAD = 0x8015;
const EVENT_QUEUE_TAIL = 0x8016;
const EVENT_QUEUE = 0x8050;
const UI_MODE = 0x800b;
const SCREEN_TABLE = 3;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_ERROR = 0x9506;
const P10_ERROR_LINE = 0x9507;

const NUM_ERR_SYNTAX = 1;
const NUM_ERR_DIV_ZERO = 2;
const NUM_ERR_RECURSION = 5;
const NUM_ERR_NO_CONVERGENCE = 6;
const NUM_ERR_CANCELLED = 7;

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
  harness.machine.write8(GRAPH_ENABLED, source.length ? 1 : 0);
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

function runProgram(lines, equation) {
  const harness = Free85Harness.boot();
  if (equation !== undefined) writeEquation(harness, equation);
  writeProgram(harness, lines);
  harness.tap("PRGM");
  harness.tap("F3");
  harness.runFrames(7000);
  return harness;
}

function evaluate(expression, equation, frames = 5000) {
  const harness = Free85Harness.boot();
  writeEquation(harness, equation);
  typeExpression(harness, expression);
  harness.tap("ENTER");
  harness.runFrames(frames);
  return harness;
}

function assertClose(actual, expected, tolerance = 1e-8) {
  assert.ok(Math.abs(actual - expected) <= tolerance * Math.max(1, Math.abs(expected)), `${actual} != ${expected}`);
}

test("[phase15.integration-smooth] bounded refinement retains accurate ordinary integrals", () => {
  for (const [equation, call, expected, tolerance] of [
    ["X^2", "FNINT(0,2)", 8 / 3, 1e-10],
    ["X^4", "FNINT(0,1)", 0.2, 1e-7],
    ["SIN(X)", "FNINT(0,PI)", 2, 1e-7],
    ["1/(1+X^2)", "FNINT(0,1)", Math.PI / 4, 1e-7],
    ["X^2", "FNINT(2,0)", -8 / 3, 1e-10]
  ]) {
    const harness = evaluate(call, equation);
    assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, `${equation}: ${call}`);
    assertClose(Number(harness.resultText()), expected, tolerance);
    assert.ok([64, 128].includes(harness.machine.read8(GRAPH_INTEGRAL_PANELS)));
  }
});

test("[phase15.integration-unsafe] singular, undersampled, and non-convergent intervals refuse safely", () => {
  const discontinuity = evaluate("FNINT(-1,1)", "1/X");
  assert.equal(discontinuity.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_DIV_ZERO);

  const stretched = evaluate("FNINT(1,1000)", "1/X^3", 7000);
  assert.equal(stretched.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_NO_CONVERGENCE);
  assert.equal(stretched.machine.read8(GRAPH_INTEGRAL_PANELS), 128);

  const spike = evaluate("FNINT(0,1)", "1/(1+10000*(X-.5)^2)", 7000);
  assert.equal(spike.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_NO_CONVERGENCE);
  assert.equal(spike.machine.read8(GRAPH_INTEGRAL_PANELS), 128);
});

test("[phase15.error-integrity] syntax, divide, recursion, and convergence remain distinct", () => {
  const empty = evaluate("FNINT(0,1)", "");
  assert.equal(empty.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_SYNTAX);

  const graph = Free85Harness.boot();
  graph.tap("GRAPH");
  while (graph.machine.read8(GRAPH_ACTIVE)) graph.runFrames(100);
  writeEquation(graph, "NDER(X)");
  graph.tap("GRAPH");
  let frames = 0;
  while (graph.machine.read8(GRAPH_ACTIVE) && frames < 5000) {
    graph.runFrames(100);
    frames += 100;
  }
  assert.equal(graph.machine.read8(GRAPH_ACTIVE), 0);
  assert.equal(graph.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, "plotting represents bad samples without poisoning home state");
  assert.equal(graph.machine.read8(GRAPH_LAST_ERROR), NUM_ERR_RECURSION);
});

test("[phase15.error-contexts] graph, table, and program preserve useful diagnostics", () => {
  const table = Free85Harness.boot();
  typeExpression(table, "1/X");
  table.tap("GRAPH");
  let frames = 0;
  while (table.machine.read8(GRAPH_ACTIVE) && frames < 5000) {
    table.runFrames(100);
    frames += 100;
  }
  table.tap("MORE");
  table.runFrames(200);
  assert.equal(table.machine.read8(UI_MODE), SCREEN_TABLE);
  assert.equal(table.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), 0, "table UNDEF does not poison home state");
  assert.equal(table.machine.read8(GRAPH_LAST_ERROR), NUM_ERR_DIV_ZERO);

  for (const [line, programError, numericError] of [
    ["DISP 1/0", 6, NUM_ERR_DIV_ZERO],
    ["DISP LN(0)", 8, 4]
  ]) {
    const program = runProgram([line, "STOP"]);
    assert.equal(program.machine.read8(P10_ERROR), programError, line);
    assert.equal(program.machine.read8(P10_ERROR_LINE), 1, line);
    assert.equal(program.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), numericError, line);
  }

  const nonConvergent = runProgram(["DISP FNINT(1,1000)", "STOP"], "1/X^3");
  assert.equal(nonConvergent.machine.read8(P10_ERROR), 10);
  assert.equal(nonConvergent.machine.read8(P10_ERROR_LINE), 1);
  assert.equal(nonConvergent.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_NO_CONVERGENCE);
});

test("[phase15.integration-cancel] EXIT interrupts bounded refinement", () => {
  const harness = Free85Harness.boot();
  writeEquation(harness, "SIN(X^2)");
  typeExpression(harness, "FNINT(0,100)");
  // Queue ENTER followed by EXIT before giving the Z80 another frame. The UI
  // consumes ENTER and starts FNINT; its bounded loop must then poll and
  // consume the queued EXIT rather than running to completion.
  harness.machine.write8(EVENT_QUEUE_HEAD, 0);
  harness.machine.write8(EVENT_QUEUE_TAIL, 2);
  harness.machine.write8(EVENT_QUEUE, 49);
  harness.machine.write8(EVENT_QUEUE + 1, 6);
  harness.runFrames(100);
  assert.equal(harness.machine.read8(FREE85_NUMERIC_ERROR_ADDRESS), NUM_ERR_CANCELLED);
});
