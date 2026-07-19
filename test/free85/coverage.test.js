import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { TI85_KEY_LAYOUT, TI85_KEY_ROWS } from "../../src/ti85-keys.js";
import {
  createFree85Coverage,
  readFree85Specifications,
  validateFree85Specifications
} from "../../scripts/free85-spec.js";

test("Free85 specifications register the complete physical keypad", async () => {
  const specifications = await readFree85Specifications();
  assert.deepEqual(validateFree85Specifications(specifications), []);

  const coverage = createFree85Coverage(specifications);
  assert.equal(TI85_KEY_LAYOUT.flat().length, 50);
  assert.equal(TI85_KEY_ROWS.flat().filter(Boolean).length, 49);
  assert.deepEqual(coverage.physical_keys, {
    total: 50,
    registered: 50,
    percent: 100,
    matrix: 49,
    special: 1
  });
  assert.equal(coverage.shifted_functions.registered, coverage.shifted_functions.total);
  assert.equal(coverage.shifted_functions.percent, 100);
  assert.equal(coverage.alpha_mappings.registered, coverage.alpha_mappings.total);
  assert.equal(coverage.alpha_mappings.percent, 100);
});

test("Free85 distinguishes tested surfaces from planned calculator features", async () => {
  const { keymap, features } = await readFree85Specifications();
  assert.equal(keymap.keys.every(({ status }) => status === "planned"), true);
  assert.equal(features.features.filter(({ status }) => status === "tested").length, 103);
  assert.equal(features.features.filter(({ status }) => status === "planned").length, 19);
  assert.equal(features.features.every(({ status }) => status === "planned" || status === "tested"), true);
  assert.equal(features.features.filter(({ status }) => status === "tested").every(({ implementation, tests }) => implementation && tests.length > 0), true);
  assert.equal(features.features.filter(({ status }) => status === "planned").every(({ implementation, tests }) => implementation === null && tests.length === 0), true);
});

test("checked-in Free85 coverage report matches its source specifications", async () => {
  const specifications = await readFree85Specifications();
  const checkedIn = JSON.parse(await readFile("spec/free85/coverage.json", "utf8"));
  assert.deepEqual(checkedIn, createFree85Coverage(specifications));
});

test("tested Free85 features reference stable test identifiers", async () => {
  const { features } = await readFree85Specifications();
  const testSources = await Promise.all([
    readFile("test/free85/keypad.test.js", "utf8"),
    readFile("test/free85/ui.test.js", "utf8"),
    readFile("test/free85/numeric.test.js", "utf8"),
    readFile("test/free85/expression.test.js", "utf8"),
    readFile("test/free85/scientific.test.js", "utf8"),
    readFile("test/free85/graph.test.js", "utf8"),
    readFile("test/free85/collections.test.js", "utf8"),
    readFile("test/free85/statistics-solvers.test.js", "utf8"),
    readFile("test/free85/strings-catalog-custom.test.js", "utf8"),
    readFile("test/free85/programming.test.js", "utf8")
  ]);
  const combined = testSources.join("\n");
  const referenced = new Set(features.features.flatMap(({ tests }) => tests));
  for (const id of referenced) assert.match(combined, new RegExp(`\\[${id.replaceAll(".", "\\.")}\\]`));
});
