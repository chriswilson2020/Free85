import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import test from "node:test";

test("[oracle.package] vector catalog is deterministic and broad", async () => {
  const catalog = JSON.parse(await readFile("spec/free85/oracle-vectors.yaml", "utf8"));
  assert.equal(catalog.fixed.length >= 12, true);
  assert.equal(catalog.generated.count >= 256, true);
  assert.deepEqual(catalog.generated.operators, ["+", "-", "*", "/"]);
  assert.equal(new Set(catalog.fixed.map(({ id }) => id)).size, catalog.fixed.length);
  assert.equal(catalog.stateVectors.length >= 5, true);
});

test("[oracle.guidebook] every guidebook chapter has a classified disposition", async () => {
  const coverage = JSON.parse(await readFile("spec/free85/guidebook-coverage.yaml", "utf8"));
  const numbered = coverage.chapters.filter(({ chapter }) => Number.isInteger(chapter));
  assert.deepEqual(numbered.map(({ chapter }) => chapter), Array.from({ length: 19 }, (_, index) => index + 1));
  for (const entry of coverage.chapters) {
    assert.equal(coverage.statuses.includes(entry.status), true, `${entry.chapter}: ${entry.status}`);
    assert.equal(Boolean(entry.evidence?.length || entry.reason), true, `${entry.chapter} lacks evidence/reason`);
  }
});

test("[oracle.optional] private lane skips cleanly when no ROM is supplied", () => {
  const environment = { ...process.env };
  delete environment.TI85_ORACLE_ROM;
  const result = spawnSync(process.execPath, ["scripts/free85-oracle.js"], { encoding: "utf8", env: environment });
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /SKIP/);
});

test("[oracle.safety] proprietary inputs and private captures are ignored", async () => {
  const ignore = await readFile(".gitignore", "utf8");
  assert.match(ignore, /^TI85\.ROM$/m);
  assert.match(ignore, /^oracle-results\/$/m);
  const documentation = await readFile("docs/oracle-validation.md", "utf8");
  assert.match(documentation, /Never commit a TI ROM/);
});

test("[oracle.report] checked-in Phase 13 observation is internally consistent", async () => {
  const report = JSON.parse(await readFile("spec/free85/oracle-report.json", "utf8"));
  assert.equal(report.phase, 13);
  assert.equal(report.oracleRom.contentsRetained, false);
  assert.equal(report.differential.equivalent, report.differential.numericVectors);
  assert.equal(report.differential.free85Regressions, 0);
  assert.equal(report.differential.applicationStateProbesPassed, report.differential.applicationStateProbes);
  assert.equal(report.publicValidation.passed, report.publicValidation.tests);
});
