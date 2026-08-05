import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const readJson = (path) => readFile(path, "utf8").then(JSON.parse);

test("[phase17.roadmap] Free85 3.0 owns every approved capability exactly once", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const packages = new Map(roadmap.workPackages.map((entry) => [entry.id, entry]));
  const positions = new Map(roadmap.workPackages.map(({ id }, index) => [id, index]));
  const owned = roadmap.workPackages.flatMap(({ owns }) => owns)
    .filter((id) => !id.startsWith("release.") && id !== "workspace.migration-contract");
  const registered = ledger.capabilities.map(({ id }) => id);

  assert.equal(roadmap.release, "3.0.0");
  assert.equal(roadmap.umbrellaPhase, 17);
  assert.deepEqual([...owned].sort(), [...registered].sort());
  assert.equal(new Set(registered).size, registered.length);
  for (const workPackage of roadmap.workPackages) {
    assert.ok(["complete", "planned"].includes(workPackage.status), `${workPackage.id}: status`);
    assert.ok(workPackage.gates.length >= 3, `${workPackage.id}: gates`);
    for (const dependency of workPackage.dependsOn) {
      assert.ok(packages.has(dependency), `${workPackage.id}: unknown dependency ${dependency}`);
      assert.ok(positions.get(dependency) < positions.get(workPackage.id), `${workPackage.id}: dependency order`);
    }
  }
});

test("[phase17.1.completion] dev.1 closes the direct-window limitation and records book impact", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const impact = await readJson("spec/free85/v3-book-impact.yaml");
  const workPackage = roadmap.workPackages.find(({ id }) => id === "17.1");
  const capability = ledger.capabilities.find(({ id }) => id === "graph.window-editor");
  const bookChange = impact.changes.find(({ issue }) => issue === capability.id);
  assert.equal(workPackage.status, "complete");
  assert.equal(workPackage.release, "3.0.0-dev.1");
  assert.equal(capability.status, "resolved");
  assert.equal(capability.resolvedRelease, workPackage.release);
  assert.ok(capability.resolutionEvidence.length >= 3);
  assert.equal(bookChange.implementedIn, workPackage.release);
  assert.ok(bookChange.documents.length >= 4);
});

test("[phase17.2.completion] dev.2 closes picture overlays without mutating stored pictures", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const impact = await readJson("spec/free85/v3-book-impact.yaml");
  const workPackage = roadmap.workPackages.find(({ id }) => id === "17.2");
  const capability = ledger.capabilities.find(({ id }) => id === "graph.picture-overlay");
  const bookChange = impact.changes.find(({ issue }) => issue === capability.id);
  assert.equal(workPackage.status, "complete");
  assert.equal(workPackage.release, "3.0.0-dev.2");
  assert.equal(capability.status, "resolved");
  assert.equal(capability.resolvedRelease, workPackage.release);
  assert.ok(capability.resolutionEvidence.length >= 3);
  assert.equal(bookChange.implementedIn, workPackage.release);
  assert.ok(bookChange.documents.length >= 4);
});

test("[phase17.3.completion] dev.3 closes coupled DEQ and phase-plane limitations", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const impact = await readJson("spec/free85/v3-book-impact.yaml");
  const workPackage = roadmap.workPackages.find(({ id }) => id === "17.3");
  const capabilities = ledger.capabilities.filter(({ owner }) => owner === "17.3");
  const bookChange = impact.changes.find(({ implementedIn }) => implementedIn === workPackage.release);
  assert.equal(workPackage.status, "complete");
  assert.equal(workPackage.release, "3.0.0-dev.3");
  assert.deepEqual(capabilities.map(({ status }) => status), ["resolved", "resolved"]);
  assert.ok(capabilities.every(({ resolvedRelease }) => resolvedRelease === workPackage.release));
  assert.ok(capabilities.every(({ resolutionEvidence }) => resolutionEvidence.length >= 3));
  assert.match(bookChange.summaryForBooks, /dX\/dT/);
  assert.ok(bookChange.documents.length >= 4);
});

test("[phase17.4.completion] dev.4 closes the fixed matrix workspace and 3x3 ceiling", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const impact = await readJson("spec/free85/v3-book-impact.yaml");
  const workPackage = roadmap.workPackages.find(({ id }) => id === "17.4");
  const capabilities = ledger.capabilities.filter(({ owner }) => owner === "17.4");
  const bookChange = impact.changes.find(({ implementedIn }) => implementedIn === workPackage.release);
  assert.equal(workPackage.status, "complete");
  assert.equal(workPackage.release, "3.0.0-dev.4");
  assert.deepEqual(capabilities.map(({ status }) => status), ["resolved", "resolved"]);
  assert.ok(capabilities.every(({ resolvedRelease }) => resolvedRelease === workPackage.release));
  assert.ok(capabilities.every(({ resolutionEvidence }) => resolutionEvidence.length >= 3));
  assert.match(bookChange.summaryForBooks, /3x6/);
  assert.ok(bookChange.documents.length >= 4);
});

test("[phase17.versioning] development builds advance monotonically to one final 3.0", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const releases = roadmap.workPackages.flatMap(({ release }) => release ? [release] : []);
  assert.deepEqual(releases, [
    "3.0.0-dev.1",
    "3.0.0-dev.2",
    "3.0.0-dev.3",
    "3.0.0-dev.4",
    "3.0.0"
  ]);
  assert.equal(roadmap.workPackages.at(0).status, "complete");
  assert.deepEqual(roadmap.workPackages.at(-1).dependsOn, roadmap.workPackages.slice(0, -1).map(({ id }) => id));
});

test("[phase17.migration] the major-release boundary has transactional source and target schemas", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const architecture = roadmap.architecture;
  assert.equal(architecture.stateSchemaBaseline, 13);
  assert.equal(architecture.targetStateSchema, 14);
  assert.equal(architecture.objectStoreSchemaBaseline, 1);
  assert.equal(architecture.targetObjectStoreSchema, 2);
  assert.equal(architecture.targetGraphDatabaseVersion, 3);
  assert.ok(architecture.migrationSources.length >= 2);
  assert.match(architecture.rollbackRule, /leaves .* unchanged/);
});

test("[phase17.scope] the bounded expansion preserves the sandbox contract", async () => {
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const ids = ledger.capabilities.map(({ id }) => id);
  assert.deepEqual(ids.sort(), [
    "collections.matrix-3x6",
    "graph.diffeq-system",
    "graph.phase-plane",
    "graph.picture-overlay",
    "graph.window-editor",
    "workspace.dynamic-matrix"
  ]);
  for (const capability of ledger.capabilities) {
    assert.ok(["baseline-limitation", "in-progress", "resolved"].includes(capability.status), capability.id);
    assert.ok(capability.baselineEvidence.length >= 2, `${capability.id}: evidence`);
    assert.ok(capability.acceptance.length >= 3, `${capability.id}: acceptance`);
  }
});

test("[phase17.5.release] the stable 3.0 package closes every work package and editorial deferral", async () => {
  const roadmap = await readJson("spec/free85/v3-roadmap.yaml");
  const ledger = await readJson("spec/free85/v3-capabilities.yaml");
  const impact = await readJson("spec/free85/v3-book-impact.yaml");
  const packageJson = await readJson("package.json");
  const release = await readJson("spec/free85/release.json");
  const reproducibility = await readJson("spec/free85/reproducibility.json");
  assert.equal(packageJson.version, "3.0.0");
  assert.ok(roadmap.workPackages.every(({ status }) => status === "complete"));
  assert.ok(ledger.capabilities.every(({ status }) => status === "resolved"));
  assert.deepEqual(impact.stillPlanned, []);
  assert.equal(impact.changes.length, 4);
  assert.deepEqual({
    version: impact.releaseFreeze.version,
    stateSchema: impact.releaseFreeze.stateSchema,
    objectStoreSchema: impact.releaseFreeze.objectStoreSchema,
    graphDatabaseVersion: impact.releaseFreeze.graphDatabaseVersion
  }, { version: "3.0.0", stateSchema: 14, objectStoreSchema: 2, graphDatabaseVersion: 3 });
  assert.match(impact.releaseFreeze.romSha256, /^[0-9a-f]{64}$/);
  assert.match(impact.releaseFreeze.pagesSha256, /^[0-9a-f]{64}$/);
  assert.equal(impact.releaseFreeze.romSha256, release.rom.sha256);
  assert.equal(impact.releaseFreeze.pagesSha256, reproducibility.pages.sha256);
});
