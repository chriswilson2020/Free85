import { readFile, writeFile } from "node:fs/promises";

const ledgerPath = "spec/free85/guidebook-command-ledger.yaml";
const gapsPath = "spec/free85/v2-parity-gaps.yaml";
const roadmapPath = "spec/free85/v2-roadmap.yaml";
const reportPath = "spec/free85/v2-parity-report.json";

const [ledger, gapLedger, roadmap] = await Promise.all([
  readFile(ledgerPath, "utf8").then(JSON.parse),
  readFile(gapsPath, "utf8").then(JSON.parse),
  readFile(roadmapPath, "utf8").then(JSON.parse)
]);

const failures = [];
const gapById = new Map(gapLedger.gaps.map((gap) => [gap.id, gap]));
const packageById = new Map(roadmap.workPackages.map((entry) => [entry.id, entry]));
const groupIds = new Set();
const itemOwners = new Map();

for (const group of ledger.groups) {
  if (groupIds.has(group.id)) failures.push(`duplicate group id: ${group.id}`);
  groupIds.add(group.id);
  if (!ledger.statuses.includes(group.status)) failures.push(`${group.id}: invalid status ${group.status}`);
  if (!Array.isArray(group.items) || group.items.length === 0) failures.push(`${group.id}: no inventory items`);
  if (group.status === "equivalent" && !group.evidence?.length) failures.push(`${group.id}: equivalent without evidence`);
  if (["partial", "missing", "hardware-dependent"].includes(group.status)) {
    if (!group.owner || !gapById.has(group.owner)) failures.push(`${group.id}: missing registered gap owner`);
    if (!group.target) failures.push(`${group.id}: missing completion target`);
  }
  if (group.status === "excluded-clean-room" && !group.reason) failures.push(`${group.id}: exclusion lacks reason`);
  for (const item of group.items ?? []) {
    const key = String(item).toLowerCase();
    if (itemOwners.has(key)) failures.push(`${group.id}: duplicate item ${item} already owned by ${itemOwners.get(key)}`);
    itemOwners.set(key, group.id);
  }
}

for (const gap of gapLedger.gaps) {
  if (!packageById.has(gap.owner)) failures.push(`${gap.id}: unknown work package ${gap.owner}`);
}

if (failures.length) throw new Error(`Free85 2.0 parity ledger invalid:\n- ${failures.join("\n- ")}`);

const countBy = (values, key) => Object.fromEntries(values.map((value) => [
  value,
  key.filter((entry) => entry.status === value).length
]));
const entriesByStatus = Object.fromEntries(ledger.statuses.map((status) => [
  status,
  ledger.groups.filter((group) => group.status === status).reduce((sum, group) => sum + group.items.length, 0)
]));
const gapStatuses = [...new Set(gapLedger.gaps.map(({ status }) => status))];

const report = {
  schemaVersion: 1,
  release: roadmap.release,
  phase: "14.5",
  inventory: {
    groups: ledger.groups.length,
    entries: itemOwners.size,
    groupsByStatus: countBy(ledger.statuses, ledger.groups),
    entriesByStatus
  },
  gaps: {
    total: gapLedger.gaps.length,
    byStatus: countBy(gapStatuses, gapLedger.gaps),
    equivalentPercent: Number(((gapLedger.gaps.filter(({ status }) => status === "equivalent").length / gapLedger.gaps.length) * 100).toFixed(2))
  },
  workPackages: roadmap.workPackages.map((workPackage) => ({
    id: workPackage.id,
    name: workPackage.name,
    gaps: gapLedger.gaps.filter(({ owner }) => owner === workPackage.id).map(({ id, status }) => ({ id, status }))
  })),
  cleanRoom: {
    proprietaryInputsRequiredForPublicValidation: false,
    exclusions: ledger.groups.find(({ id }) => id === "clean-room.exclusions").items
  }
};

const serialized = `${JSON.stringify(report, null, 2)}\n`;
if (process.argv.includes("--write")) {
  await writeFile(reportPath, serialized);
} else if (process.argv.includes("--check")) {
  const checkedIn = await readFile(reportPath, "utf8");
  if (checkedIn !== serialized) throw new Error(`${reportPath} is stale; run npm run update:free85:v2-parity`);
}
console.log(serialized.trimEnd());
