import { createHash } from "node:crypto";
import { readFile, writeFile } from "node:fs/promises";

const [rom, coverageText, performanceText, parityText, reproducibilityText, packageText] = await Promise.all([
  readFile("ROM/FREE85.ROM"),
  readFile("spec/free85/coverage.json", "utf8"),
  readFile("spec/free85/performance.json", "utf8"),
  readFile("spec/free85/v2-parity-report.json", "utf8"),
  readFile("spec/free85/reproducibility.json", "utf8"),
  readFile("package.json", "utf8")
]);
const coverage = JSON.parse(coverageText);
const performance = JSON.parse(performanceText);
const parity = JSON.parse(parityText);
const reproducibility = JSON.parse(reproducibilityText);
const packageJson = JSON.parse(packageText);

if (rom.length !== 131072) throw new Error(`Release ROM is ${rom.length} bytes instead of 131072`);
if (coverage.features.complete_test_percent !== 100) {
  throw new Error("Release coverage is not at 100 percent");
}
if (performance.phase !== coverage.phase || performance.release !== packageJson.version) {
  throw new Error("Release performance report does not match the package version");
}
if ((parity.gaps.byStatus.missing ?? 0) !== 0 || (parity.gaps.byStatus.partial ?? 0) !== 0) {
  throw new Error("Release parity report still contains applicable missing or partial gaps");
}
const releaseGap = parity.workPackages
  .find(({ id }) => id === "14.10")?.gaps
  .find(({ id }) => id === "release.2.0");
if (parity.phase !== "14.10" || releaseGap?.status !== "equivalent") {
  throw new Error("The Free85 2.0 release gap is not closed");
}
const romHash = createHash("sha256").update(rom).digest("hex");
if (reproducibility.release !== packageJson.version
  || reproducibility.phase !== coverage.phase
  || reproducibility.rom.sha256 !== romHash
  || reproducibility.independent_builds < 2) {
  throw new Error("Release reproducibility evidence is absent or stale");
}

const manifest = {
  schema_version: 2,
  name: "Free85",
  version: packageJson.version,
  phase: coverage.phase,
  target_release: packageJson.version,
  status: packageJson.version.includes("-dev.") ? "development" : "stable",
  license: "MIT",
  persistent_ram: {
    schema: 13,
    status: "frozen",
    migrates_from: [12],
    object_store_schema: 1
  },
  rom: {
    path: "ROM/FREE85.ROM",
    bytes: rom.length,
    sha256: romHash,
    banks: 8,
    bank_bytes: 16384
  },
  source: "firmware/free85/",
  build_instructions: "README.md#build-the-rom",
  coverage_report: "spec/free85/coverage.json",
  performance_report: "spec/free85/performance.json",
  parity_report: "spec/free85/v2-parity-report.json",
  reproducibility_report: "spec/free85/reproducibility.json",
  release_notes: packageJson.version.startsWith("3.")
    ? "docs/Free85-3.0-engineering-handoff.md"
    : "docs/Free85-2.21-engineering-handoff.md",
  known_limitations: "docs/known-limitations.md",
  notices: ["LICENSE", "NOTICE.md", "firmware/free85/LICENSE"],
  browser_default: "public/ti85-app.js"
};

const output = `${JSON.stringify(manifest, null, 2)}\n`;
if (process.argv.includes("--write")) await writeFile("spec/free85/release.json", output);
console.log(output.trimEnd());
