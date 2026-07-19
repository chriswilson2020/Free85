import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { access, readFile } from "node:fs/promises";
import test from "node:test";

test("[release.bundle] the checked-in development ROM remains reproducible", async () => {
  const manifest = JSON.parse(await readFile("spec/free85/release.json", "utf8"));
  const rom = await readFile(manifest.rom.path);
  assert.equal(manifest.version, "1.0.0");
  assert.equal(manifest.phase, "14.1");
  assert.equal(manifest.target_release, "2.0.0");
  assert.equal(manifest.status, "development");
  assert.equal(manifest.license, "MIT");
  assert.equal(rom.length, 131072);
  assert.equal(createHash("sha256").update(rom).digest("hex"), manifest.rom.sha256);

  for (const path of [
    manifest.source,
    manifest.coverage_report,
    manifest.performance_report,
    manifest.known_limitations,
    ...manifest.notices
  ]) await access(path);
});

test("[release.coverage-performance] release reports retain all parity and timing gates", async () => {
  const coverage = JSON.parse(await readFile("spec/free85/coverage.json", "utf8"));
  const performance = JSON.parse(await readFile("spec/free85/performance.json", "utf8"));
  assert.equal(coverage.phase, "14.1");
  assert.equal(coverage.physical_keys.percent, 100);
  assert.equal(coverage.shifted_functions.percent, 100);
  assert.equal(coverage.alpha_mappings.percent, 100);
  assert.equal(coverage.features.complete_test_percent, 100);
  assert.equal(performance.phase, 12);
  assert.ok(performance.key_response.frames <= performance.limits.key_response_frames);
  for (const [name, limit] of Object.entries(performance.limits.evaluation_frames)) {
    assert.ok(performance.evaluation[name].frames <= limit, name);
  }
  for (const [name, limit] of Object.entries(performance.limits.graph_frames)) {
    assert.ok(performance.graph[name].frames <= limit, name);
  }
});

test("[release.browser-default] GitHub Pages boots only the bundled Free85 ROM by default", async () => {
  const [app, builder] = await Promise.all([
    readFile("public/ti85-app.js", "utf8"),
    readFile("scripts/build-pages.js", "utf8")
  ]);
  assert.match(app, /DEFAULT_ROM_URL = new URL\("\.\.\/ROM\/FREE85\.ROM"/);
  assert.doesNotMatch(app, /TI85\.ROM/);
  assert.match(builder, /ROM\/FREE85\.ROM/);
});
