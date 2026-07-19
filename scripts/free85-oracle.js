import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { Ti85Machine } from "../src/ti85.js";
import { Free85Harness } from "../test/helpers/free85-harness.js";
import { bitmapToPbm, cellRows, readRightAlignedNumber } from "./free85-lcd-ocr.js";

const config = JSON.parse(await readFile("spec/free85/oracle-vectors.yaml", "utf8"));
const coverage = JSON.parse(await readFile("spec/free85/guidebook-coverage.yaml", "utf8"));
const romPath = process.env.TI85_ORACLE_ROM;
const full = process.argv.includes("--full");
const writePrivate = process.argv.includes("--write-private");
const outputDirectory = process.env.FREE85_ORACLE_OUTPUT ?? "oracle-results";

function tap(machine, key, holdFrames = 2, gapFrames = 2) {
  machine.pressKey(key);
  for (let index = 0; index < holdFrames; index += 1) machine.runFrame();
  machine.releaseKey(key);
  for (let index = 0; index < gapFrames; index += 1) machine.runFrame();
}

function expressionKeys(expression) {
  const keys = [];
  for (let index = 0; index < expression.length; index += 1) {
    const character = expression[index];
    const unary = character === "-" && (index === 0 || "+-*/^(".includes(expression[index - 1]));
    keys.push(unary ? "(-)" : character);
  }
  return keys;
}

function bootTi(path) {
  const machine = Ti85Machine.fromRomFile(path);
  for (let index = 0; index < 30; index += 1) machine.runFrame();
  tap(machine, "ON");
  for (let index = 0; index < 100; index += 1) machine.runFrame();
  tap(machine, "ENTER");
  return machine;
}

function lastRightAlignedRow(bitmap) {
  let selected = null;
  for (let row = 0; row < 8; row += 1) {
    const occupied = Array.from({ length: 21 }, (_, column) => ({
      column,
      rows: cellRows(bitmap, 1, 0, column, row)
    })).filter(({ rows }) => rows.some(Boolean));
    if (occupied.length && occupied.at(-1).column === 20 && occupied[0].column >= 8) selected = { row, occupied };
  }
  return selected;
}

function calibrationObservation(path, keys) {
  const machine = bootTi(path);
  for (const key of keys) tap(machine, key);
  tap(machine, "ENTER");
  for (let index = 0; index < 4; index += 1) machine.runFrame();
  const line = lastRightAlignedRow(machine.renderLcdBitmap());
  if (!line) throw new Error("Could not locate a right-aligned oracle result during runtime OCR calibration");
  return line;
}

function calibrateOracleOcr(path) {
  const hypotheses = {};
  for (const digit of "0123456789") {
    const line = calibrationObservation(path, [digit]);
    hypotheses[digit] = [line.occupied.at(-1).rows];
  }
  const negative = calibrationObservation(path, ["(-)", "1"]);
  hypotheses["-"] = [negative.occupied[0].rows];
  const decimal = calibrationObservation(path, ["1", "/", "2"]);
  hypotheses["."] = [decimal.occupied.at(-2).rows];
  return hypotheses;
}

function normalizeNumber(text) {
  if (!text) return NaN;
  return Number(text.replace(/\s/g, "").replace(/([0-9.])-([0-9]+)$/, "$1E-$2"));
}

function numericallyEqual(left, right) {
  const a = normalizeNumber(left);
  const b = normalizeNumber(right);
  if (!Number.isFinite(a) || !Number.isFinite(b)) return false;
  return Math.abs(a - b) <= 1e-10 * Math.max(1, Math.abs(a), Math.abs(b));
}

function makeRandomVectors(count) {
  let state = config.generated.seed >>> 0;
  const next = () => {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    return state;
  };
  const vectors = [];
  const [minimum, maximum] = config.generated.integerRange;
  const integer = () => minimum + (next() % (maximum - minimum + 1));
  for (let index = 0; index < count; index += 1) {
    let left = integer();
    let right = integer();
    const operator = config.generated.operators[index % config.generated.operators.length];
    if (operator === "/" && right === 0) right = 1;
    const expression = `${left}${operator}${right}`;
    const expected = operator === "+" ? left + right
      : operator === "-" ? left - right
        : operator === "*" ? left * right : left / right;
    vectors.push({ id: `generated-${String(index + 1).padStart(3, "0")}`, chapter: 3, topic: "seeded arithmetic", expression, expected: String(expected) });
  }
  return vectors;
}

function evaluateFree85(vector) {
  const harness = Free85Harness.boot();
  for (const key of expressionKeys(vector.expression)) harness.tap(key);
  const start = harness.machine.cpu.tStates;
  harness.tap("ENTER");
  let frames = 0;
  while (!harness.resultText() && frames < 200) {
    harness.machine.runFrame();
    frames += 1;
  }
  return { result: harness.resultText(), tstates: harness.machine.cpu.tStates - start, frames };
}

function evaluateTi(machine, vector, hypotheses) {
  tap(machine, "CLEAR");
  for (const key of expressionKeys(vector.expression)) tap(machine, key);
  const start = machine.cpu.tStates;
  tap(machine, "ENTER");
  for (let index = 0; index < 4; index += 1) machine.runFrame();
  const observation = readRightAlignedNumber(machine.renderLcdBitmap(), { hypotheses });
  return {
    result: observation?.value ?? null,
    ocrDistance: observation?.confidence ?? null,
    tstates: machine.cpu.tStates - start,
    frames: 8
  };
}

function guidebookSummary() {
  return Object.fromEntries(coverage.statuses.map((status) => [
    status,
    coverage.chapters.filter((entry) => entry.status === status).length
  ]));
}

if (!romPath || !existsSync(romPath)) {
  console.log("Free85 private oracle: SKIP (set TI85_ORACLE_ROM to a user-supplied 128 KiB ROM to enable it). ");
  process.exit(0);
}

const rom = await readFile(romPath);
if (rom.length !== Ti85Machine.ROM_SIZE) throw new Error(`Oracle ROM must be exactly ${Ti85Machine.ROM_SIZE} bytes`);
const fingerprint = createHash("sha256").update(rom).digest("hex");
const generatedCount = full ? config.generated.count : 32;
const vectors = [...config.fixed, ...makeRandomVectors(generatedCount)];
const oracleGlyphs = calibrateOracleOcr(romPath);
const machine = bootTi(romPath);
const results = [];

for (const vector of vectors) {
  const free85 = evaluateFree85(vector);
  const oracle = evaluateTi(machine, vector, oracleGlyphs);
  const expectedPass = numericallyEqual(free85.result, vector.expected);
  const oracleReadable = Number.isFinite(normalizeNumber(oracle.result));
  results.push({
    id: vector.id,
    chapter: vector.chapter,
    topic: vector.topic,
    expression: vector.expression,
    expected: vector.expected,
    free85,
    oracle,
    classification: !expectedPass ? "free85-regression"
      : !oracleReadable ? "oracle-observation-unreadable"
        : numericallyEqual(free85.result, oracle.result) ? "equivalent" : "intentional-or-unresolved-divergence"
  });
}

const stateResults = [];
for (const vector of config.stateVectors) {
  const stateMachine = bootTi(romPath);
  const before = stateMachine.renderLcdBitmap();
  for (const key of vector.keys) tap(stateMachine, key);
  const after = stateMachine.renderLcdBitmap();
  stateResults.push({
    id: vector.id,
    chapter: vector.chapter,
    assertion: vector.assertion,
    changed: before.checksum !== after.checksum,
    readable: after.enabled && after.litPixelCount > 10,
    classification: before.checksum !== after.checksum && after.enabled && after.litPixelCount > 10 ? "observed" : "needs-review"
  });
}

const counts = Object.fromEntries([...new Set(results.map(({ classification }) => classification))]
  .map((classification) => [classification, results.filter((item) => item.classification === classification).length]));
const report = {
  schemaVersion: 1,
  phase: 13,
  mode: full ? "full" : "quick",
  cleanRoom: true,
  rom: { size: rom.length, sha256: fingerprint },
  vectorCount: results.length,
  classifications: counts,
  guidebookCoverage: guidebookSummary(),
  results,
  stateResults
};

if (writePrivate) {
  await mkdir(outputDirectory, { recursive: true });
  await writeFile(`${outputDirectory}/oracle-report.json`, `${JSON.stringify(report, null, 2)}\n`);
  await writeFile(`${outputDirectory}/last-oracle-screen.pbm`, bitmapToPbm(machine.renderLcdBitmap()));
}

console.log(JSON.stringify({
  phase: report.phase,
  mode: report.mode,
  vectorCount: report.vectorCount,
  classifications: report.classifications,
  stateResults,
  guidebookCoverage: report.guidebookCoverage,
  privateArtifactsWritten: writePrivate
}, null, 2));

const regressions = results.filter(({ classification }) => classification === "free85-regression");
const unreadable = results.filter(({ classification }) => classification === "oracle-observation-unreadable");
if (regressions.length || unreadable.length) {
  throw new Error(`Oracle validation failed: ${regressions.length} Free85 regressions, ${unreadable.length} unreadable oracle observations`);
}
