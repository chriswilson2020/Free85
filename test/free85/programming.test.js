import assert from "node:assert/strict";
import test from "node:test";
import { TI85_PHYSICAL_KEYS } from "../../src/ti85-keys.js";
import { FREE85_BOOT_FRAMES, FREE85_UI_MODE_ADDRESS, Free85Harness } from "../helpers/free85-harness.js";
import { assertLcdGolden } from "../helpers/lcd-visual.js";

const SCREEN_GRAPH = 2;
const SCREEN_PROGRAM_LIST = 15;
const SCREEN_PROGRAM_EDIT = 16;
const SCREEN_PROGRAM_RUN = 18;
const SCREEN_PROGRAM_INPUT = 19;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_PROGRAM_SIZE = 392;
const P10_LINE_SIZE = 49;
const P10_RUNNING = 0x9504;
const P10_ERROR = 0x9506;
const P10_ERROR_LINE = 0x9507;
const P10_OUTPUT = 0x9be0;
const VARIABLES = 0x8218;

const alphaKeys = new Map(TI85_PHYSICAL_KEYS
  .filter(({ alpha }) => /^[A-Z]$/.test(alpha ?? ""))
  .map(({ alpha, key }) => [alpha, key]));

function tapAll(harness, keys) {
  for (const key of keys) harness.tap(key);
}

function typeProgramText(harness, value) {
  for (const character of value) {
    if (/[A-Z]/.test(character)) tapAll(harness, ["ALPHA", alphaKeys.get(character)]);
    else if (character === " ") tapAll(harness, ["2ND", "0"]);
    else harness.tap(character);
  }
}

function writeProgram(harness, program, lines, name = `P${program + 1}`) {
  harness.machine.write8(P10_EXISTS + program, 1);
  for (let index = 0; index < name.length; index += 1) {
    harness.machine.write8(P10_NAMES + program * 8 + index, name.charCodeAt(index));
  }
  harness.machine.write8(P10_NAMES + program * 8 + name.length, 0);
  for (let line = 0; line < lines.length; line += 1) {
    const address = P10_DATA + program * P10_PROGRAM_SIZE + line * P10_LINE_SIZE;
    harness.machine.write8(address, lines[line].length);
    for (let index = 0; index < lines[line].length; index += 1) {
      harness.machine.write8(address + 1 + index, lines[line].charCodeAt(index));
    }
    harness.machine.write8(address + 1 + lines[line].length, 0);
  }
}

function output(harness) {
  const bytes = [];
  for (let index = 0; index < 24; index += 1) {
    const byte = harness.machine.read8(P10_OUTPUT + index);
    if (byte === 0) break;
    bytes.push(byte);
  }
  return String.fromCharCode(...bytes);
}

function runProgram(lines, frames = 100) {
  const harness = Free85Harness.boot();
  writeProgram(harness, 0, lines, "TEST");
  tapAll(harness, ["PRGM", "F3"]);
  harness.runFrames(frames);
  return harness;
}

test("[program.lifecycle] programs can be created, edited, renamed, persisted, and deleted", () => {
  const harness = Free85Harness.boot();
  harness.tap("PRGM");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_PROGRAM_LIST);
  assertLcdGolden("phase10-program-list", harness.machine.renderLcdBitmap());

  harness.tap("F1");
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_PROGRAM_EDIT);
  assertLcdGolden("phase10-program-editor", harness.machine.renderLcdBitmap());
  typeProgramText(harness, "DISP 4");
  harness.tap("F1");
  assert.equal(harness.machine.read8(P10_DATA), 6);
  harness.tap("F5");

  harness.tap("F4");
  harness.tap("CLEAR");
  typeProgramText(harness, "TEST");
  harness.tap("ENTER");
  assert.equal(String.fromCharCode(...Array.from({ length: 4 }, (_, index) => harness.machine.read8(P10_NAMES + index))), "TEST");

  harness.machine.reset();
  harness.runFrames(FREE85_BOOT_FRAMES);
  assert.equal(harness.machine.read8(P10_EXISTS), 1);
  assert.equal(harness.machine.read8(P10_DATA), 6);
  tapAll(harness, ["PRGM", "F5"]);
  assert.equal(harness.machine.read8(P10_EXISTS), 0);
});

test("[program.expressions] assignments, shared scientific expressions, and Disp execute", () => {
  const harness = runProgram(["2+3->A", "DISP SIN(0)+A", "STOP"]);
  assert.equal(harness.machine.read8(P10_ERROR), 0);
  assert.equal(output(harness), "5");
  assert.equal(harness.packedNumber(VARIABLES), 5);
});

test("[program.control-flow] If/Else, While, and For execute with bounded nesting", () => {
  const conditional = runProgram(["0->A", "IF A", "DISP 1", "ELSE", "DISP 2", "END", "STOP"]);
  assert.equal(output(conditional), "2");
  assert.equal(conditional.machine.read8(P10_ERROR), 0);

  const loop = runProgram(["3->A", "WHILE A", "A-1->A", "END", "DISP A", "STOP"]);
  assert.equal(output(loop), "0");
  assert.equal(loop.packedNumber(VARIABLES), 0);

  const counted = runProgram(["FOR A,1,3", "DISP A", "END", "STOP"]);
  assert.equal(output(counted), "3");
  assert.equal(counted.packedNumber(VARIABLES), 3);
});

test("[program.input] Input pauses execution and resumes through the numeric editor", () => {
  const harness = Free85Harness.boot();
  writeProgram(harness, 0, ["INPUT A", "DISP A*2", "STOP"]);
  tapAll(harness, ["PRGM", "F3"]);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_PROGRAM_INPUT);
  assertLcdGolden("phase10-program-input", harness.machine.renderLcdBitmap());
  tapAll(harness, ["6", "ENTER"]);
  harness.runFrames(20);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_PROGRAM_RUN);
  assert.equal(output(harness), "12");
});

test("[program.data-and-calls] program calls and list/matrix access share calculator objects", () => {
  const harness = Free85Harness.boot();
  writeProgram(harness, 0, ["CALL 2", "LSET 2,A", "LGET 2,B", "MSET 2,3,9", "MGET 2,3,C", "DISP B+C", "STOP"]);
  writeProgram(harness, 1, ["7->A", "RETURN"]);
  tapAll(harness, ["PRGM", "F3"]);
  harness.runFrames(100);
  assert.equal(output(harness), "16");
  assert.equal(harness.packedNumber(VARIABLES + 9), 7);
  assert.equal(harness.packedNumber(VARIABLES + 18), 9);
  assert.equal(harness.packedNumber(0x8781 + 9), 7);
  assert.equal(harness.packedNumber(0x8902 + 5 * 9), 9);
});

test("[program.graph] GRAPH evaluates through the shared expression engine and opens the graph", () => {
  const harness = runProgram(["GRAPH 5*SIN(X)"], 5);
  assert.equal(harness.machine.read8(FREE85_UI_MODE_ADDRESS), SCREEN_GRAPH);
  assert.equal(harness.machine.read8(0x8510), 8);
});

test("[program.stop] ON stops a runaway program without resetting persistent source", () => {
  const harness = Free85Harness.boot();
  writeProgram(harness, 0, ["WHILE 1", "END"]);
  tapAll(harness, ["PRGM", "F3"]);
  harness.runFrames(40);
  assert.equal(harness.machine.read8(P10_RUNNING), 1);
  harness.tap("ON");
  assert.equal(harness.machine.read8(P10_RUNNING), 0);
  assert.equal(harness.machine.read8(P10_ERROR), 5);
  assert.equal(harness.machine.read8(P10_EXISTS), 1);
});

test("[program.errors] runtime syntax failures identify the source line", () => {
  const harness = runProgram(["1->A", "NOT A COMMAND", "STOP"]);
  assert.equal(harness.machine.read8(P10_RUNNING), 0);
  assert.equal(harness.machine.read8(P10_ERROR), 1);
  assert.equal(harness.machine.read8(P10_ERROR_LINE), 2);
  assert.match(harness.editorText(), /NOT A COMMAND/);
  assertLcdGolden("phase10-program-error", harness.machine.renderLcdBitmap());
});
