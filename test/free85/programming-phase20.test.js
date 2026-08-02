import assert from "node:assert/strict";
import test from "node:test";
import { FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_GRAPH = 2;
const SCREEN_LIST = 5;
const SCREEN_STATISTICS = 8;
const SCREEN_SOLVER = 10;
const SCREEN_PROGRAM_INPUT = 19;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_RUNNING = 0x9504;
const P10_ERROR = 0x9506;
const P10_ERROR_LINE = 0x9507;
const P10_OUTPUT = 0x9be0;
const P20_WAIT_MODE = 0x9ce0;
const P20_DEVICE_LENGTH = 0x9ce5;
const P20_DEVICE_BUFFER = 0x9ce6;
const VARIABLES = 0x8218;
const STRING_A = 0x9320;
const STRING_B = 0x9360;
const GRAPH_ENABLED = 0x8501;
const GRAPH_EQ1 = 0x8510;
const GRAPH_MODE = 0x869a;
const LIST_RESULT = 0x8880;
const STATS_RESULT = 0x8d20;
const SOLVER_EQUATION = 0x91a0;

function writeProgram(harness, lines) {
  harness.machine.write8(P10_EXISTS, 1);
  for (const [index, character] of [..."TEST\0"].entries()) {
    harness.machine.write8(P10_NAMES + index, character.charCodeAt(0));
  }
  for (let line = 0; line < lines.length; line += 1) {
    const address = P10_DATA + line * P10_LINE_SIZE;
    harness.machine.write8(address, lines[line].length);
    for (let index = 0; index < lines[line].length; index += 1) {
      harness.machine.write8(address + 1 + index, lines[line].charCodeAt(index));
    }
    harness.machine.write8(address + 1 + lines[line].length, 0);
  }
}

function runProgram(lines, frames = 100) {
  const harness = Free85Harness.boot();
  writeProgram(harness, lines);
  harness.tap("PRGM");
  harness.tap("F3");
  harness.runFrames(frames);
  return harness;
}

function ascii(harness, address, capacity = 32) {
  const bytes = [];
  for (let index = 0; index < capacity; index += 1) {
    const byte = harness.machine.read8(address + index);
    if (byte === 0) break;
    bytes.push(byte);
  }
  return String.fromCharCode(...bytes);
}

function writeString(harness, address, value) {
  harness.machine.write8(address, value.length);
  for (let index = 0; index < value.length; index += 1) {
    harness.machine.write8(address + 1 + index, value.charCodeAt(index));
  }
}

test("[program.phase20.control] labels, Goto, Repeat, IS>, and DS< follow exact lines", () => {
  const jump = runProgram(["GOTO OK", "DISP 0", "LBL OK", "DISP 7", "STOP"]);
  assert.equal(ascii(jump, P10_OUTPUT), "7");

  const repeat = runProgram(["0->A", "REPEAT A=3", "A+1->A", "END", "DISP A", "STOP"]);
  assert.equal(ascii(repeat, P10_OUTPUT), "3");

  const increment = runProgram(["0->A", "IS> A,0", "DISP 0", "DISP A", "STOP"]);
  assert.equal(ascii(increment, P10_OUTPUT), "1");
  const decrement = runProgram(["2->A", "DS< A,2", "DISP 0", "DISP A", "STOP"]);
  assert.equal(ascii(decrement, P10_OUTPUT), "1");
});

test("[program.phase20.menu] a soft-key menu branches through program labels", () => {
  const harness = runProgram(["MENU ONE,TWO", "LBL ONE", "DISP 1", "STOP", "LBL TWO", "DISP 2", "STOP"], 1);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_PROGRAM_INPUT);
  assert.equal(harness.machine.read8(P20_WAIT_MODE), 5);
  assertLcdGolden("phase20-program-menu", harness.machine.renderLcdBitmap());
  harness.tap("F2");
  harness.runFrames(20);
  assert.equal(ascii(harness, P10_OUTPUT), "2");
  assert.equal(harness.machine.read8(P10_ERROR), 0);
});

test("[program.phase20.io] GetKey is nonblocking while Pause and Prompt resume deterministically", () => {
  const idleKey = runProgram(["GETKEY A", "DISP A", "STOP"]);
  assert.equal(idleKey.packedNumber(VARIABLES), 0);

  const getKey = runProgram(["REPEAT A", "GETKEY A", "END", "DISP A", "STOP"], 4);
  getKey.tap("SIN");
  getKey.runFrames(20);
  assert.equal(getKey.packedNumber(VARIABLES), 22);
  assert.equal(ascii(getKey, P10_OUTPUT), "22");

  const pause = runProgram(["1->A", "PAUSE", "A+1->A", "DISP A", "STOP"], 2);
  assert.equal(pause.machine.read8(P20_WAIT_MODE), 4);
  pause.tap("F1");
  pause.runFrames(20);
  assert.equal(ascii(pause, P10_OUTPUT), "2");

  const prompt = runProgram(["PROMPT A", "DISP A*2", "STOP"], 1);
  assert.equal(prompt.machine.read8(P20_WAIT_MODE), 1);
  assertLcdGolden("phase20-prompt-banner", prompt.machine.renderLcdBitmap());
  prompt.tap("6");
  prompt.tap("ENTER");
  prompt.runFrames(20);
  assert.equal(ascii(prompt, P10_OUTPUT), "12");
});

test("[program.phase20.strings] string input and equation conversion round-trip exactly", () => {
  const harness = runProgram(["INPST A", "STTOEQ A,1", "EQTOST 1,B", "STOP"], 1);
  assert.equal(harness.machine.read8(P20_WAIT_MODE), 2);
  assertLcdGolden("phase20-string-input", harness.machine.renderLcdBitmap());
  for (const key of ["ALPHA", "7", "ALPHA", "8", "ALPHA", "+"]) harness.tap(key);
  harness.tap("ENTER");
  harness.runFrames(30);
  assert.equal(harness.machine.read8(STRING_A), 3);
  assert.equal(ascii(harness, STRING_A + 1), "LMX");
  assert.equal(harness.machine.read8(GRAPH_EQ1), 3);
  assert.equal(ascii(harness, GRAPH_EQ1 + 1), "LMX");
  assert.equal(harness.machine.read8(STRING_B), 3);
  assert.equal(ascii(harness, STRING_B + 1), "LMX");
  assert.equal(harness.machine.read8(GRAPH_ENABLED) & 1, 1);
});

test("[program.phase20.display-device] positioned output, clear, print, and virtual I/O are bounded", () => {
  const positioned = runProgram(["OUTPT 3,12,HELLO", "STOP"]);
  assert.equal(positioned.machine.renderLcdBitmap().litPixelCount > 0, true);
  assertLcdGolden("phase20-positioned-output", positioned.machine.renderLcdBitmap());

  const cleared = runProgram(["CLLCD", "STOP"]);
  assert.equal(cleared.machine.renderLcdBitmap().litPixelCount, 0);

  const virtual = runProgram(["VOUT 42", "VIN A", "DISP A", "PRTSCRN", "STOP"]);
  assert.equal(virtual.packedNumber(VARIABLES), 42);
  assert.equal(virtual.machine.read8(P20_DEVICE_LENGTH), 8);
  assert.equal(ascii(virtual, P20_DEVICE_BUFFER), "LCD:1024");
});

test("[program.phase20.catalog-graph] catalog expressions and DispG use shared engines", () => {
  const catalog = runProgram(["CAT SQRT(9)->A", "DISP A", "STOP"]);
  assert.equal(catalog.packedNumber(VARIABLES), 3);

  const graph = Free85Harness.boot();
  writeString(graph, GRAPH_EQ1, "X^2-4");
  graph.machine.write8(GRAPH_ENABLED, 1);
  writeProgram(graph, ["DISPG"]);
  graph.tap("PRGM");
  graph.tap("F3");
  graph.runFrames(5);
  assert.equal(graph.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_GRAPH);
});

test("[program.phase20.catalog] vector, collection, statistics, solver, and graph-mode calls use native state", () => {
  const vector = runProgram(["VSET 2,7", "VGET 2,A", "DISP A", "STOP"]);
  assert.equal(vector.packedNumber(VARIABLES), 7);

  const collection = runProgram(["LSET 1,3", "LSET 2,4", "COLL 0"]);
  assert.equal(collection.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_LIST);
  assert.equal(collection.machine.read8(LIST_RESULT), 1);
  assert.equal(collection.packedNumber(LIST_RESULT + 1), 4);

  const statistics = runProgram(["LSET 1,2", "LSET 2,4", "LSET 3,6", "LSET 4,8", "STATC 0"]);
  assert.equal(statistics.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_STATISTICS);
  assert.equal(statistics.packedNumber(STATS_RESULT), 5);

  const solver = runProgram(["SOLVER X-2"]);
  assert.equal(solver.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_SOLVER);
  assert.equal(solver.machine.read8(SOLVER_EQUATION), 3);
  assert.equal(ascii(solver, SOLVER_EQUATION + 1), "X-2");

  const graphMode = runProgram(["GMODE 1"]);
  assert.equal(graphMode.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_GRAPH);
  assert.equal(graphMode.machine.read8(GRAPH_MODE), 1);
});

test("[program.phase20.errors] an unresolved label reports its exact source line", () => {
  const harness = runProgram(["1->A", "GOTO MISSING", "STOP"]);
  assert.equal(harness.machine.read8(P10_RUNNING), 0);
  assert.equal(harness.machine.read8(P10_ERROR), 4);
  assert.equal(harness.machine.read8(P10_ERROR_LINE), 2);
});

test("[program.phase20.interrupt] every waiting instruction remains immediately interruptible", () => {
  for (const line of ["PAUSE", "PROMPT A", "INPST A", "MENU DONE"]) {
    const harness = runProgram([line, "LBL DONE", "STOP"], 1);
    assert.notEqual(harness.machine.read8(P20_WAIT_MODE), 0, line);
    harness.tap("ON");
    assert.equal(harness.machine.read8(P10_RUNNING), 0, line);
    assert.equal(harness.machine.read8(P10_ERROR), 5, line);
    assert.equal(harness.machine.read8(P10_EXISTS), 1, line);
  }
});
