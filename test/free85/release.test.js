import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { access, readFile } from "node:fs/promises";
import test from "node:test";

test("[release.bundle] the stable 2.14 ROM is bound to frozen schemas and reproducibility evidence", async () => {
  const manifest = JSON.parse(await readFile("spec/free85/release.json", "utf8"));
  const rom = await readFile(manifest.rom.path);
  const reproducibility = JSON.parse(await readFile(manifest.reproducibility_report, "utf8"));
  assert.equal(manifest.schema_version, 2);
  assert.equal(manifest.version, "2.14.0");
  assert.equal(manifest.phase, "15.2");
  assert.equal(manifest.target_release, "2.14.0");
  assert.equal(manifest.status, "stable");
  assert.equal(manifest.license, "MIT");
  assert.deepEqual(manifest.persistent_ram, {
    schema: 13,
    status: "frozen",
    migrates_from: [12],
    object_store_schema: 1
  });
  assert.equal(rom.length, 131072);
  assert.equal(createHash("sha256").update(rom).digest("hex"), manifest.rom.sha256);
  assert.equal(reproducibility.rom.sha256, manifest.rom.sha256);
  assert.equal(reproducibility.independent_builds, 2);
  assert.equal(reproducibility.pages.files > 0, true);
  assert.match(reproducibility.pages.sha256, /^[0-9a-f]{64}$/);

  for (const path of [
    manifest.source,
    manifest.coverage_report,
    manifest.performance_report,
    manifest.parity_report,
    manifest.reproducibility_report,
    manifest.release_notes,
    manifest.known_limitations,
    ...manifest.notices
  ]) await access(path);
});

test("[release.coverage-performance] release reports retain all parity and timing gates", async () => {
  const coverage = JSON.parse(await readFile("spec/free85/coverage.json", "utf8"));
  const performance = JSON.parse(await readFile("spec/free85/performance.json", "utf8"));
  assert.equal(coverage.phase, "14.10");
  assert.equal(coverage.physical_keys.percent, 100);
  assert.equal(coverage.shifted_functions.percent, 100);
  assert.equal(coverage.alpha_mappings.percent, 100);
  assert.equal(coverage.features.complete_test_percent, 100);
  assert.equal(performance.phase, "15.2");
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

test("[release.browser-docs] Pages embeds self-contained books without replacing the calculator", async () => {
  const manualPath = "public/guidebook/Free85-Manual-typeset.html";
  const guidebookPath = "public/guidebook/Free85-Guidebook-typeset.html";
  const [index, app, manual, guidebook] = await Promise.all([
    readFile("index.html", "utf8"),
    readFile("public/ti85-app.js", "utf8"),
    readFile(manualPath, "utf8"),
    readFile(guidebookPath, "utf8")
  ]);
  assert.match(index, /id="ti85DocReader"/);
  assert.match(index, /id="ti85DocFrame"/);
  assert.match(index, /id="ti85DocHandle"/);
  assert.match(index, /data-doc-book="manual"/);
  assert.match(index, /data-doc-book="guidebook"/);
  assert.match(app, /function openDocumentation\(book\)/);
  assert.match(app, /classList\.add\("docs-parked"\)/);
  assert.match(app, /openDocumentation\(activeDocumentation\)/);
  assert.match(app, /docFrame\.src = embeddedUrl/);
  assert.match(app, /docFrame\.dataset\.docBook !== book/);
  assert.match(app, /docFrame\.dataset\.docBook = book/);
  assert.doesNotMatch(app, /docFrame\.src\s*=\s*["']{2}/);
  assert.doesNotMatch(app, /window\.location\s*=/);
  assert.match(manual, /<title>Free85 Getting Started Manual \(typeset\)<\/title>/);
  assert.match(guidebook, /<title>The Free85 Guidebook \(typeset\)<\/title>/);
  for (const html of [manual, guidebook]) {
    assert.match(html, /aria-label="Book navigation"/);
    assert.match(html, /href="\.\.\/\.\.\/index\.html"/);
    assert.match(html, /embedded-reader/);
    assert.doesNotMatch(html, /Paged\.registerHandlers/);
  }
});
