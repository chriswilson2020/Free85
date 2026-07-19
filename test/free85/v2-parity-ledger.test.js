import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { spawnSync } from "node:child_process";
import test from "node:test";

const readJson = (path) => readFile(path, "utf8").then(JSON.parse);

test("[v2.ledger] checked-in command-level parity report is current", () => {
  const result = spawnSync(process.execPath, ["scripts/free85-v2-parity.js", "--check"], { encoding: "utf8" });
  assert.equal(result.status, 0, result.stderr);
});

test("[v2.ledger] every inventoried item is unique and conservatively classified", async () => {
  const ledger = await readJson("spec/free85/guidebook-command-ledger.yaml");
  const items = ledger.groups.flatMap((group) => group.items.map((item) => String(item).toLowerCase()));
  assert.equal(new Set(items).size, items.length);
  assert.equal(items.length >= 250, true);
  for (const group of ledger.groups) {
    assert.equal(ledger.statuses.includes(group.status), true, group.id);
    if (group.status === "equivalent") assert.equal(group.evidence.length > 0, true, group.id);
    if (["partial", "missing", "hardware-dependent"].includes(group.status)) {
      assert.equal(Boolean(group.owner), true, group.id);
      assert.equal(Boolean(group.target), true, group.id);
    }
  }
});

test("[v2.ledger] chapter summary no longer overstates broad equivalence", async () => {
  const coverage = await readJson("spec/free85/guidebook-coverage.yaml");
  assert.equal(coverage.chapters.filter(({ chapter }) => Number.isInteger(chapter)).length, 19);
  assert.equal(coverage.chapters.some(({ status }) => status === "missing"), true);
  assert.equal(coverage.chapters.some(({ status }) => status === "partial"), true);
  assert.equal(coverage.chapters.filter(({ status }) => status === "equivalent").length, 0);
});

test("[v2.progress] Phase 14.1 closes the storage foundation without hiding remaining work", async () => {
  const report = await readJson("spec/free85/v2-parity-report.json");
  assert.equal(report.phase, "14.1");
  assert.equal(report.inventory.entries >= 250, true);
  assert.equal(report.gaps.total, 36);
  assert.equal(report.gaps.byStatus.equivalent, 4);
  assert.equal(report.gaps.equivalentPercent, 11.11);
  assert.equal(report.cleanRoom.proprietaryInputsRequiredForPublicValidation, false);
});
