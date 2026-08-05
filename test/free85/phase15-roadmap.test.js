import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const readJson = (path) => readFile(path, "utf8").then(JSON.parse);

test("[phase15.roadmap] every quality issue has one ordered work-package owner", async () => {
  const roadmap = await readJson("spec/free85/v2.20-roadmap.yaml");
  const quality = await readJson("spec/free85/numerical-quality.yaml");
  const packages = new Map(roadmap.workPackages.map((entry) => [entry.id, entry]));
  const positions = new Map(roadmap.workPackages.map(({ id }, index) => [id, index]));
  const owned = roadmap.workPackages.flatMap(({ owns }) => owns)
    .filter((id) => id !== "quality.contract" && id !== "release.2.20");
  const registered = quality.issues.map(({ id }) => id);

  assert.equal(roadmap.release, "2.20.0");
  assert.equal(roadmap.umbrellaPhase, 15);
  assert.deepEqual([...owned].sort(), [...registered].sort());
  assert.equal(new Set(registered).size, registered.length);

  for (const workPackage of roadmap.workPackages) {
    assert.ok(["complete", "planned"].includes(workPackage.status), `${workPackage.id}: invalid status`);
    assert.ok(workPackage.gates.length >= 3, `${workPackage.id}: insufficient gates`);
    for (const dependency of workPackage.dependsOn) {
      assert.ok(packages.has(dependency), `${workPackage.id}: unknown dependency ${dependency}`);
      assert.ok(positions.get(dependency) < positions.get(workPackage.id), `${workPackage.id}: dependency is not earlier`);
    }
  }
  assert.deepEqual(roadmap.workPackages.at(-1).dependsOn, roadmap.workPackages.slice(0, -1).map(({ id }) => id));
});

test("[phase15.quality] every limitation has evidence, acceptance criteria, and a release target", async () => {
  const roadmap = await readJson("spec/free85/v2.20-roadmap.yaml");
  const quality = await readJson("spec/free85/numerical-quality.yaml");
  const packages = new Map(roadmap.workPackages.map((entry) => [entry.id, entry]));

  assert.equal(quality.baselineRelease, "2.11.1");
  assert.equal(quality.targetRelease, "2.20.0");
  for (const issue of quality.issues) {
    assert.ok(quality.statuses.includes(issue.status), `${issue.id}: invalid status`);
    assert.ok(packages.get(issue.owner)?.owns.includes(issue.id), `${issue.id}: invalid owner`);
    assert.equal(issue.targetRelease, packages.get(issue.owner).release, `${issue.id}: release mismatch`);
    assert.ok(issue.summary.length > 30, `${issue.id}: summary too short`);
    assert.ok(issue.baselineEvidence.length >= 2, `${issue.id}: insufficient evidence`);
    assert.ok(issue.acceptance.length >= 3, `${issue.id}: insufficient acceptance criteria`);
    if (issue.status === "resolved") {
      assert.equal(issue.resolvedRelease, issue.targetRelease, `${issue.id}: wrong resolved release`);
      assert.ok(issue.resolutionEvidence.length >= 2, `${issue.id}: insufficient resolution evidence`);
    }
  }
});

test("[phase15.versioning] feature versions advance beyond 2.11 without becoming 3.0", async () => {
  const roadmap = await readJson("spec/free85/v2.20-roadmap.yaml");
  const releases = roadmap.workPackages.flatMap(({ release }) => release ? [release] : []);
  const minors = releases.map((release) => Number(release.split(".")[1]));
  assert.deepEqual(minors, [12, 14, 16, 18, 19, 20]);
  assert.equal(roadmap.deferred.find(({ id }) => id === "workspace.dynamic-capacity").target, "3.0.0");
});

test("[phase15.1.completion] 2.12 closes its two quality owners and records the book impact", async () => {
  const roadmap = await readJson("spec/free85/v2.20-roadmap.yaml");
  const quality = await readJson("spec/free85/numerical-quality.yaml");
  const impact = await readJson("spec/free85/v2.20-book-impact.yaml");
  const workPackage = roadmap.workPackages.find(({ id }) => id === "15.1");
  assert.equal(workPackage.status, "complete");
  assert.equal(workPackage.release, "2.12.0");
  for (const id of workPackage.owns) {
    const issue = quality.issues.find((entry) => entry.id === id);
    const bookChange = impact.changes.find((entry) => entry.issue === id);
    assert.equal(issue.status, "resolved", id);
    assert.equal(issue.resolvedRelease, "2.12.0", id);
    assert.equal(bookChange.implementedIn, "2.12.0", id);
  }
});

test("[phase15.books] every quality correction has an explicit deferred book revision", async () => {
  const quality = await readJson("spec/free85/numerical-quality.yaml");
  const impact = await readJson("spec/free85/v2.20-book-impact.yaml");
  const qualityIds = quality.issues.map(({ id }) => id).sort();
  const impactIds = impact.changes.map(({ issue }) => issue).sort();

  assert.equal(impact.firmwareTarget, "2.20.0");
  assert.deepEqual(impactIds, qualityIds);
  assert.equal(new Set(impactIds).size, impactIds.length);
  assert.ok(impact.rules.length >= 5);
  assert.ok(impact.finalVerification.length >= 5);

  const paths = new Set();
  for (const change of impact.changes) {
    assert.ok(change.summaryForBooks.length > 50, `${change.issue}: summary is not editorially useful`);
    assert.ok(change.documents.length >= 2, `${change.issue}: too few affected documents`);
    assert.ok(change.mustRemoveOrCorrect.length >= 2, `${change.issue}: stale claims are not identified`);
    assert.ok(change.mustAdd.length >= 2, `${change.issue}: replacement material is not identified`);
    for (const document of change.documents) paths.add(document.path);
  }

  for (const path of paths) {
    const stat = await import("node:fs/promises").then(({ stat }) => stat(path));
    assert.ok(stat.isFile() || stat.isDirectory(), `${path}: missing book source`);
  }
});
