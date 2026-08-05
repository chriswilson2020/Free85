import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";

const P10_EXISTS = 0x9510;
const P10_NAMES = 0x9520;
const P10_DATA = 0x9540;
const P10_LINE_SIZE = 49;
const P10_ERROR = 0x9506;
const P10_OUTPUT = 0x9be0;

function writeProgram(harness, lines) {
  harness.machine.write8(P10_EXISTS, 1);
  [..."HARDEN"].forEach((character, index) => harness.machine.write8(P10_NAMES + index, character.charCodeAt(0)));
  lines.forEach((line, lineIndex) => {
    const address = P10_DATA + lineIndex * P10_LINE_SIZE;
    harness.machine.write8(address, line.length);
    [...line].forEach((character, index) => harness.machine.write8(address + 1 + index, character.charCodeAt(0)));
  });
}

function runProgram(lines) {
  const harness = Free85Harness.boot();
  writeProgram(harness, lines);
  harness.tap("PRGM");
  harness.tap("F3");
  harness.runFrames(500);
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

test("[phase15.hardening-todos] every Phase 15 executable TODO is closed", async () => {
  const names = (await readdir("test/free85")).filter((name) => name.startsWith("phase15-") && name.endsWith(".test.js"));
  for (const name of names) {
    const source = await readFile(`test/free85/${name}`, "utf8");
    assert.doesNotMatch(source, /\btest\.(?:todo|skip)\s*\(/, name);
  }
});
test("[phase15.hardening-randomized] seeded signed FOR vectors match independent integer expectations", () => {
  let state = 0x85_15_06_20;
  const next = () => {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    return state;
  };

  for (let index = 0; index < 32; index += 1) {
    const start = (next() % 201) - 100;
    let step = (next() % 15) - 7;
    if (step === 0) step = 1;
    const advances = next() % 8;
    const end = start + step * advances;
    const harness = runProgram([`FOR A,(${start})+0,(${end})+0,${step}`, "DISP A", "END", "STOP"]);
    assert.equal(harness.machine.read8(P10_ERROR), 0, `vector ${index}`);
    assert.equal(output(harness), String(end), `vector ${index}`);
  }
});

test("[phase15.hardening-lanes] the 2.20 release command owns every required public and optional lane", async () => {
  const packageJson = JSON.parse(await readFile("package.json", "utf8"));
  const release = packageJson.scripts["release:free85"];
  for (const lane of [
    "build:free85",
    "coverage:free85",
    "update:free85:performance",
    "build:pages",
    "update:free85:reproducibility",
    "npm test",
    "test:free85:stress",
    "test:free85:soak",
    "test:free85:oracle"
  ]) assert.match(release, new RegExp(lane.replaceAll(":", "\\:")), lane);

  const phase15Tests = await Promise.all([
    "phase15-deq.test.js",
    "phase15-calculus.test.js",
    "phase15-workflows.test.js"
  ].map((name) => readFile(`test/free85/${name}`, "utf8")));
  assert.match(phase15Tests[0], /deq-migration/);
  assert.match(phase15Tests[1], /assertLcdGolden/);
  assert.match(phase15Tests[2], /result-chaining-capacity/);
});
