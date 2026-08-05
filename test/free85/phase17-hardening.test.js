import assert from "node:assert/strict";
import { readFile, readdir } from "node:fs/promises";
import test from "node:test";
import { Free85Harness } from "../helpers/free85-harness.js";

const MATRIX_A = 0xf2e0;
const MATRIX_B = 0xf384;
const MATRIX_R = 0xf428;

function packed(value) {
  if (value === 0) return Uint8Array.of(0, 0, 0, 0, 0, 0, 0, 0, 0);
  const sign = value < 0 ? 0x80 : 0;
  const magnitude = Math.abs(value);
  const exponent = Math.floor(Math.log10(magnitude));
  const digits = (magnitude / (10 ** exponent)).toPrecision(14).replace(".", "").slice(0, 14);
  return Uint8Array.of(sign, exponent < 0 ? exponent + 256 : exponent,
    ...Array.from({ length: 7 }, (_, index) => (Number(digits[index * 2]) << 4) | Number(digits[index * 2 + 1])));
}

function writeMatrix(harness, base, rows, cols, values) {
  harness.machine.write8(base, rows);
  harness.machine.write8(base + 1, cols);
  values.forEach((value, index) => {
    packed(value).forEach((byte, offset) => harness.machine.write8(base + 2 + index * 9 + offset, byte));
  });
}

function readMatrix(harness, base) {
  const rows = harness.machine.read8(base);
  const cols = harness.machine.read8(base + 1);
  return {
    rows,
    cols,
    values: Array.from({ length: rows * cols }, (_, index) => harness.packedNumber(base + 2 + index * 9))
  };
}

function multiply(left, right, rows, shared, cols) {
  return Array.from({ length: rows * cols }, (_, index) => {
    const row = Math.floor(index / cols);
    const col = index % cols;
    let value = 0;
    for (let inner = 0; inner < shared; inner += 1) {
      value += left[row * shared + inner] * right[inner * cols + col];
    }
    return value;
  });
}

test("[phase17.5.probes] every Phase 17 executable probe is an ordinary passing test", async () => {
  const names = (await readdir("test/free85"))
    .filter((name) => name.startsWith("phase17-") && name.endsWith(".test.js"));
  for (const name of names) {
    const source = await readFile(`test/free85/${name}`, "utf8");
    assert.doesNotMatch(source, /\btest\.(?:todo|skip)\s*\(/, name);
  }
});

test("[phase17.5.randomized] seeded rectangular products match independent integer arithmetic", () => {
  let state = 0x85_17_05_30;
  const next = () => {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    return state;
  };

  for (let vector = 0; vector < 12; vector += 1) {
    const rows = 1 + (next() % 3);
    const shared = 1 + (next() % 3);
    const cols = 1 + (next() % 6);
    const left = Array.from({ length: rows * shared }, () => (next() % 7) - 3);
    const right = Array.from({ length: shared * cols }, () => (next() % 7) - 3);
    const harness = Free85Harness.boot();
    writeMatrix(harness, MATRIX_A, rows, shared, left);
    writeMatrix(harness, MATRIX_B, shared, cols, right);
    harness.tap("2ND");
    harness.tap("7");
    harness.tap("MORE");
    harness.tap("F3");
    harness.runFrames(1200);
    assert.deepEqual(readMatrix(harness, MATRIX_R), {
      rows,
      cols,
      values: multiply(left, right, rows, shared, cols)
    }, `seeded vector ${vector}`);
  }
});

test("[phase17.5.lanes] stable 3.0 owns all public, reproducibility, and optional release lanes", async () => {
  const packageJson = JSON.parse(await readFile("package.json", "utf8"));
  const release = packageJson.scripts["release:free85"];
  assert.equal(packageJson.version, "3.0.0");
  for (const lane of [
    "build:free85",
    "coverage:free85",
    "update:free85:performance",
    "build:pages",
    "update:free85:reproducibility",
    "update:free85:release",
    "npm test",
    "test:free85:stress",
    "test:free85:soak",
    "test:free85:oracle"
  ]) assert.match(release, new RegExp(lane.replaceAll(":", "\\:")), lane);

  const migration = await readFile("test/free85/object-store.test.js", "utf8");
  const matrix = await readFile("test/free85/phase17-matrix-3x6.test.js", "utf8");
  assert.match(migration, /phase17\.5\.corruption/);
  assert.match(migration, /phase17\.4\.rollback/);
  assert.match(matrix, /assertLcdGolden/);
});
