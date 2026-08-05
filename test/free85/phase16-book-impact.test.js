import assert from "node:assert/strict";
import test from "node:test";
import { readFile } from "node:fs/promises";

const ledgerPath = "spec/free85/v2.21-book-impact.yaml";

test("[phase16.book-impact] the 2.21 ledger owns every shipped behavioural correction", async () => {
  const ledger = JSON.parse(await readFile(ledgerPath, "utf8"));
  assert.equal(ledger.firmwareTarget, "2.21.0");
  assert.equal(ledger.phase, "16");
  assert.equal(ledger.romSha256, "b714dd191c4182c294017f6fe19f1699db039c9579fc39eef1dd568afb05339d");
  assert.deepEqual(ledger.changes.map(({ issue }) => issue).sort(), [
    "collections.lu-permutation-storage",
    "collections.matrix-row-menu-fit",
    "numeric.general-power",
    "solver.simult-cell-coordinate"
  ]);
  for (const change of ledger.changes) {
    assert.ok(change.documents.length > 0, `${change.issue}: documents`);
    assert.ok(change.mustRemoveOrCorrect.length > 0, `${change.issue}: stale claims`);
    assert.ok(change.mustAdd.length > 0, `${change.issue}: replacement content`);
    assert.ok(change.evidence.length > 0, `${change.issue}: evidence`);
  }
  assert.ok(ledger.unchangedClaims.some((claim) => claim.includes("no direct four-field graph-window editor")));
  assert.ok(ledger.finalVerification.length >= 6);
});
