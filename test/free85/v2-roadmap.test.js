import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

async function readJson(path) {
  return JSON.parse(await readFile(path, "utf8"));
}

test("[v2.roadmap] every parity gap has exactly one work-package owner", async () => {
  const roadmap = await readJson("spec/free85/v2-roadmap.yaml");
  const ledger = await readJson("spec/free85/v2-parity-gaps.yaml");
  const packages = new Map(roadmap.workPackages.map((entry) => [entry.id, entry]));
  const declared = new Set(roadmap.workPackages.flatMap(({ owns }) => owns));
  const registered = new Set(ledger.gaps.map(({ id }) => id));
  assert.equal(roadmap.release, "2.0.0");
  assert.equal(roadmap.umbrellaPhase, 14);
  assert.equal(new Set(ledger.gaps.map(({ id }) => id)).size, ledger.gaps.length);
  assert.deepEqual([...declared].sort(), [...registered].sort());
  for (const gap of ledger.gaps) {
    assert.equal(ledger.statuses.includes(gap.status), true, `${gap.id}: invalid status`);
    assert.equal(packages.has(gap.owner), true, `${gap.id}: missing owner ${gap.owner}`);
    assert.equal(packages.get(gap.owner).owns.includes(gap.id), true, `${gap.id}: not declared by ${gap.owner}`);
    assert.equal(gap.target.length > 10, true, `${gap.id}: target is not concrete`);
  }
});

test("[v2.roadmap] package dependencies are ordered and release hardening owns every dependency", async () => {
  const roadmap = await readJson("spec/free85/v2-roadmap.yaml");
  const position = new Map(roadmap.workPackages.map(({ id }, index) => [id, index]));
  for (const entry of roadmap.workPackages) {
    assert.equal(entry.gates.length >= 3, true, `${entry.id}: insufficient gates`);
    for (const dependency of entry.dependsOn) {
      assert.equal(position.has(dependency), true, `${entry.id}: unknown dependency ${dependency}`);
      assert.equal(position.get(dependency) < position.get(entry.id), true, `${entry.id}: dependency is not earlier`);
    }
  }
  const release = roadmap.workPackages.at(-1);
  assert.equal(release.id, "14.10");
  assert.deepEqual(release.dependsOn, roadmap.workPackages.slice(0, -1).map(({ id }) => id));
});
