import assert from "node:assert/strict";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";

const P7_ACTIVE_SET = 0x8703;
const P7_SELECTED = 0x8702;
const P7_COORD_MODE = 0x8707;
const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_ERROR = 0x9506;
const P10_OUTPUT = 0x9be0;

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

function writeProgram(harness, lines) {
  harness.machine.write8(P10_EXISTS, 1);
  [..."TEST"].forEach((character, index) => harness.machine.write8(P10_NAMES + index, character.charCodeAt(0)));
  lines.forEach((line, lineIndex) => {
    const address = P10_DATA + lineIndex * P10_LINE_SIZE;
    harness.machine.write8(address, line.length);
    [...line].forEach((character, index) => harness.machine.write8(address + 1 + index, character.charCodeAt(0)));
  });
}

function runProgram(lines, frames = 400) {
  const harness = Free85Harness.boot();
  writeProgram(harness, lines);
  harness.tap("PRGM");
  harness.tap("F3");
  harness.runFrames(frames);
  return harness;
}

function output(harness) {
  const bytes = [];
  for (let index = 0; index < 24; index += 1) {
    const byte = harness.machine.read8(P10_OUTPUT + index);
    if (!byte) break;
    bytes.push(byte);
  }
  return String.fromCharCode(...bytes);
}

test("[phase15.result-chaining] ENTER copies complete complex, list, matrix, and vector results into A", () => {
  const cases = [
    { keys: ["2ND", "9"], result: 0x8744, input: 0x8720, header: [], values: [3, -4] },
    { keys: ["2ND", "-"], result: 0x8880, input: 0x8780, header: [3], values: [1, 2, 3], imagResult: 0xf890, imagInput: 0xf800 },
    { keys: ["2ND", "7"], result: 0x8a00, input: 0x8900, header: [2, 3], values: [1, 2, 3, 4, 5, 6], imagResult: 0xf97a, imagInput: 0xf8d8 },
    { keys: ["2ND", "8"], result: 0x8b80, input: 0x8b00, header: [3], values: [7, 8, 9], imagResult: 0xfa52, imagInput: 0xfa1c }
  ];

  for (const entry of cases) {
    const harness = Free85Harness.boot();
    for (const key of entry.keys) harness.tap(key);
    entry.header.forEach((byte, index) => harness.machine.write8(entry.result + index, byte));
    entry.values.forEach((value, index) => writeNumber(harness, entry.result + entry.header.length + index * 9, value));
    if (entry.imagResult) entry.values.forEach((value, index) => writeNumber(harness, entry.imagResult + index * 9, -value / 10));
    harness.machine.write8(P7_SELECTED, Math.max(0, entry.values.length - 1));
    harness.machine.write8(P7_ACTIVE_SET, 2);
    harness.machine.write8(P7_COORD_MODE, 2);
    harness.tap("ENTER");

    assert.equal(harness.machine.read8(P7_ACTIVE_SET), 0);
    assert.equal(harness.machine.read8(P7_SELECTED), 0);
    assert.equal(harness.machine.read8(P7_COORD_MODE), 2, "coordinate metadata is preserved");
    entry.header.forEach((byte, index) => assert.equal(harness.machine.read8(entry.input + index), byte));
    entry.values.forEach((value, index) => assert.equal(harness.packedNumber(entry.input + entry.header.length + index * 9), value));
    if (entry.imagInput) entry.values.forEach((value, index) => assert.ok(
      Math.abs(harness.packedNumber(entry.imagInput + index * 9) + value / 10) < 1e-12
    ));
  }
});

test("[phase15.result-chaining-capacity] invalid result shape leaves input A unchanged", () => {
  const harness = Free85Harness.boot();
  harness.tap("2ND");
  harness.tap("-");
  writeNumber(harness, 0x8781, 42);
  harness.machine.write8(0x8880, 9);
  harness.machine.write8(P7_ACTIVE_SET, 2);
  harness.tap("ENTER");
  assert.equal(harness.machine.read8(0x8705), 1);
  assert.equal(harness.machine.read8(0x8780), 4);
  assert.equal(harness.packedNumber(0x8781), 42);
});

test("[phase15.program-for] FOR evaluates expression bounds, nested commas, and an optional step", () => {
  const harness = runProgram(["FOR A,1+1,NCR(5,2)+2,2", "DISP A", "END", "STOP"]);
  assert.equal(harness.machine.read8(P10_ERROR), 0);
  assert.equal(output(harness), "12");

  const nested = runProgram(["FOR A,1,2", "FOR B,2,4,2", "DISP A*10+B", "END", "END", "STOP"]);
  assert.equal(nested.machine.read8(P10_ERROR), 0);
  assert.equal(output(nested), "24");
});

test("[phase15.program-for-direction] descending and empty ranges terminate inclusively", () => {
  const descending = runProgram(["FOR A,6,0,-2", "DISP A", "END", "STOP"]);
  assert.equal(descending.machine.read8(P10_ERROR), 0);
  assert.equal(output(descending), "0");

  for (const source of ["FOR A,5,1", "FOR A,1,5,-1"]) {
    const empty = runProgram([source, "DISP 1", "END", "DISP 9", "STOP"]);
    assert.equal(empty.machine.read8(P10_ERROR), 0, source);
    assert.equal(output(empty), "9", source);
  }
});

test("[phase15.program-for-errors] noninteger bounds and a zero step fail with a domain error", () => {
  for (const source of ["FOR A,1,3,0", "FOR A,1.5,3", "FOR A,1,40000"]) {
    const harness = runProgram([source, "END", "STOP"]);
    assert.equal(harness.machine.read8(P10_ERROR), 8, source);
  }
});

test("[phase15.program-for-boundaries] signed overshoot terminates and long loops remain interruptible", () => {
  for (const [source, expected] of [
    ["FOR A,32760,32767,10", "32760"],
    ["FOR A,-32760,-32768,-10", "-32760"]
  ]) {
    const harness = runProgram([source, "DISP A", "END", "STOP"]);
    assert.equal(harness.machine.read8(P10_ERROR), 0, source);
    assert.equal(output(harness), expected, source);
  }

  const interrupted = runProgram(["FOR A,-32768,32767", "DISP A", "END", "STOP"], 10);
  interrupted.tap("ON");
  assert.equal(interrupted.machine.read8(P10_ERROR), 5);
});
